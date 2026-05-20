const { GoogleGenerativeAI } = require('@google/generative-ai');

const MODEL = 'gemini-flash-latest';

let _genAI = null;
function genAI() {
  if (!process.env.GEMINI_API_KEY) {
    throw Object.assign(new Error('ai_disabled'), { expose: true, status: 503 });
  }
  if (!_genAI) _genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  return _genAI;
}
function client(systemInstruction) {
  return genAI().getGenerativeModel(
    systemInstruction ? { model: MODEL, systemInstruction } : { model: MODEL }
  );
}

// ── Helpers ──────────────────────────────────────────────────────────────────

async function fetchImageAsBase64(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`fetch ${url} → ${res.status}`);
  const mime = res.headers.get('content-type') || 'image/jpeg';
  const buf = Buffer.from(await res.arrayBuffer());
  return { mimeType: mime, data: buf.toString('base64') };
}

function safeJson(text) {
  // Gemini sometimes wraps JSON in ```json ... ``` or adds prose. Extract braces.
  const m = text.match(/\{[\s\S]*\}/);
  if (!m) return null;
  try { return JSON.parse(m[0]); } catch { return null; }
}

// ── 1. Photo analysis ───────────────────────────────────────────────────────

async function analyzePhoto(photoUrl) {
  const image = await fetchImageAsBase64(photoUrl);
  const prompt = `Tu es un assistant qui analyse des photos prises sur les plages tunisiennes pour aider une application de surveillance côtière.

Analyse l'image et réponds UNIQUEMENT par un objet JSON avec ces champs:
- "type": un des suivants — "erosion", "pollution", "wildlife", "infrastructure", "photo", "other"
- "severity": un entier de 1 à 5 (1 = bénin, 5 = critique)
- "description": une phrase courte en français (max 120 caractères) décrivant ce que tu vois
- "confidence": "low" | "medium" | "high"

Règles:
- Si la photo montre des déchets, du plastique, une marée noire → type="pollution"
- Si la photo montre du recul de plage, une falaise effondrée, du sable manquant → type="erosion"
- Si la photo montre un animal blessé ou en détresse → type="wildlife"
- Si la photo montre un escalier cassé, une rampe, du béton endommagé → type="infrastructure"
- Si c'est juste une belle photo de plage → type="photo", severity=1
- Si rien de pertinent (selfie, intérieur, etc.) → type="other", severity=1, confidence="low"

Réponds en JSON uniquement, pas de texte avant ou après.`;

  const result = await client().generateContent([
    { inlineData: image },
    prompt,
  ]);
  const text = result.response.text();
  const json = safeJson(text);
  if (!json) throw new Error('ai_parse_failed');

  return {
    type:        ['erosion','pollution','wildlife','infrastructure','photo','other'].includes(json.type) ? json.type : 'other',
    severity:    Math.max(1, Math.min(5, parseInt(json.severity) || 3)),
    description: String(json.description || '').slice(0, 200),
    confidence:  ['low','medium','high'].includes(json.confidence) ? json.confidence : 'medium',
  };
}

// ── 2. Smart triage (called fire-and-forget after report creation) ──────────

async function scoreReport({ type, severity, message, photoUrl }) {
  const prompt = `Tu es un modérateur d'une application de surveillance des plages tunisiennes.
Un utilisateur vient de soumettre ce signalement. Évalue la probabilité qu'il soit légitime et utile (vs spam, blague, hors-sujet).

- Type: ${type}
- Sévérité: ${severity}/5
- Message: ${message || '(aucun)'}
- Photo jointe: ${photoUrl ? 'oui' : 'non'}

Réponds UNIQUEMENT par un objet JSON:
{ "score": <0..100>, "reason": "<phrase courte en français>" }

100 = clairement légitime et utile, 50 = douteux, 0 = clairement spam ou non pertinent.`;

  const result = await client().generateContent(prompt);
  const json = safeJson(result.response.text());
  if (!json) return null;
  return {
    score:  Math.max(0, Math.min(100, parseInt(json.score) || 50)),
    reason: String(json.reason || '').slice(0, 200),
  };
}

// ── 3. Chatbot ──────────────────────────────────────────────────────────────

const CHAT_SYSTEM = `Tu es l'assistant de l'application Costalina, dédiée à la surveillance citoyenne du littoral tunisien.
Tu aides les utilisateurs à:
- Comprendre comment signaler un problème (érosion, pollution, faune, infrastructure)
- Comprendre le système de points et de récompenses (+5 pts par signalement, +20 si vérifié, +10 si photo)
- Apprendre sur l'érosion côtière en Tunisie et les bonnes pratiques de protection
- Naviguer dans l'application (Accueil, Carte, Alertes, Profil)

Style: amical, concis (3 phrases max), tutoiement, français par défaut.
Si on te demande quelque chose hors-sujet (politique, médical, etc.), redirige poliment vers le sujet de l'app.`;

async function chat(messages, lang = 'fr') {
  // Gemini requires history to start with a 'user' message. The mobile app
  // shows a hardcoded UI greeting as the first assistant message — strip any
  // leading non-user entries before sending to the model.
  const cleaned = [...messages];
  while (cleaned.length > 0 && cleaned[0].role !== 'user') cleaned.shift();
  if (cleaned.length === 0) {
    throw Object.assign(new Error('no_user_message'), { expose: true, status: 400 });
  }

  const last = cleaned[cleaned.length - 1];
  if (last.role !== 'user') {
    throw Object.assign(new Error('last_must_be_user'), { expose: true, status: 400 });
  }

  const history = cleaned.slice(0, -1).map(m => ({
    role: m.role === 'assistant' ? 'model' : 'user',
    parts: [{ text: m.content }],
  }));

  const model = client(CHAT_SYSTEM + `\nLangue préférée: ${lang}.`);
  const session = model.startChat({ history });
  const result = await session.sendMessage(last.content);
  return { reply: result.response.text().trim() };
}

// ── 4. Beach risk forecast ──────────────────────────────────────────────────

async function forecastBeach(beach, reports) {
  const recent = reports.slice(0, 30).map(r => ({
    type:     r.type,
    severity: r.severity,
    status:   r.status,
    at:       r.createdAt,
  }));

  const prompt = `Tu es un analyste environnemental. Voici les ${recent.length} derniers signalements pour la plage "${beach.name}" (${beach.city}, Tunisie). Niveau de risque actuel: ${beach.risk}.

Signalements (les plus récents d'abord):
${JSON.stringify(recent, null, 2)}

Estime le risque pour le mois prochain et écris un court résumé.

Réponds UNIQUEMENT par un objet JSON:
{
  "risk": "stable" | "modere" | "eleve",
  "confidence": "low" | "medium" | "high",
  "summary": "<2-3 phrases en français qui expliquent la tendance>"
}`;

  const result = await client().generateContent(prompt);
  const json = safeJson(result.response.text());
  if (!json) throw new Error('ai_parse_failed');

  return {
    risk:       ['stable','modere','eleve'].includes(json.risk) ? json.risk : beach.risk,
    confidence: ['low','medium','high'].includes(json.confidence) ? json.confidence : 'low',
    summary:    String(json.summary || '').slice(0, 500),
  };
}

module.exports = { analyzePhoto, scoreReport, chat, forecastBeach };