const PDFDocument = require('pdfkit');
const fs          = require('fs');
const path        = require('path');

const doc  = new PDFDocument({ margin: 50, size: 'A4' });
const out  = path.join(__dirname, 'Costalina_App_Guide.pdf');
doc.pipe(fs.createWriteStream(out));

// ── Palette ───────────────────────────────────────────────────────────────────
const TEAL      = '#1A6B6B';
const TEAL_DARK = '#0D4040';
const GREY      = '#888888';
const INK       = '#1A2E2C';
const CREAM     = '#F5F7F5';
const WHITE     = '#FFFFFF';
const AMBER     = '#C17A2A';
const RED       = '#B03A2E';

// ── Helpers ───────────────────────────────────────────────────────────────────
function eyebrow(text, y) {
  doc.font('Helvetica').fontSize(8).fillColor(GREY)
     .text(text.toUpperCase(), 50, y, { characterSpacing: 1.2 });
}

function h1(text) {
  doc.moveDown(0.3);
  doc.font('Helvetica-Bold').fontSize(22).fillColor(TEAL_DARK).text(text);
  doc.moveDown(0.2);
  doc.moveTo(50, doc.y).lineTo(545, doc.y).strokeColor(TEAL).lineWidth(1).stroke();
  doc.moveDown(0.4);
}

function h2(text) {
  doc.moveDown(0.5);
  doc.font('Helvetica-Bold').fontSize(14).fillColor(TEAL).text(text);
  doc.moveDown(0.15);
}

function h3(text) {
  doc.moveDown(0.3);
  doc.font('Helvetica-Bold').fontSize(11).fillColor(INK).text(text);
  doc.moveDown(0.1);
}

function body(text, opts = {}) {
  doc.font('Helvetica').fontSize(9.5).fillColor(INK).text(text, { lineGap: 2, ...opts });
}

function bullet(text, indent = 65) {
  const y = doc.y;
  doc.font('Helvetica').fontSize(9).fillColor(TEAL).text('•', 50, y);
  doc.font('Helvetica').fontSize(9).fillColor(INK).text(text, indent, y, { width: 480 });
  doc.moveDown(0.15);
}

function tableRow(cols, widths, isHeader = false) {
  const startX = 50;
  const rowH   = isHeader ? 18 : 16;
  const y      = doc.y;

  // background
  if (isHeader) {
    doc.rect(startX, y, widths.reduce((a, b) => a + b, 0), rowH)
       .fill(TEAL_DARK);
  } else {
    doc.rect(startX, y, widths.reduce((a, b) => a + b, 0), rowH)
       .fill(CREAM);
  }

  let x = startX;
  cols.forEach((col, i) => {
    doc.font(isHeader ? 'Helvetica-Bold' : 'Helvetica')
       .fontSize(8.5)
       .fillColor(isHeader ? WHITE : INK)
       .text(col, x + 6, y + 4, { width: widths[i] - 10, ellipsis: true });
    x += widths[i];
  });

  doc.y = y + rowH + 1;
}

function codeBlock(lines) {
  const blockH = lines.length * 13 + 14;
  doc.rect(50, doc.y, 495, blockH).fill('#1E2E2C');
  const startY = doc.y + 7;
  lines.forEach((line, i) => {
    const isComment = line.trim().startsWith('#') || line.trim().startsWith('//');
    doc.font('Courier').fontSize(8)
       .fillColor(isComment ? '#5BBCB0' : '#D4E8E4')
       .text(line, 60, startY + i * 13, { width: 475 });
  });
  doc.y = doc.y + blockH + 8;
}

function divider() {
  doc.moveDown(0.3);
  doc.moveTo(50, doc.y).lineTo(545, doc.y).strokeColor('#C8DADA').lineWidth(0.5).stroke();
  doc.moveDown(0.3);
}

function newPage() {
  doc.addPage();
}

// ── COVER PAGE ────────────────────────────────────────────────────────────────
doc.rect(0, 0, 595, 842).fill(TEAL_DARK);

doc.font('Helvetica').fontSize(10).fillColor('#A8DDD8')
   .text('GUIDE COMPLET', 0, 180, { align: 'center', characterSpacing: 2.5 });

doc.font('Helvetica-Bold').fontSize(46).fillColor(WHITE)
   .text('Costalina', 0, 210, { align: 'center' });

doc.font('Helvetica').fontSize(16).fillColor('#A8DDD8')
   .text('Application de surveillance côtière', 0, 268, { align: 'center' });

doc.moveTo(200, 310).lineTo(395, 310).strokeColor('#5BBCB0').lineWidth(1).stroke();

doc.font('Helvetica').fontSize(11).fillColor(WHITE)
   .text('Flutter  ·  Node.js  ·  MongoDB', 0, 326, { align: 'center' });

doc.font('Helvetica').fontSize(9).fillColor('#6BADA8')
   .text('v 2.4  ·  Littoral tunisien  ·  2026', 0, 760, { align: 'center' });

// ── PAGE 2 — TABLE OF CONTENTS ────────────────────────────────────────────────
newPage();
doc.rect(0, 0, 595, 842).fill(WHITE);

doc.moveDown(1);
eyebrow('TABLE DES MATIÈRES', 55);
doc.moveDown(0.5);
h1('Sommaire');

const tocItems = [
  ['1.', 'Vue d\'ensemble', '3'],
  ['2.', 'Stack technique', '3'],
  ['3.', 'Architecture Flutter', '4'],
  ['4.', 'Architecture Backend', '5'],
  ['5.', 'Fonctionnalités détaillées', '6'],
  ['6.', 'Système de points & récompenses', '8'],
  ['7.', 'Sécurité', '9'],
  ['8.', 'Variables d\'environnement', '9'],
  ['9.', 'Lancer le projet', '10'],
];

tocItems.forEach(([num, title, page]) => {
  const y = doc.y;
  doc.font('Helvetica-Bold').fontSize(10).fillColor(TEAL_DARK).text(num, 55, y);
  doc.font('Helvetica').fontSize(10).fillColor(INK).text(title, 75, y);
  doc.font('Helvetica').fontSize(10).fillColor(GREY).text(page, 0, y, { align: 'right' });
  doc.y = y + 20;
  doc.moveTo(55, doc.y - 4).lineTo(540, doc.y - 4).strokeColor('#E0ECEC').lineWidth(0.5).stroke();
});

// ── PAGE 3 — OVERVIEW + STACK ─────────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 1', 55);
h1('Vue d\'ensemble');

body(
  'Costalina est une application mobile de science citoyenne permettant de surveiller l\'érosion côtière le long du littoral tunisien. ' +
  'Les utilisateurs soumettent des signalements depuis les plages, gagnent des points, échangent des récompenses et construisent collectivement une carte de risque en temps réel.'
);

doc.moveDown(0.5);
h2('Concept clé');

const concepts = [
  ['Signalement', 'L\'utilisateur observe une anomalie (érosion, pollution, …) et soumet un rapport géolocalisé avec photo et sévérité 1–5.'],
  ['Risque automatique', 'Chaque signalement déclenche un recalcul du risque de la plage. Si le risque change, une alerte est automatiquement créée.'],
  ['Points & Récompenses', 'Soumettre = +5 pts. Rapport vérifié = +20 pts (+10 si photo). Les points s\'échangent contre des récompenses partenaires.'],
  ['Hors-ligne', 'Si le réseau est indisponible, les rapports sont sauvegardés localement et renvoyés automatiquement à la reconnexion.'],
];
concepts.forEach(([title, desc]) => {
  h3(title);
  body(desc);
});

divider();
doc.moveDown(0.3);
eyebrow('Section 2', 55);
doc.moveDown(0.3);
h1('Stack Technique');

tableRow(['Couche', 'Technologie', 'Détails'], [120, 160, 215], true);
[
  ['Mobile', 'Flutter (Dart)', 'Android + iOS ready'],
  ['Backend', 'Node.js + Express', 'API REST JSON'],
  ['Base de données', 'MongoDB (Mongoose)', 'Cloud Atlas ou local'],
  ['Auth', 'JWT + flutter_secure_storage', 'Token 30 jours'],
  ['Cartes', 'flutter_map v7', 'Tuiles ESRI gratuites, sans clé'],
  ['Météo marine', 'Open-Meteo Marine API', 'Gratuit, sans clé API'],
  ['Photos', 'Multer → MongoDB Binary', 'Stockage en base, pas sur disque'],
  ['Graphiques', 'fl_chart', 'Line chart + Bar chart empilé'],
  ['File offline', 'shared_preferences', 'Queue JSON locale'],
  ['Police', 'Plus Jakarta Sans', 'Via google_fonts'],
  ['Localisation', 'geolocator ^13', 'GPS + stream position'],
  ['Limitation débit', 'express-rate-limit', '300/15min global, 20/15min auth'],
].forEach(row => tableRow(row, [120, 160, 215]));

// ── PAGE 4 — FLUTTER ARCHITECTURE ────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 3', 55);
h1('Architecture Flutter');

h2('Structure des dossiers');

codeBlock([
  'lib/',
  '├── main.dart                  # Routes, notifiers (thème, locale, tab)',
  '├── data/',
  '│   └── mock_beaches.dart      # Données de secours — 6 plages Monastir',
  '├── l10n/',
  '│   └── app_strings.dart       # Traductions FR / EN',
  '├── models/',
  '│   ├── beach.dart             # Beach + BeachRisk enum',
  '│   ├── alerte.dart            # Modèle alerte',
  '│   ├── signalement.dart       # Modèle rapport + fromJson',
  '│   ├── report_type.dart       # ReportType enum (6 types)',
  '│   ├── badge.dart             # BadgeTier + BadgeService',
  '│   ├── reward.dart            # Reward + Redemption',
  '│   └── user.dart              # AppUser',
  '├── screens/',
  '│   ├── splash_screen.dart     # Splash 3 s → onboarding ou login',
  '│   ├── onboarding_screen.dart # 3 pages (1ère ouverture seulement)',
  '│   ├── login_screen.dart      # Login + register + reset OTP',
  '│   ├── app_shell.dart         # IndexedStack + nav + FAB',
  '│   ├── home_screen.dart       # Dashboard principal',
  '│   ├── map_screen.dart        # Carte + GPS + heatmap',
  '│   ├── alertes_screen.dart    # Fil d\'alertes en direct',
  '│   ├── beach_detail_screen.dart # 4 onglets détail plage',
  '│   ├── profil_screen.dart     # Profil + badges + menu',
  '│   ├── rewards_screen.dart    # Catalogue récompenses',
  '│   └── leaderboard_screen.dart# Classement communautaire',
  '├── services/',
  '│   ├── api_service.dart       # Tous les appels HTTP',
  '│   ├── auth_service.dart      # JWT, login/register/reset',
  '│   ├── storage_service.dart   # Upload photo',
  '│   ├── weather_service.dart   # Météo + données marines',
  '│   ├── cache_service.dart     # Cache SharedPreferences',
  '│   ├── report_queue.dart      # File offline signalements',
  '│   └── location_service.dart  # GPS injectif (testable)',
  '├── theme/',
  '│   └── app_theme.dart         # CoastPalette, CType, CColors',
  '└── widgets/                   # 15+ widgets réutilisables',
]);

h2('Navigation');
tableRow(['Route', 'Écran', 'Déclencheur'], [100, 180, 215], true);
[
  ['/', 'SplashScreen', 'Démarrage de l\'app'],
  ['/onboarding', 'OnboardingScreen', '1ère ouverture (flag SharedPrefs)'],
  ['/login', 'LoginScreen', 'Après splash ou déconnexion'],
  ['/app', 'AppShell', 'Après connexion réussie'],
  ['push', 'BeachDetailScreen', 'Tap sur une plage'],
  ['push', 'RewardsScreen', 'Menu profil → Récompenses'],
  ['push', 'LeaderboardScreen', 'Menu profil → Classement'],
].forEach(row => tableRow(row, [100, 180, 215]));

// ── PAGE 5 — BACKEND ARCHITECTURE ────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 4', 55);
h1('Architecture Backend');

h2('Structure des dossiers');

codeBlock([
  'backend/',
  '├── server.js              # Express app + rate limiting + montage routes',
  '├── models/',
  '│   ├── User.js            # name, email, password(bcrypt), points, role',
  '│   ├── Beach.js           # id, name, city, risk, erosionMeters, lat/lng',
  '│   ├── Report.js          # beachId, userId, type, severity, status',
  '│   ├── Alert.js           # beachId, risk, message (auto-créées)',
  '│   ├── Photo.js           # Données binaires image en MongoDB',
  '│   ├── Reward.js          # name, description, cost, category, imageUrl',
  '│   └── Redemption.js      # userId, rewardId, code, status',
  '├── routes/',
  '│   ├── auth.js            # /register /login /me /forgot /reset-password',
  '│   ├── beaches.js         # GET all, GET :id, PUT risk',
  '│   ├── reports.js         # GET/POST, PATCH status, timeline, stats/me, /me',
  '│   ├── alerts.js          # GET toutes les alertes',
  '│   ├── uploads.js         # POST photo, GET photo/:id',
  '│   ├── users.js           # GET all, GET leaderboard',
  '│   └── rewards.js         # GET catalog, POST redeem, GET my redemptions',
  '├── middleware/',
  '│   ├── auth.js            # Vérification JWT',
  '│   └── requireModerator.js# Vérification rôle moderator/admin',
  '└── utils/',
  '    ├── riskService.js     # Calcul risque auto + création alertes',
  '    └── mailer.js          # Nodemailer pour OTP mot de passe',
]);

h2('Endpoints API');

tableRow(['Méthode', 'Route', 'Auth', 'Description'], [65, 195, 50, 185], true);
[
  ['POST', '/api/auth/register', '—', 'Créer un compte'],
  ['POST', '/api/auth/login', '—', 'Connexion → JWT'],
  ['GET',  '/api/auth/me', 'JWT', 'Profil courant'],
  ['PUT',  '/api/auth/me', 'JWT', 'Modifier nom / avatar'],
  ['POST', '/api/auth/forgot-password', '—', 'Envoyer OTP par email'],
  ['POST', '/api/auth/reset-password', '—', 'Réinitialiser mot de passe'],
  ['GET',  '/api/beaches', '—', 'Liste toutes les plages'],
  ['GET',  '/api/beaches/:id', '—', 'Détail d\'une plage'],
  ['GET',  '/api/reports', '—', 'Signalements (filtre beachId)'],
  ['POST', '/api/reports', 'JWT', 'Créer un signalement (+5 pts)'],
  ['PATCH','/api/reports/:id/status', 'Modo', 'Changer statut (vérifié/rejeté)'],
  ['GET',  '/api/reports/me', 'JWT', 'Mes signalements'],
  ['GET',  '/api/reports/stats/me', 'JWT', 'Mes statistiques'],
  ['GET',  '/api/reports/timeline', '—', 'Activité 12 mois par plage'],
  ['GET',  '/api/alerts', '—', 'Toutes les alertes actives'],
  ['POST', '/api/uploads/photo', 'JWT', 'Uploader une photo'],
  ['GET',  '/api/uploads/photo/:id', '—', 'Récupérer une photo'],
  ['GET',  '/api/rewards', '—', 'Catalogue récompenses'],
  ['POST', '/api/rewards/:id/redeem', 'JWT', 'Échanger points contre récompense'],
  ['GET',  '/api/rewards/redemptions/me', 'JWT', 'Historique échanges'],
  ['GET',  '/api/users/leaderboard', '—', 'Top 20 par points'],
].forEach(row => tableRow(row, [65, 195, 50, 185]));

// ── PAGE 6 — FEATURES ─────────────────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 5', 55);
h1('Fonctionnalités Détaillées');

h2('Authentification');
[
  'Inscription avec email + mot de passe (bcrypt hashé, 12 rounds)',
  'Connexion → JWT signé, stocké dans flutter_secure_storage (Keystore Android / Keychain iOS)',
  'Session restaurée au démarrage via GET /auth/me',
  'Réinitialisation par OTP envoyé par email (Nodemailer), code expire en 15 min',
  'Déconnexion efface le JWT localement',
].forEach(t => bullet(t));

h2('Soumission de signalement');
[
  'Sélection de la plage via dropdown (toutes les plages de l\'API)',
  'Type : erosion · pollution · faune · infrastructure · photo · autre',
  'Sévérité 1 à 5 (boutons visuels)',
  'Description libre (champ texte)',
  'Photo facultative : caméra ou galerie, redimensionnée à 1200px max',
  'GPS capturé automatiquement à l\'ouverture du formulaire',
  'Si réseau indisponible → enregistré dans SharedPreferences, renvoyé silencieusement à la reconnexion',
].forEach(t => bullet(t));

h2('Calcul automatique du risque');
[
  'Chaque création ou changement de statut de rapport déclenche recomputeBeachRisk()',
  'Score = Σ(sévérité × poidsStatut) sur les 90 derniers jours',
  'Poids : vérifié×1.0, en_attente×0.5, résolu×0.1, rejeté×0',
  'Seuils : score ≥ 12 → élevé · ≥ 5 → modéré · sinon stable',
  'Si le risque change → Alert automatiquement créée en base → visible dans l\'onglet Alertes',
].forEach(t => bullet(t));

h2('Carte interactive');
[
  'Tuiles satellite ESRI gratuites (flutter_map v7, CancellableNetworkTileProvider)',
  'Marqueurs de plage avec couleur de risque',
  'Bouton GPS : demande permission → centre sur l\'utilisateur → stream continu (10 m)',
  'Heatmap : toggle flamme → CircleLayer semi-transparent rouge sur chaque signalement géolocalisé',
].forEach(t => bullet(t));

h2('Détail d\'une plage — 4 onglets');

h3('Aperçu');
[
  'Slider avant/après : CustomClipper draggable (Mai 2023 vs Mai 2026)',
  'Carte KPI : recul en mètres + étoiles de gravité',
  'Données marines en direct : hauteur de vagues, période, temp. mer (Open-Meteo gratuit)',
  'Galerie photos (scroll horizontal) avec viewer plein écran + InteractiveViewer',
].forEach(t => bullet(t));

h3('Évolution');
[
  'Courbe d\'érosion LineChart (fl_chart)',
  'KPIs : recul total, vitesse, pire mois, indice de confiance',
  'Histogramme empilé 12 mois : érosion (teal) + pollution (ambre) + autre (gris)',
].forEach(t => bullet(t));

h3('Signalements');
[
  'Liste paginée depuis l\'API avec badge de statut coloré',
  'Miniature photo ou icône de type si pas de photo',
].forEach(t => bullet(t));

h3('Infos');
[
  'Métadonnées : région, longueur, type de plage, accès public, dernière inspection, sources',
].forEach(t => bullet(t));

// ── PAGE 7 — FEATURES (suite) ─────────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 5 (suite)', 55);
h1('Fonctionnalités — Suite');

h2('Alertes');
[
  'Chargées depuis l\'API, fallback sur données mock si hors-ligne',
  'Tap sur une alerte → fetch de la plage complète depuis l\'API (plus de crash sur données inconnues)',
  'Pastille étoile colorée selon le niveau de risque',
  'Filtrable par statut urgent (risk ≠ stable)',
].forEach(t => bullet(t));

h2('Profil utilisateur');
[
  'Photo de profil : modification + suppression avec upload vers MongoDB',
  'Stats en direct : total · vérifiés · en attente (rechargées à chaque visite de l\'onglet)',
  'Badges : 6 paliers calculés côté client depuis UserStats — Observateur → Expert Côtier',
  'Menu : Classement · Mes signalements · Récompenses · Notifications · Plages suivies · Apprentissage · À propos · Paramètres',
  'Déconnexion avec redirection vers /login',
].forEach(t => bullet(t));

h2('Mes signalements');
[
  'Liste de tous les rapports soumis par l\'utilisateur connecté',
  'Icône de type, libellé, date relative, badge de statut coloré (vert vérifié, orange en attente, rouge rejeté)',
  'Vide state illustré avec icône et message explicatif',
].forEach(t => bullet(t));

h2('Classement (Leaderboard)');
[
  'Top 20 utilisateurs triés par points',
  'Médailles 🥇🥈🥉 pour les 3 premiers',
  'L\'utilisateur courant est mis en évidence (fond teal + libellé "Vous")',
  'Pull-to-refresh pour actualiser',
].forEach(t => bullet(t));

h2('Mode hors-ligne');
[
  'Beaches et alertes mis en cache dans SharedPreferences (CacheService)',
  'Rapports qui échouent → ReportQueue.enqueue() → JSON list dans SharedPrefs',
  'Au prochain succès réseau : ReportQueue.flush() → renvoi automatique + snackbar',
  'Indicateur GPS absent si permission refusée (pas de crash silencieux)',
].forEach(t => bullet(t));

h2('Thème sombre / clair');
[
  'themeModeNotifier (ValueNotifier<ThemeMode>) dans main.dart drive MaterialApp.themeMode',
  'CoastPalette ThemeExtension avec instances .light et .dark',
  'Toggle dans la page Profil, reset au redémarrage (normal pour un prototype)',
  'Ne jamais hardcoder Colors.white pour les surfaces — toujours palette(context).bg / .surface',
].forEach(t => bullet(t));

h2('Internationalisation');
[
  'AppStrings.current expose les chaînes dans la langue active',
  'localeNotifier (ValueNotifier<Locale>) change la langue en temps réel',
  'LangPickerBtn disponible dans toutes les top bars',
  'Langues : Français (défaut) · Anglais',
].forEach(t => bullet(t));

// ── PAGE 8 — REWARDS ─────────────────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 6', 55);
h1('Système de Points & Récompenses');

h2('Attribution des points');

tableRow(['Action', 'Points accordés'], [280, 215], true);
[
  ['Soumettre un signalement', '+5 pts'],
  ['Rapport vérifié par un modérateur', '+20 pts'],
  ['Rapport vérifié avec photo jointe', '+30 pts (20 + 10 bonus)'],
].forEach(row => tableRow(row, [280, 215]));

doc.moveDown(0.5);
h2('Catalogue de récompenses (seedé en base)');

tableRow(['Récompense', 'Coût', 'Catégorie'], [230, 80, 185], true);
[
  ['Cocktail offert (bar partenaire)', '100 pts', 'experience'],
  ['Plantation d\'un arbre à votre nom', '200 pts', 'eco'],
  ['T-shirt Costalina coton bio', '250 pts', 'merch'],
  ['Massage spa 30 minutes', '500 pts', 'experience'],
  ['Session paddle 2h avec moniteur', '1000 pts', 'experience'],
  ['Excursion bateau — îles Kuriat', '1500 pts', 'experience'],
].forEach(row => tableRow(row, [230, 80, 185]));

doc.moveDown(0.5);
h2('Mécanisme d\'échange (atomique)');
body(
  'L\'échange utilise MongoDB findOneAndUpdate avec la condition { points: { $gte: cost } } et l\'opération ' +
  '{ $inc: { points: -cost } }. Cette opération est atomique : il est impossible de tomber en dessous de zéro, ' +
  'même avec des requêtes concurrentes. En cas de solde insuffisant, le backend retourne { error: "insufficient_points" }.'
);

doc.moveDown(0.5);
h2('Badges (calculés côté client)');

tableRow(['Badge', 'Condition', 'Palier'], [160, 200, 135], true);
[
  ['Observateur', '1 signalement total', 'Bronze'],
  ['Sentinelle', '5 signalements total', 'Bronze'],
  ['Gardien du littoral', '10 signalements total', 'Argent'],
  ['Expert côtier', '25 signalements total', 'Or'],
  ['Ambassadeur Costalina', '5 signalements vérifiés', 'Or'],
  ['Champion de la côte', '10 signalements vérifiés', 'Platine'],
].forEach(row => tableRow(row, [160, 200, 135]));

// ── PAGE 9 — SECURITY + ENV ───────────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 7', 55);
h1('Sécurité');

h2('Authentification & Autorisation');
[
  'JWT signé avec JWT_SECRET (env var), expiration 30 jours',
  'Middleware auth.js vérifie chaque token sur les routes protégées',
  'Middleware requireModerator.js vérifie role ∈ {moderator, admin} pour PATCH /reports/:id/status',
  'Seul le propriétaire d\'un rapport peut le supprimer (DELETE /reports/:id)',
  'Rôles disponibles : user (défaut) · moderator · admin',
].forEach(t => bullet(t));

h2('Limitation de débit (express-rate-limit)');

tableRow(['Règle', 'Fenêtre', 'Limite'], [200, 120, 175], true);
[
  ['Global (toutes routes)', '15 minutes', '300 requêtes'],
  ['POST /auth/login', '15 minutes', '20 requêtes'],
  ['POST /auth/register', '15 minutes', '20 requêtes'],
  ['Toutes routes /reports', '1 minute', '10 requêtes'],
].forEach(row => tableRow(row, [200, 120, 175]));

doc.moveDown(0.5);
h2('Stockage des données sensibles');
[
  'Mots de passe : bcrypt (12 rounds), jamais stockés en clair',
  'JWT côté mobile : flutter_secure_storage (Android Keystore / iOS Keychain)',
  'OTP de reset : hashé en base, TTL 15 minutes, effacé après usage',
  'Photos : binaire MongoDB (pas de fichiers disque exposés publiquement)',
].forEach(t => bullet(t));

divider();

eyebrow('Section 8', doc.y + 5);
doc.moveDown(0.5);
h1('Variables d\'Environnement');

h2('Fichier backend/.env');

codeBlock([
  '# MongoDB',
  'MONGODB_URI=mongodb+srv://<user>:<pass>@cluster.mongodb.net/costalina',
  '',
  '# JWT',
  'JWT_SECRET=votre-clé-secrète-longue-et-aléatoire',
  '',
  '# Nodemailer (reset mot de passe)',
  'EMAIL_USER=votre@email.com',
  'EMAIL_PASS=votre-mot-de-passe-app',
  '',
  '# Serveur',
  'PORT=3000',
]);

body('Toutes ces variables sont requises. Sans MONGODB_URI le serveur ne démarre pas. Sans EMAIL_* la réinitialisation de mot de passe échoue silencieusement.');

// ── PAGE 10 — RUNNING ─────────────────────────────────────────────────────────
newPage();

doc.moveDown(1);
eyebrow('Section 9', 55);
h1('Lancer le Projet');

h2('Prérequis');

tableRow(['Outil', 'Version minimum', 'Utilisation'], [120, 130, 245], true);
[
  ['Flutter SDK', '3.x', 'Développement mobile'],
  ['Dart', 'Inclus Flutter', 'Langage mobile'],
  ['Node.js', '18.x+', 'Backend API'],
  ['MongoDB', 'Atlas (cloud) ou local', 'Base de données'],
  ['Android Studio', 'Flamingo+', 'Build Android + émulateur'],
  ['ADB', 'Platform Tools', 'Débogage USB device réel'],
].forEach(row => tableRow(row, [120, 130, 245]));

doc.moveDown(0.5);
h2('Démarrer le backend');
codeBlock([
  '# 1. Installer les dépendances',
  'cd backend && npm install',
  '',
  '# 2. Créer le fichier .env (voir section Variables)',
  '',
  '# 3. Lancer le serveur',
  'node server.js',
  '# → ✅  MongoDB connected',
  '# → 🚀  Costalina API running on http://0.0.0.0:3000',
  '',
  '# (Optionnel) Seeder les récompenses',
  'node seed_rewards.js',
]);

h2('Démarrer l\'app mobile');
codeBlock([
  '# 1. Installer les dépendances Flutter',
  'flutter pub get',
  '',
  '# 2. (Device USB) Tunnel port vers le device',
  'adb reverse tcp:3000 tcp:3000',
  '',
  '# 3. Lancer sur le device connecté',
  'flutter run -d <device-id>',
  '',
  '# Obtenir la liste des devices',
  'flutter devices',
  '',
  '# Build APK de debug',
  'flutter build apk --debug',
]);

h2('Commandes utiles');
tableRow(['Commande', 'Description'], [250, 245], true);
[
  ['flutter analyze', 'Analyser le code Dart (lint)'],
  ['flutter test', 'Exécuter les tests unitaires'],
  ['flutter clean', 'Nettoyer le cache de build (résout les locks Gradle)'],
  ['adb devices', 'Lister les appareils Android connectés'],
  ['node seed_rewards.js', 'Re-seeder le catalogue de récompenses'],
  ['GET /api/health', 'Vérifier que le backend répond'],
].forEach(row => tableRow(row, [250, 245]));

doc.moveDown(0.6);
h2('Résoudre les problèmes courants');

h3('Erreur Gradle : fichier verrouillé (generate_cxx_metadata)');
[
  'Exécuter : Get-Process -Name "java" | Stop-Process -Force',
  'Supprimer : build/app/intermediates/cxx/',
  'Relancer flutter run',
].forEach((t, i) => bullet(`Étape ${i+1} : ${t}`));

h3('Backend sur port 3000 occupé');
[
  'Get-NetTCPConnection -LocalPort 3000 | Select-Object OwningProcess',
  'Stop-Process -Id <PID> -Force',
].forEach((t, i) => bullet(`Étape ${i+1} : ${t}`));

h3('Photos refusées (Android → application/octet-stream)');
bullet('Le middleware uploads.js accepte déjà octet-stream si l\'extension est .jpg/.png/etc. et normalise le Content-Type avant stockage en base.');

// ── BACK COVER ────────────────────────────────────────────────────────────────
newPage();
doc.rect(0, 0, 595, 842).fill(TEAL_DARK);

doc.font('Helvetica').fontSize(9).fillColor('#6BADA8')
   .text('COSTALINA — GUIDE COMPLET', 0, 360, { align: 'center', characterSpacing: 2 });

doc.font('Helvetica-Bold').fontSize(28).fillColor(WHITE)
   .text('Surveiller. Signaler. Agir.', 0, 388, { align: 'center' });

doc.moveTo(180, 435).lineTo(415, 435).strokeColor('#5BBCB0').lineWidth(1).stroke();

doc.font('Helvetica').fontSize(10).fillColor('#A8DDD8')
   .text('contact@costalina.tn  ·  www.costalina.tn', 0, 450, { align: 'center' });

doc.font('Helvetica').fontSize(8).fillColor('#3A6060')
   .text('v 2.4  ·  Littoral tunisien  ·  2026', 0, 800, { align: 'center' });

doc.end();
console.log('PDF generated:', out);