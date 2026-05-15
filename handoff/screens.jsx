// Costalina — editorial redesign matching the web aesthetic
// (Cormorant Garamond + Jost · sand/teal palette · hairline borders · italic accents).
// Five screens: Accueil, Carte, Détails de la plage, Alertes, Profil.

const { useState, useEffect, useRef } = React;

// ─────────────────────────────────────────────────────────────
// Design tokens — mirrors the web's --teal / --sand / --ink set
// ─────────────────────────────────────────────────────────────
const C = {
  teal:      '#5bbcb0',
  tealDark:  '#3d9e93',
  tealDeep:  '#1d504b',
  tealPale:  '#a8ddd8',
  tealBg:    '#e8f7f5',
  sand:      '#f5f0e8',
  sandDark:  '#e0d8c8',
  white:     '#ffffff',
  ink:       '#1a2e2c',
  inkSoft:   '#3a5450',
  grey:      '#7a9490',
  hairline:  'rgba(91, 188, 176, 0.22)',
  hairlineSoft: 'rgba(91, 188, 176, 0.14)',
  // Risk semantics — muted, not chunky
  green:  { ink: '#1d9e75', bg: 'rgba(29, 158, 117, 0.10)', dot: '#1d9e75' },
  amber:  { ink: '#c4804a', bg: 'rgba(196, 128, 74, 0.12)', dot: '#c4804a' },
  red:    { ink: '#a84848', bg: 'rgba(168, 72, 72, 0.10)',  dot: '#a84848' },
};
const RISK = {
  stable: { label: 'Stable',         severity: 1, ...C.green },
  modere: { label: 'Risque modéré',  severity: 3, ...C.amber },
  eleve:  { label: 'Risque élevé',   severity: 5, ...C.red },
};

const FONT_SERIF = "'Cormorant Garamond', Georgia, serif";
const FONT_SANS  = "'Jost', -apple-system, system-ui, sans-serif";

// ─────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────
const BEACHES = [
  { id: 'sayada',   name: 'Plage de Sayada',  city: 'Monastir', risk: 'eleve',  x: 58, y: 18, lastUpdate: '21·05·2026',
    photo: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?w=900&q=80&auto=format&fit=crop',
    erosion: '−5.8 m', period: 'sur 12 mois' },
  { id: 'skanes',   name: 'Plage de Skanes',  city: 'Monastir', risk: 'modere', x: 60, y: 32, lastUpdate: '20·05·2026',
    photo: 'https://images.unsplash.com/photo-1473625247510-8ceb1760943f?w=900&q=80&auto=format&fit=crop',
    erosion: '−3.2 m', period: 'sur 12 mois' },
  { id: 'sousse',   name: 'Plage de Sousse',  city: 'Sousse',   risk: 'stable', x: 62, y: 46, lastUpdate: '19·05·2026',
    photo: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=80&auto=format&fit=crop',
    erosion: '−0.4 m', period: 'sur 12 mois' },
  { id: 'teboulba', name: 'Plage de Teboulba', city: 'Monastir', risk: 'stable', x: 60, y: 60, lastUpdate: '18·05·2026',
    photo: 'https://images.unsplash.com/photo-1439130490301-25e322d88054?w=900&q=80&auto=format&fit=crop',
    erosion: '−0.7 m', period: 'sur 12 mois' },
  { id: 'bekalta',  name: 'Plage de Bekalta', city: 'Monastir', risk: 'modere', x: 62, y: 74, lastUpdate: '16·05·2026',
    photo: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=80&auto=format&fit=crop',
    erosion: '−2.4 m', period: 'sur 12 mois' },
  { id: 'kuriat',   name: 'Îles Kuriat',      city: 'Monastir', risk: 'stable', x: 88, y: 56, lastUpdate: '17·05·2026',
    photo: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=80&auto=format&fit=crop',
    erosion: '−0.1 m', period: 'sur 12 mois' },
];

const SIGNALEMENTS = [
  { id: 1, type: 'Érosion',                   when: '18·05·2026 · 10:30', status: 'En cours', statusColor: 'amber',
    thumb: 'https://images.unsplash.com/photo-1473625247510-8ceb1760943f?w=200&q=70&auto=format&fit=crop' },
  { id: 2, type: 'Pollution plastique',       when: '15·05·2026 · 16:12', status: 'Résolu',   statusColor: 'green',
    thumb: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=200&q=70&auto=format&fit=crop' },
  { id: 3, type: 'Construction non-déclarée', when: '12·05·2026 · 09:05', status: 'En cours', statusColor: 'amber',
    thumb: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=200&q=70&auto=format&fit=crop' },
];

const ALERTES = [
  { id: 1, beach: 'Plage de Sayada',  msg: 'Recul du trait de côte de 5,8 m détecté.',     time: 'il y a 2 h',  risk: 'eleve'  },
  { id: 2, beach: 'Plage de Skanes',  msg: 'Nouveau signalement d\u2019érosion à vérifier.', time: 'il y a 5 h',  risk: 'modere' },
  { id: 3, beach: 'Plage de Bekalta', msg: 'Mise à jour satellite disponible.',             time: 'hier',         risk: 'modere' },
  { id: 4, beach: 'Plage de Sousse',  msg: 'État stable confirmé par relevé terrain.',      time: 'hier',         risk: 'stable' },
  { id: 5, beach: 'Îles Kuriat',      msg: 'Campagne de mesure planifiée le 25·05.',        time: '2 jours',      risk: 'stable' },
];

// ─────────────────────────────────────────────────────────────
// Editorial atoms — eyebrows, serif titles, hairlines, brand mark
// ─────────────────────────────────────────────────────────────
const STAR_CLIP = 'polygon(50% 0%, 61% 35%, 98% 35%, 68% 57%, 79% 91%, 50% 70%, 21% 91%, 32% 57%, 2% 35%, 39% 35%)';

// Costalina logo mark — starfish + palm + waves inside a ring.
// Faithful inline SVG of the brand logo so it scales + recolors cleanly.
function CostalinaMark({ size = 28, color = C.tealDark }) {
  return (
    <svg viewBox="0 0 100 100" width={size} height={size} style={{ display: 'block', flexShrink: 0 }} aria-hidden="true">
      {/* Ring */}
      <circle cx="50" cy="50" r="46.5" fill="none" stroke={color} strokeWidth="2.6"/>
      {/* Starfish — upper-left */}
      <g transform="translate(30 33) rotate(-18)" fill={color}>
        <path d="M 0 -11 C 1.6 -4 4 -3 10 -3.4 C 5 1 3.8 4 7 11 C 1 6.5 -1 6.5 -7 11 C -3.8 4 -5 1 -10 -3.4 C -4 -3 -1.6 -4 0 -11 Z"/>
      </g>
      {/* Palm — upper-right with dune */}
      <g transform="translate(68 30)" fill={color}>
        {/* trunk */}
        <path d="M -1.1 0 Q -2 8 -3.6 16 L 0 16 L 1.6 16 Q 1 8 1.1 0 Z"/>
        {/* crown fronds — 6 radiating ellipses */}
        <ellipse cx="0" cy="-2" rx="8.5" ry="2.3"/>
        <ellipse cx="0" cy="-2" rx="8.5" ry="2.3" transform="rotate(45)"/>
        <ellipse cx="0" cy="-2" rx="8.5" ry="2.3" transform="rotate(-45)"/>
        <ellipse cx="0" cy="-2" rx="8.5" ry="2.3" transform="rotate(90)"/>
        <ellipse cx="0" cy="-2" rx="8.5" ry="2.3" transform="rotate(-90)"/>
        <ellipse cx="0" cy="-2" rx="8.5" ry="2.3" transform="rotate(135)"/>
        {/* dune */}
        <path d="M -17 16 Q -8 13 0 14 Q 10 15 17 17 L 17 19 L -17 19 Z"/>
      </g>
      {/* Waves — three flowing lines */}
      <g fill="none" stroke={color} strokeWidth="2.6" strokeLinecap="round">
        <path d="M 13 62 Q 25 56 37 62 Q 49 68 61 62 Q 73 56 87 62"/>
        <path d="M 16 70 Q 28 64 40 70 Q 52 76 64 70 Q 76 64 84 70"/>
        <path d="M 20 78 Q 32 73 44 78 Q 56 83 68 78 Q 76 74 81 78"/>
      </g>
    </svg>
  );
}

// Small star ornament (kept for risk-severity gauge — used elsewhere).
function BrandMark({ size = 14, color = C.teal }) {
  return (
    <span style={{
      display: 'inline-block', width: size, height: size, flexShrink: 0,
      background: color, clipPath: STAR_CLIP,
    }}/>
  );
}

function Eyebrow({ children, color = C.teal, size = 10, tracking = 0.32, weight = 500, style }) {
  return (
    <div style={{
      fontFamily: FONT_SANS, fontSize: size, letterSpacing: `${tracking}em`,
      textTransform: 'uppercase', color, fontWeight: weight, ...style,
    }}>{children}</div>
  );
}

function SerifTitle({ children, size = 30, color = C.ink, style, italic = false }) {
  return (
    <h1 style={{
      margin: 0, fontFamily: FONT_SERIF, fontWeight: 300,
      fontSize: size, color, lineHeight: 1.12, letterSpacing: -0.2,
      fontStyle: italic ? 'italic' : 'normal', ...style,
    }}>{children}</h1>
  );
}

function HairLine({ color = C.hairline, length = 56, vertical = false, style }) {
  return (
    <span style={{
      display: 'block',
      width: vertical ? 1 : length,
      height: vertical ? length : 1,
      background: color, ...style,
    }}/>
  );
}

function SectionHead({ kicker, title, italic, right, divider = true }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 12, marginBottom: 10 }}>
        <div style={{ minWidth: 0, flex: 1 }}>
          {kicker && <Eyebrow style={{ marginBottom: 8 }}>{kicker}</Eyebrow>}
          <SerifTitle size={22}>{title}{italic ? <em style={{ color: C.tealDark, fontStyle: 'italic', fontFamily: FONT_SERIF }}> {italic}</em> : null}</SerifTitle>
        </div>
        {right}
      </div>
      {divider && <HairLine color={C.hairlineSoft}/>}
    </div>
  );
}

function GhostLink({ children, onClick }) {
  return (
    <button onClick={onClick} style={{
      ...btnReset, fontFamily: FONT_SANS, fontSize: 10, letterSpacing: '.22em',
      textTransform: 'uppercase', color: C.tealDark, paddingBottom: 3,
      borderBottom: `1px solid ${C.tealPale}`,
    }}>{children}</button>
  );
}

// Risk severity rendered as 5 star clips (Iberostar-style rating, repurposed)
function StarGauge({ severity, color, size = 6, gap = 4 }) {
  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', gap }}>
      {[0,1,2,3,4].map(i => (
        <span key={i} style={{
          display: 'block', width: size, height: size,
          background: i < severity ? color : 'rgba(26,46,44,0.18)',
          clipPath: STAR_CLIP,
        }}/>
      ))}
    </div>
  );
}

// Risk tag — small dot + uppercase letter-spaced label, hairline border
function RiskTag({ risk, light = false, size = 'md' }) {
  const r = RISK[risk];
  const fs = size === 'sm' ? 9 : 10;
  const py = size === 'sm' ? 3 : 5;
  const px = size === 'sm' ? 8 : 10;
  const fg = light ? '#fff' : r.ink;
  const bg = light ? 'rgba(255,255,255,0.14)' : r.bg;
  const border = light ? 'rgba(255,255,255,0.4)' : `rgba(${hexToRgb(r.dot)},0.4)`;
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: `${py}px ${px}px`,
      background: bg, color: fg,
      border: `1px solid ${border}`,
      fontFamily: FONT_SANS, fontSize: fs, fontWeight: 500,
      letterSpacing: '.16em', textTransform: 'uppercase',
    }}>
      <span style={{ width: 5, height: 5, borderRadius: 99, background: light ? '#fff' : r.dot }}/>
      {r.label}
    </span>
  );
}

// ─────────────────────────────────────────────────────────────
// Top brand bar — appears on most screens
// ─────────────────────────────────────────────────────────────
function TopBar({ left, right, dark = false }) {
  const fg = dark ? '#fff' : C.ink;
  return (
    <div style={{
      paddingTop: 56, padding: '56px 22px 14px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      background: dark ? 'transparent' : C.sand,
      borderBottom: dark ? 'none' : `1px solid ${C.hairlineSoft}`,
      color: fg,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, minWidth: 0 }}>
        {left || (
          <>
            <CostalinaMark color={dark ? '#fff' : C.tealDark} size={26}/>
            <span style={{
              fontFamily: FONT_SANS, fontWeight: 300,
              fontSize: 13, letterSpacing: '.38em', textTransform: 'uppercase',
              color: dark ? '#fff' : C.tealDark,
            }}>Costalina</span>
          </>
        )}
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>{right}</div>
    </div>
  );
}

function IconBtn({ children, onClick, light = false }) {
  return (
    <button onClick={onClick} style={{
      ...btnReset, width: 32, height: 32,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: light ? '#fff' : C.ink,
    }}>{children}</button>
  );
}

// ─────────────────────────────────────────────────────────────
// 1. ACCUEIL (Home)
// ─────────────────────────────────────────────────────────────
function HomeScreen({ onOpenBeach, onTab }) {
  const featured = BEACHES.find(b => b.id === 'skanes');
  const counts = { stable: 12, modere: 8, eleve: 5 };

  return (
    <div data-screen-label="01 Accueil" style={{ background: C.sand, minHeight: '100%' }}>
      <TopBar right={
        <>
          <IconBtn><IconBellDot size={20}/></IconBtn>
          <IconBtn><IconMenu size={22}/></IconBtn>
        </>
      }/>

      {/* Editorial intro */}
      <div style={{ padding: '24px 22px 22px' }}>
        <Eyebrow style={{ marginBottom: 12 }}>Littoral tunisien · 2026</Eyebrow>
        <SerifTitle size={34} style={{ lineHeight: 1.08 }}>
          Veillons sur nos<br/><em style={{ color: C.tealDark, fontStyle: 'italic' }}>plages</em>.
        </SerifTitle>
        <p style={{
          margin: '14px 0 0', fontFamily: FONT_SANS, fontWeight: 300,
          fontSize: 13, color: C.inkSoft, lineHeight: 1.7, letterSpacing: 0.1,
          maxWidth: 300,
        }}>
          Surveillance du trait de côte, signalements citoyens et données satellite — à portée de main.
        </p>
      </div>

      {/* Featured beach — editorial hero card */}
      <div style={{ padding: '0 22px' }}>
        <button onClick={() => onOpenBeach(featured.id)} style={{
          ...btnReset, width: '100%', display: 'block', textAlign: 'left',
          position: 'relative', overflow: 'hidden',
          aspectRatio: '5 / 6',
          background: C.ink,
        }}>
          <img src={featured.photo} alt="" style={{
            width: '100%', height: '100%', objectFit: 'cover', display: 'block',
            filter: 'saturate(0.92)',
          }}/>
          <div style={{
            position: 'absolute', inset: 0,
            background: 'linear-gradient(to top, rgba(26,46,44,0.92) 0%, rgba(26,46,44,0.25) 45%, transparent 80%)',
          }}/>
          {/* Corner ornaments */}
          <CornerOrnament/>
          {/* Top eyebrow */}
          <div style={{ position: 'absolute', top: 18, left: 20, right: 20, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Eyebrow color="rgba(168,221,216,0.95)" size={9} tracking={0.38}>À la une</Eyebrow>
            <Eyebrow color="rgba(255,255,255,0.7)" size={9} tracking={0.28}>{featured.lastUpdate}</Eyebrow>
          </div>
          {/* Bottom copy */}
          <div style={{ position: 'absolute', left: 22, right: 22, bottom: 22 }}>
            <Eyebrow color="rgba(168,221,216,0.95)" size={10} tracking={0.35} style={{ marginBottom: 8 }}>
              {featured.city} · Trait de côte
            </Eyebrow>
            <SerifTitle size={32} color="#fff" style={{ lineHeight: 1.05 }}>
              {featured.name.replace('Plage de ', '')}
            </SerifTitle>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 14 }}>
              <RiskTag risk={featured.risk} light/>
              <span style={{
                color: 'rgba(255,255,255,0.7)', fontFamily: FONT_SERIF,
                fontStyle: 'italic', fontSize: 13,
              }}>· recul {featured.erosion}</span>
            </div>
            <div style={{
              marginTop: 18, display: 'flex', alignItems: 'center', gap: 10,
              color: '#fff', fontFamily: FONT_SANS, fontSize: 11,
              fontWeight: 400, letterSpacing: '.24em', textTransform: 'uppercase',
            }}>
              Découvrir le détail
              <span style={{ fontSize: 14, lineHeight: 1, fontWeight: 300 }}>→</span>
            </div>
          </div>
        </button>
      </div>

      {/* État des plages — editorial stat strip */}
      <div style={{ padding: '40px 22px 0' }}>
        <SectionHead kicker="Synthèse" title="État du" italic="littoral"/>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 0, border: `1px solid ${C.hairline}`, background: C.white }}>
          <StatCell label="Plages stables" count={counts.stable} risk="stable"/>
          <StatCell label="Risque modéré"  count={counts.modere} risk="modere" middle/>
          <StatCell label="Risque élevé"   count={counts.eleve}  risk="eleve"/>
        </div>
      </div>

      {/* Actions */}
      <div style={{ padding: '36px 22px 0' }}>
        <SectionHead kicker="À votre main" title="Actions" italic="rapides"/>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 0, border: `1px solid ${C.hairline}`, background: C.white }}>
          <QuickAction icon={<IconCamera size={20}/>} label="Ajouter une photo"      sub="Capturez la plage"/>
          <QuickAction icon={<IconAlert size={20}/>}  label="Signaler un problème"   sub="Érosion, pollution…" rightBorder/>
          <QuickAction icon={<IconMap size={20}/>}    label="Voir la carte"          sub="Toutes les plages" topBorder onClick={() => onTab('map')}/>
          <QuickAction icon={<IconCap size={20}/>}    label="Centre d'apprentissage" sub="Comprendre l'érosion" topBorder rightBorder/>
        </div>
      </div>

      {/* Plages surveillées — editorial list */}
      <div style={{ padding: '36px 22px 30px' }}>
        <SectionHead kicker="Veille active" title="Plages" italic="surveillées" right={<GhostLink>Voir tout</GhostLink>}/>
        <div style={{ display: 'flex', flexDirection: 'column' }}>
          {BEACHES.slice(0, 4).map((b, i) => (
            <BeachListRow key={b.id} beach={b} onClick={() => onOpenBeach(b.id)} first={i === 0}/>
          ))}
        </div>
      </div>
    </div>
  );
}

function CornerOrnament() {
  // Subtle hairline corner brackets on hero
  const arm = 14, off = 14;
  const line = '1px solid rgba(255,255,255,0.45)';
  const c = (style) => <span style={{ position: 'absolute', width: arm, height: arm, ...style }}/>;
  return (
    <>
      {c({ top: off, left: off,  borderTop: line, borderLeft: line })}
      {c({ top: off, right: off, borderTop: line, borderRight: line })}
      {c({ bottom: off, left: off,  borderBottom: line, borderLeft: line })}
      {c({ bottom: off, right: off, borderBottom: line, borderRight: line })}
    </>
  );
}

function StatCell({ label, count, risk, middle }) {
  const r = RISK[risk];
  return (
    <div style={{
      padding: '20px 12px 18px', textAlign: 'left',
      borderLeft: middle ? `1px solid ${C.hairlineSoft}` : 'none',
      borderRight: middle ? `1px solid ${C.hairlineSoft}` : 'none',
      position: 'relative', minHeight: 110,
    }}>
      <div style={{
        fontFamily: FONT_SERIF, fontWeight: 300, fontSize: 44,
        color: r.dot, lineHeight: 1, letterSpacing: -1,
      }}>{count}</div>
      <div style={{ marginTop: 12 }}>
        <span style={{ display: 'inline-block', width: 5, height: 5, borderRadius: 99, background: r.dot, marginRight: 6, verticalAlign: 'middle' }}/>
        <Eyebrow size={9} tracking={0.18} color={C.inkSoft} style={{ display: 'inline-block', verticalAlign: 'middle' }}>{label}</Eyebrow>
      </div>
    </div>
  );
}

function QuickAction({ icon, label, sub, onClick, topBorder, rightBorder }) {
  return (
    <button onClick={onClick} style={{
      ...btnReset, display: 'flex', flexDirection: 'column', alignItems: 'flex-start',
      gap: 14, padding: '18px 16px 18px',
      textAlign: 'left',
      borderTop: topBorder ? `1px solid ${C.hairlineSoft}` : 'none',
      borderRight: rightBorder ? 'none' : `1px solid ${C.hairlineSoft}`,
      minHeight: 112,
    }}>
      <span style={{ color: C.tealDark }}>{icon}</span>
      <div>
        <div style={{
          fontFamily: FONT_SERIF, fontSize: 16, fontWeight: 400, color: C.ink,
          lineHeight: 1.2, letterSpacing: -0.1,
        }}>{label}</div>
        <div style={{
          fontFamily: FONT_SANS, fontSize: 10, color: C.grey,
          letterSpacing: '.06em', marginTop: 4,
        }}>{sub}</div>
      </div>
    </button>
  );
}

function BeachListRow({ beach, onClick, first }) {
  const r = RISK[beach.risk];
  return (
    <button onClick={onClick} style={{
      ...btnReset, display: 'flex', alignItems: 'center', gap: 16,
      padding: '14px 0',
      borderTop: first ? `1px solid ${C.hairline}` : `1px solid ${C.hairlineSoft}`,
      textAlign: 'left', width: '100%',
    }}>
      <div style={{ position: 'relative', width: 64, height: 80, flexShrink: 0, overflow: 'hidden' }}>
        <img src={beach.photo} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}/>
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to top, rgba(26,46,44,0.4), transparent 60%)' }}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <Eyebrow size={9} tracking={0.24} style={{ marginBottom: 4 }}>{beach.city}</Eyebrow>
        <div style={{
          fontFamily: FONT_SERIF, fontSize: 19, fontWeight: 400, color: C.ink,
          lineHeight: 1.15, letterSpacing: -0.2,
        }}>{beach.name}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 8 }}>
          <StarGauge severity={RISK[beach.risk].severity} color={r.dot}/>
          <span style={{ fontFamily: FONT_SERIF, fontStyle: 'italic', fontSize: 12, color: C.inkSoft }}>
            {beach.erosion}
          </span>
        </div>
      </div>
      <span style={{ color: C.tealDark, fontSize: 18, fontWeight: 300 }}>→</span>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// 2. CARTE (Map)
// ─────────────────────────────────────────────────────────────
function MapScreen({ onOpenBeach }) {
  const [selected, setSelected] = useState('skanes');
  const sel = BEACHES.find(b => b.id === selected);
  return (
    <div data-screen-label="02 Carte" style={{ height: '100%', position: 'relative', background: C.sand, display: 'flex', flexDirection: 'column' }}>
      {/* Editorial header on sand */}
      <div style={{ background: C.sand, paddingTop: 56, padding: '56px 22px 18px', borderBottom: `1px solid ${C.hairlineSoft}` }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <IconBtn><IconMenu size={22}/></IconBtn>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <CostalinaMark size={22}/>
            <Eyebrow size={11} tracking={0.32}>Cartographie</Eyebrow>
          </div>
          <IconBtn><IconFilter size={20}/></IconBtn>
        </div>
        <div style={{ marginTop: 16 }}>
          <SerifTitle size={26}>
            Trait de côte<br/><em style={{ color: C.tealDark, fontStyle: 'italic' }}>tunisien</em>
          </SerifTitle>
        </div>
        {/* Search */}
        <div style={{ marginTop: 16, display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{
            flex: 1, background: C.white, padding: '10px 14px',
            display: 'flex', alignItems: 'center', gap: 10,
            border: `1px solid ${C.hairline}`,
          }}>
            <IconSearch size={16} style={{ color: C.grey }}/>
            <input placeholder="Rechercher une plage…" style={{
              flex: 1, border: 'none', outline: 'none', background: 'transparent',
              fontSize: 13, color: C.ink, fontFamily: FONT_SANS, letterSpacing: 0.05,
            }}/>
          </div>
          <button style={{
            ...btnReset, width: 42, height: 42, background: C.white,
            border: `1px solid ${C.hairline}`, color: C.tealDark,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><IconLocate size={18}/></button>
        </div>
      </div>

      {/* Map */}
      <div style={{ position: 'relative', flex: 1, minHeight: 460, overflow: 'hidden' }}>
        <SatelliteMap/>
        {BEACHES.map(b => (
          <BeachPin key={b.id} beach={b} active={b.id === selected} onClick={() => setSelected(b.id)}/>
        ))}
        <MapLabel x={30} y={20} size={13}>Sayada</MapLabel>
        <MapLabel x={30} y={55} size={14}>Monastir</MapLabel>
        <MapLabel x={80} y={38} size={12} italic>Golfe de<br/>Monastir</MapLabel>

        {sel && <MapInfoCard beach={sel} onOpen={() => onOpenBeach(sel.id)}/>}

        <div style={{ position: 'absolute', right: 16, bottom: 92 }}>
          <button style={{
            ...btnReset, width: 42, height: 42, background: C.white,
            border: `1px solid ${C.hairline}`, color: C.tealDark,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}><IconLocate size={20}/></button>
        </div>

        {/* Editorial legend strip */}
        <div style={{
          position: 'absolute', left: 16, right: 16, bottom: 56,
          background: C.white, padding: '11px 16px',
          display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 8,
          border: `1px solid ${C.hairline}`,
        }}>
          <LegendDot color={RISK.stable.dot} label="Stable"/>
          <HairLine vertical length={14} color={C.hairlineSoft}/>
          <LegendDot color={RISK.modere.dot} label="Modéré"/>
          <HairLine vertical length={14} color={C.hairlineSoft}/>
          <LegendDot color={RISK.eleve.dot}  label="Élevé"/>
        </div>
      </div>
    </div>
  );
}

function SatelliteMap() {
  // Refined SVG of Monastir coast — desaturated, editorial palette
  return (
    <div style={{ position: 'absolute', inset: 0, background: '#234b56' }}>
      <svg viewBox="0 0 400 600" preserveAspectRatio="xMidYMid slice" style={{ width: '100%', height: '100%', display: 'block' }}>
        <defs>
          <linearGradient id="sea" x1="0" x2="1" y1="0" y2="1">
            <stop offset="0%"  stopColor="#2c5e6a"/>
            <stop offset="100%" stopColor="#173842"/>
          </linearGradient>
          <linearGradient id="land" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%"  stopColor="#c8b48f"/>
            <stop offset="60%" stopColor="#b09f7b"/>
            <stop offset="100%" stopColor="#8d7f63"/>
          </linearGradient>
          <pattern id="grid" width="16" height="16" patternUnits="userSpaceOnUse">
            <path d="M0 16h16M16 0v16" stroke="rgba(0,0,0,0.10)" strokeWidth="0.5" fill="none"/>
          </pattern>
        </defs>
        <rect width="400" height="600" fill="url(#sea)"/>
        <path d="M0,0 L260,0 C220,80 180,120 200,200 C220,260 180,320 220,400 C240,460 200,540 240,600 L0,600 Z" fill="url(#land)"/>
        <path d="M0,0 L260,0 C220,80 180,120 200,200 C220,260 180,320 220,400 C240,460 200,540 240,600 L0,600 Z" fill="url(#grid)" opacity="0.5"/>
        <path d="M260,0 C220,80 180,120 200,200 C220,260 180,320 220,400 C240,460 200,540 240,600"
          stroke="#ede0c0" strokeWidth="5" fill="none" opacity="0.85"/>
        <g stroke="rgba(255,255,255,0.08)" fill="none" strokeWidth="1">
          <path d="M270 60 q40 -10 80 0"/>
          <path d="M260 160 q40 -10 80 0"/>
          <path d="M280 280 q40 -10 80 0"/>
          <path d="M260 380 q40 -10 80 0"/>
          <path d="M290 480 q40 -10 80 0"/>
        </g>
        <ellipse cx="340" cy="350" rx="18" ry="10" fill="#9c8b6b" opacity="0.8"/>
      </svg>
    </div>
  );
}

function BeachPin({ beach, active, onClick }) {
  const color = RISK[beach.risk].dot;
  const size = active ? 12 : 8;
  return (
    <button onClick={onClick} style={{
      ...btnReset, position: 'absolute', left: `${beach.x}%`, top: `${beach.y}%`,
      transform: 'translate(-50%,-50%)', cursor: 'pointer',
    }}>
      <div style={{
        width: size, height: size, background: color,
        clipPath: STAR_CLIP,
        filter: `drop-shadow(0 0 ${active ? 8 : 3}px rgba(0,0,0,0.5))`,
        transition: 'all 160ms ease',
      }}/>
      {active && (
        <span style={{
          position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%,-50%)',
          width: 28, height: 28, border: `1px solid ${color}`, borderRadius: 999,
          opacity: 0.6, pointerEvents: 'none',
        }}/>
      )}
    </button>
  );
}

function MapLabel({ x, y, size = 14, italic, children }) {
  return (
    <div style={{
      position: 'absolute', left: `${x}%`, top: `${y}%`, transform: 'translate(-50%,-50%)',
      color: '#fff', fontSize: size,
      fontFamily: italic ? FONT_SERIF : FONT_SANS,
      fontWeight: italic ? 400 : 300,
      letterSpacing: italic ? 0 : '.22em',
      textTransform: italic ? 'none' : 'uppercase',
      fontStyle: italic ? 'italic' : 'normal',
      textShadow: '0 1px 4px rgba(0,0,0,0.7)', pointerEvents: 'none', textAlign: 'center',
      lineHeight: 1.2,
    }}>{children}</div>
  );
}

function MapInfoCard({ beach, onOpen }) {
  const cardLeft = Math.min(Math.max(beach.x - 28, 4), 56);
  return (
    <div style={{
      position: 'absolute', left: `${cardLeft}%`, top: `calc(${beach.y}% - 130px)`,
      background: C.white, padding: '14px 16px 14px',
      width: 240, border: `1px solid ${C.hairline}`,
      boxShadow: '0 14px 36px -10px rgba(26,46,44,0.35)',
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8 }}>
        <div style={{ minWidth: 0 }}>
          <Eyebrow size={9} tracking={0.28} style={{ marginBottom: 4 }}>{beach.city}</Eyebrow>
          <div style={{ fontFamily: FONT_SERIF, fontSize: 18, fontWeight: 400, color: C.ink, lineHeight: 1.15, letterSpacing: -0.1 }}>{beach.name}</div>
        </div>
        <button onClick={onOpen} style={{ ...btnReset, color: C.tealDark, fontSize: 18, fontWeight: 300, lineHeight: 1 }}>→</button>
      </div>
      <div style={{ marginTop: 10, display: 'flex', alignItems: 'center', gap: 8 }}>
        <StarGauge severity={RISK[beach.risk].severity} color={RISK[beach.risk].dot} size={7}/>
        <span style={{ fontFamily: FONT_SERIF, fontStyle: 'italic', fontSize: 12, color: C.inkSoft }}>{RISK[beach.risk].label}</span>
      </div>
      <HairLine color={C.hairlineSoft} style={{ margin: '10px 0 8px', width: '100%' }}/>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Eyebrow size={8} tracking={0.24} color={C.grey}>Maj · {beach.lastUpdate}</Eyebrow>
        <span style={{ fontFamily: FONT_SERIF, fontStyle: 'italic', fontSize: 12, color: C.red.ink }}>{beach.erosion}</span>
      </div>
      <div style={{
        position: 'absolute', left: `${(beach.x - cardLeft) / 60 * 100}%`,
        bottom: -8, transform: 'translateX(-50%)',
        width: 14, height: 8, background: C.white, clipPath: 'polygon(50% 100%, 0 0, 100% 0)',
      }}/>
    </div>
  );
}

function LegendDot({ color, label }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
      <span style={{ width: 6, height: 6, background: color, clipPath: STAR_CLIP }}/>
      <Eyebrow size={9} tracking={0.2} color={C.ink}>{label}</Eyebrow>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 3. DÉTAILS DE LA PLAGE
// ─────────────────────────────────────────────────────────────
function DetailScreen({ beachId, onBack }) {
  const beach = BEACHES.find(b => b.id === beachId) || BEACHES[0];
  const r = RISK[beach.risk];
  const [tab, setTab] = useState('apercu');

  return (
    <div data-screen-label="03 Détail" style={{ background: C.sand }}>
      {/* Hero photo with overlay */}
      <div style={{ position: 'relative', height: 360, overflow: 'hidden', background: C.ink }}>
        <img src={beach.photo} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}/>
        <div style={{
          position: 'absolute', inset: 0,
          background: 'linear-gradient(to top, rgba(26,46,44,0.92) 0%, rgba(26,46,44,0.15) 40%, rgba(26,46,44,0.45) 100%)',
        }}/>

        {/* Top bar overlaying */}
        <div style={{
          position: 'absolute', top: 0, left: 0, right: 0,
          paddingTop: 56, padding: '56px 18px 0',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <IconBtn light onClick={onBack}><IconBack size={22}/></IconBtn>
          <Eyebrow color="rgba(255,255,255,0.85)" size={10} tracking={0.32}>Fiche plage</Eyebrow>
          <IconBtn light><IconShare size={20}/></IconBtn>
        </div>

        <CornerOrnament/>

        {/* Bottom overlay copy */}
        <div style={{ position: 'absolute', left: 22, right: 22, bottom: 22 }}>
          <Eyebrow color="rgba(168,221,216,0.95)" size={10} tracking={0.35} style={{ marginBottom: 8 }}>
            {beach.city} · Mise à jour {beach.lastUpdate}
          </Eyebrow>
          <SerifTitle size={32} color="#fff" style={{ lineHeight: 1.05 }}>
            {beach.name}
          </SerifTitle>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginTop: 14 }}>
            <RiskTag risk={beach.risk} light/>
            <StarGauge severity={r.severity} color="#fff" size={7}/>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)',
        background: C.sand,
        borderBottom: `1px solid ${C.hairline}`,
      }}>
        <TabBtn label="Aperçu"       active={tab==='apercu'}    onClick={() => setTab('apercu')}/>
        <TabBtn label="Évolution"    active={tab==='evolution'} onClick={() => setTab('evolution')}/>
        <TabBtn label="Signalements" active={tab==='signal'}    onClick={() => setTab('signal')}/>
        <TabBtn label="Infos"        active={tab==='infos'}     onClick={() => setTab('infos')}/>
      </div>

      {/* Tab content */}
      <div style={{ padding: '26px 22px 30px', background: C.sand }}>
        {tab === 'apercu'    && <ApercuTab beach={beach}/>}
        {tab === 'evolution' && <EvolutionTab beach={beach}/>}
        {tab === 'signal'    && <SignalementsTab/>}
        {tab === 'infos'     && <InfosTab beach={beach}/>}
      </div>
    </div>
  );
}

function TabBtn({ label, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      ...btnReset, padding: '14px 4px 12px',
      color: active ? C.tealDark : C.grey,
      borderBottom: active ? `2px solid ${C.tealDark}` : '2px solid transparent',
      marginBottom: -1, transition: 'color 140ms ease',
      fontFamily: FONT_SANS,
      fontSize: 10, fontWeight: 500, letterSpacing: '.22em', textTransform: 'uppercase',
    }}>{label}</button>
  );
}

function ApercuTab({ beach }) {
  const r = RISK[beach.risk];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 30 }}>
      {/* Évolution comparative */}
      <div>
        <SectionHead kicker="Trait de côte" title="Avant /" italic="après" right={<GhostLink>Voir plus</GhostLink>}/>
        <div style={{ position: 'relative', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <ComparePhoto src={beach.photo} year="Mai 2023"/>
          <ComparePhoto src={beach.photo} year="Mai 2024" desat/>
        </div>

        {/* Recul estimé — editorial card */}
        <div style={{
          marginTop: 16, background: C.white, padding: '20px 22px',
          border: `1px solid ${C.hairline}`,
          display: 'flex', alignItems: 'center', gap: 18,
        }}>
          <div>
            <Eyebrow size={9} tracking={0.32} style={{ marginBottom: 8 }}>Recul estimé</Eyebrow>
            <div style={{
              fontFamily: FONT_SERIF, fontWeight: 300, fontSize: 38,
              color: C.red.ink, lineHeight: 1, letterSpacing: -1,
            }}>{beach.erosion}</div>
            <div style={{ fontFamily: FONT_SERIF, fontStyle: 'italic', fontSize: 13, color: C.inkSoft, marginTop: 6 }}>
              {beach.period}
            </div>
          </div>
          <HairLine vertical length={70} color={C.hairlineSoft} style={{ marginLeft: 'auto' }}/>
          <div style={{ width: 90 }}>
            <Eyebrow size={9} tracking={0.28} style={{ marginBottom: 8 }}>Sévérité</Eyebrow>
            <StarGauge severity={r.severity} color={r.dot} size={8}/>
            <div style={{ fontFamily: FONT_SERIF, fontStyle: 'italic', fontSize: 12, color: r.ink, marginTop: 8 }}>{r.label}</div>
          </div>
        </div>
      </div>

      {/* Signalement récent */}
      <div>
        <SectionHead kicker="Communauté" title="Signalements" italic="récents" right={<GhostLink>Voir tout</GhostLink>}/>
        <SignalementRow item={SIGNALEMENTS[0]}/>
      </div>
    </div>
  );
}

function ComparePhoto({ src, year, desat }) {
  return (
    <div style={{ position: 'relative', aspectRatio: '4 / 5', overflow: 'hidden', background: C.ink }}>
      <img src={src} alt="" style={{
        width: '100%', height: '100%', objectFit: 'cover', display: 'block',
        filter: desat ? 'saturate(0.45) contrast(1.05) brightness(0.92)' : 'saturate(0.92)',
      }}/>
      <div style={{
        position: 'absolute', left: 10, bottom: 10,
        padding: '4px 9px', background: 'rgba(245,240,232,0.92)',
      }}>
        <Eyebrow size={9} tracking={0.28} color={C.ink}>{year}</Eyebrow>
      </div>
    </div>
  );
}

function EvolutionTab({ beach }) {
  const points = [0, -0.3, -0.6, -1.1, -1.5, -2.0, -2.4, -2.6, -2.9, -3.0, -3.1, -3.2];
  const months = ['J','F','M','A','M','J','J','A','S','O','N','D'];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      <div>
        <SectionHead kicker="Sur 12 mois" title="Recul" italic="cumulé"/>
        <div style={{ background: C.white, border: `1px solid ${C.hairline}`, padding: '18px 14px 12px' }}>
          <Sparkline points={points} months={months}/>
        </div>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 0, border: `1px solid ${C.hairline}`, background: C.white }}>
        <KpiCell label="Total reculé" value={beach.erosion} tint={C.red.ink}/>
        <KpiCell label="Vitesse" value="0,27 m/mois" tint={C.amber.ink} divider/>
        <KpiCell label="Pire mois" value="Sept. 2025" tint={C.ink} topBorder/>
        <KpiCell label="Confiance" value="92 %" tint={C.green.ink} divider topBorder/>
      </div>
    </div>
  );
}

function Sparkline({ points, months }) {
  const w = 320, h = 130, pad = 18;
  const min = Math.min(...points), max = 0;
  const range = max - min || 1;
  const step = (w - pad * 2) / (points.length - 1);
  const xy = (v, i) => [pad + i * step, pad + (1 - (v - min) / range) * (h - pad * 2)];
  const path = points.map((v, i) => xy(v, i)).map(([x, y], i) => `${i?'L':'M'}${x.toFixed(1)} ${y.toFixed(1)}`).join(' ');
  const area = path + ` L ${pad + (points.length - 1) * step} ${h - pad} L ${pad} ${h - pad} Z`;
  const last = xy(points[points.length - 1], points.length - 1);
  return (
    <svg viewBox={`0 0 ${w} ${h + 20}`} style={{ width: '100%', height: 'auto', display: 'block' }}>
      <defs>
        <linearGradient id="spark" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%"  stopColor={C.teal} stopOpacity="0.28"/>
          <stop offset="100%" stopColor={C.teal} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <path d={area} fill="url(#spark)"/>
      <path d={path} fill="none" stroke={C.tealDark} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
      <circle cx={last[0]} cy={last[1]} r="3.5" fill={C.tealDark}/>
      <circle cx={last[0]} cy={last[1]} r="8" fill={C.tealDark} opacity="0.18"/>
      {months.map((m, i) => (
        <text key={i} x={pad + i * step} y={h + 14} textAnchor="middle"
          fontSize="9" fill={C.grey} fontFamily={FONT_SANS} letterSpacing="2">{m}</text>
      ))}
    </svg>
  );
}

function KpiCell({ label, value, tint, divider, topBorder }) {
  return (
    <div style={{
      padding: '16px 16px 16px',
      borderLeft: divider ? `1px solid ${C.hairlineSoft}` : 'none',
      borderTop:  topBorder ? `1px solid ${C.hairlineSoft}` : 'none',
    }}>
      <Eyebrow size={9} tracking={0.28} style={{ marginBottom: 8 }}>{label}</Eyebrow>
      <div style={{
        fontFamily: FONT_SERIF, fontWeight: 300, fontSize: 22, color: tint,
        letterSpacing: -0.3, lineHeight: 1,
      }}>{value}</div>
    </div>
  );
}

function SignalementsTab() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column' }}>
      {SIGNALEMENTS.map((s, i) => <SignalementRow key={s.id} item={s} first={i === 0}/>)}
    </div>
  );
}

function SignalementRow({ item, first = true }) {
  const sc = RISK[item.statusColor === 'green' ? 'stable' : item.statusColor === 'amber' ? 'modere' : 'eleve'];
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 14,
      padding: '14px 0',
      borderTop: first ? `1px solid ${C.hairline}` : `1px solid ${C.hairlineSoft}`,
      borderBottom: `1px solid ${C.hairlineSoft}`,
    }}>
      <div style={{ width: 56, height: 70, flexShrink: 0, overflow: 'hidden' }}>
        <img src={item.thumb} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <Eyebrow size={9} tracking={0.24} style={{ marginBottom: 4 }}>{item.when}</Eyebrow>
        <div style={{ fontFamily: FONT_SERIF, fontSize: 17, fontWeight: 400, color: C.ink, lineHeight: 1.15, letterSpacing: -0.1 }}>
          {item.type}
        </div>
      </div>
      <div style={{
        fontFamily: FONT_SANS, fontSize: 9, fontWeight: 500, color: sc.ink,
        letterSpacing: '.22em', textTransform: 'uppercase',
        padding: '4px 9px', border: `1px solid ${sc.dot}40`, background: sc.bg,
      }}>{item.status}</div>
    </div>
  );
}

function InfosTab({ beach }) {
  const rows = [
    ['Région',         beach.city],
    ['Longueur',       '2,4 km'],
    ['Type',           'Plage de sable'],
    ['Accès public',   'Oui'],
    ['Dernier relevé', beach.lastUpdate],
    ['Sources',        'Sentinel-2 · Terrain'],
  ];
  return (
    <div style={{ background: C.white, border: `1px solid ${C.hairline}` }}>
      {rows.map(([k, v], i) => (
        <div key={k} style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          padding: '14px 18px', gap: 16,
          borderTop: i ? `1px solid ${C.hairlineSoft}` : 'none',
        }}>
          <Eyebrow size={9} tracking={0.28} color={C.grey}>{k}</Eyebrow>
          <span style={{ fontFamily: FONT_SERIF, fontSize: 14, color: C.ink, textAlign: 'right' }}>{v}</span>
        </div>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 4. ALERTES
// ─────────────────────────────────────────────────────────────
function AlertesScreen() {
  return (
    <div data-screen-label="04 Alertes" style={{ background: C.sand, minHeight: '100%' }}>
      <TopBar right={
        <>
          <IconBtn><IconSettings size={20}/></IconBtn>
        </>
      }/>

      <div style={{ padding: '26px 22px 22px' }}>
        <Eyebrow style={{ marginBottom: 12 }}>5 nouvelles · 2 à traiter</Eyebrow>
        <SerifTitle size={34}>
          Alertes<br/><em style={{ color: C.tealDark, fontStyle: 'italic' }}>côtières</em>
        </SerifTitle>
      </div>

      <div style={{ padding: '0 22px 30px' }}>
        <div style={{ background: C.white, border: `1px solid ${C.hairline}` }}>
          {ALERTES.map((a, i) => <AlerteRow key={a.id} a={a} first={i === 0}/>)}
        </div>
      </div>
    </div>
  );
}

function AlerteRow({ a, first }) {
  const r = RISK[a.risk];
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-start', gap: 14,
      padding: '16px 18px',
      borderTop: first ? 'none' : `1px solid ${C.hairlineSoft}`,
    }}>
      <div style={{ width: 8, paddingTop: 6, flexShrink: 0 }}>
        <span style={{ display: 'block', width: 6, height: 6, background: r.dot, clipPath: STAR_CLIP }}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: 10 }}>
          <div style={{
            fontFamily: FONT_SERIF, fontSize: 17, fontWeight: 400, color: C.ink,
            letterSpacing: -0.1, lineHeight: 1.2,
          }}>{a.beach}</div>
          <Eyebrow size={9} tracking={0.18} color={C.grey} style={{ flexShrink: 0 }}>{a.time}</Eyebrow>
        </div>
        <p style={{
          margin: '6px 0 8px', fontFamily: FONT_SANS, fontWeight: 300,
          fontSize: 12.5, color: C.inkSoft, lineHeight: 1.6, letterSpacing: 0.05,
        }}>{a.msg}</p>
        <RiskTag risk={a.risk} size="sm"/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 5. PROFIL
// ─────────────────────────────────────────────────────────────
function ProfilScreen() {
  return (
    <div data-screen-label="05 Profil" style={{ background: C.sand, minHeight: '100%' }}>
      <TopBar
        left={<IconBtn><IconBack size={22}/></IconBtn>}
        right={<IconBtn><IconSettings size={20}/></IconBtn>}
      />

      {/* Editorial intro */}
      <div style={{ padding: '24px 22px 18px', textAlign: 'left' }}>
        <Eyebrow style={{ marginBottom: 12 }}>Bénévole · Monastir</Eyebrow>
        <SerifTitle size={34}>Yasmine <em style={{ color: C.tealDark, fontStyle: 'italic' }}>Taoufik</em></SerifTitle>
        <p style={{
          margin: '12px 0 0', fontFamily: FONT_SANS, fontWeight: 300,
          fontSize: 13, color: C.inkSoft, lineHeight: 1.7,
        }}>Inscrite depuis mars 2025 · Costalinienne active</p>
      </div>

      {/* Stats — editorial 3 col */}
      <div style={{ padding: '14px 22px 0' }}>
        <div style={{
          background: C.white, border: `1px solid ${C.hairline}`,
          display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)',
        }}>
          <ProfilStat label="Signalements" value="12"/>
          <ProfilStat label="Photos"        value="47" divider/>
          <ProfilStat label="Plages suivies" value="6"  divider/>
        </div>
      </div>

      {/* Menu list */}
      <div style={{ padding: '28px 22px 0' }}>
        <Eyebrow style={{ marginBottom: 14 }}>Mon espace</Eyebrow>
        <div style={{ background: C.white, border: `1px solid ${C.hairline}` }}>
          <ProfilRow icon={<IconBell size={18}/>}     label="Notifications"       hint="Activées"/>
          <ProfilRow icon={<IconMap size={18}/>}      label="Plages suivies"      hint="6"/>
          <ProfilRow icon={<IconCap size={18}/>}      label="Centre d'apprentissage"/>
          <ProfilRow icon={<IconInfo size={18}/>}     label="À propos de Costalina"/>
          <ProfilRow icon={<IconSettings size={18}/>} label="Paramètres" last/>
        </div>
      </div>

      {/* Editorial footer with full logo */}
      <div style={{ padding: '40px 22px 80px', textAlign: 'center' }}>
        <div style={{ display: 'inline-flex', flexDirection: 'column', alignItems: 'center', gap: 14 }}>
          <CostalinaMark size={56}/>
          <span style={{
            fontFamily: FONT_SANS, fontWeight: 300, fontSize: 14,
            letterSpacing: '.48em', textTransform: 'uppercase', color: C.tealDark,
            paddingLeft: '.48em', // optical balance for tracked text
          }}>Costalina</span>
        </div>
        <div style={{
          marginTop: 14, fontFamily: FONT_SANS, fontWeight: 300, fontSize: 9,
          letterSpacing: '.32em', textTransform: 'uppercase', color: C.grey,
        }}>v 2.4 · Littoral tunisien · 2026</div>
      </div>
    </div>
  );
}

function ProfilStat({ label, value, divider }) {
  return (
    <div style={{
      textAlign: 'center', padding: '18px 8px 16px',
      borderLeft: divider ? `1px solid ${C.hairlineSoft}` : 'none',
    }}>
      <div style={{
        fontFamily: FONT_SERIF, fontWeight: 300, fontSize: 30, color: C.tealDark,
        lineHeight: 1, letterSpacing: -0.5,
      }}>{value}</div>
      <Eyebrow size={9} tracking={0.2} color={C.grey} style={{ marginTop: 8 }}>{label}</Eyebrow>
    </div>
  );
}

function ProfilRow({ icon, label, hint, last }) {
  return (
    <button style={{
      ...btnReset, display: 'flex', alignItems: 'center', gap: 14, width: '100%',
      padding: '15px 18px',
      borderBottom: last ? 'none' : `1px solid ${C.hairlineSoft}`,
      textAlign: 'left',
    }}>
      <span style={{ color: C.tealDark, flexShrink: 0 }}>{icon}</span>
      <div style={{ flex: 1, fontFamily: FONT_SERIF, fontSize: 16, color: C.ink, fontWeight: 400, letterSpacing: -0.1 }}>{label}</div>
      {hint && <Eyebrow size={9} tracking={0.2} color={C.grey}>{hint}</Eyebrow>}
      <span style={{ color: C.tealDark, fontSize: 14, fontWeight: 300 }}>→</span>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// Bottom navigation — refined, with center "Contribuer" button
// ─────────────────────────────────────────────────────────────
function BottomNav({ active, onChange, onPlus }) {
  const tabs = [
    { id: 'home',    label: 'Accueil', icon: IconHome },
    { id: 'map',     label: 'Carte',   icon: IconMap },
    { id: '__fab' },
    { id: 'alerts',  label: 'Alertes', icon: IconBell },
    { id: 'profile', label: 'Profil',  icon: IconPerson },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      height: 86,
      paddingBottom: 22,
      background: C.sand,
      borderTop: `1px solid ${C.hairline}`,
    }}>
      {/* Center action — refined teal square with Costalina mark */}
      <button onClick={onPlus} style={{
        ...btnReset,
        position: 'absolute', left: '50%', top: -16, transform: 'translateX(-50%)',
        width: 52, height: 52,
        background: C.tealDark, color: '#fff',
        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        gap: 1,
        boxShadow: '0 8px 18px -8px rgba(29,80,75,0.6)',
        border: `3px solid ${C.sand}`,
      }}>
        <CostalinaMark color="#fff" size={22}/>
        <span style={{
          fontFamily: FONT_SANS, fontSize: 7, fontWeight: 500,
          letterSpacing: '.18em', textTransform: 'uppercase',
        }}>Ajouter</span>
      </button>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr 1fr', padding: '12px 6px 0', height: '100%' }}>
        {tabs.map(t => {
          if (t.id === '__fab') return <div key="fab"/>;
          const I = t.icon;
          const isActive = active === t.id;
          return (
            <button key={t.id} onClick={() => onChange(t.id)} style={{
              ...btnReset, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
              padding: '4px 4px', color: isActive ? C.tealDark : C.grey,
            }}>
              <I size={20}/>
              <span style={{
                fontFamily: FONT_SANS, fontSize: 9,
                fontWeight: isActive ? 500 : 400,
                letterSpacing: '.18em', textTransform: 'uppercase',
              }}>{t.label}</span>
              {isActive && <HairLine length={14} color={C.tealDark} style={{ marginTop: -2 }}/>}
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Action sheet
// ─────────────────────────────────────────────────────────────
function ActionSheet({ open, onClose }) {
  if (!open) return null;
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, background: 'rgba(26,46,44,0.55)',
      backdropFilter: 'blur(6px)',
      zIndex: 80,
      display: 'flex', alignItems: 'flex-end',
      animation: 'cwFade 180ms ease-out',
    }}>
      <div onClick={e => e.stopPropagation()} style={{
        background: C.sand, width: '100%',
        padding: '22px 22px 32px',
        animation: 'cwSlideUp 220ms cubic-bezier(.2,.8,.2,1)',
        borderTop: `1px solid ${C.hairline}`,
      }}>
        <div style={{ width: 36, height: 2, background: C.hairline, margin: '0 auto 18px' }}/>
        <Eyebrow style={{ marginBottom: 8 }}>Contribuer</Eyebrow>
        <SerifTitle size={24} style={{ marginBottom: 18 }}>
          Nouvelle <em style={{ color: C.tealDark, fontStyle: 'italic' }}>observation</em>
        </SerifTitle>
        <div style={{ background: C.white, border: `1px solid ${C.hairline}` }}>
          <SheetAction icon={<IconCamera size={20}/>} title="Ajouter une photo"      sub="Capturez l'état actuel de la plage"/>
          <SheetAction icon={<IconAlert size={20}/>}  title="Signaler un problème"   sub="Érosion, pollution, construction…"/>
          <SheetAction icon={<IconRuler size={20}/>}  title="Relevé terrain"         sub="Mesure manuelle du trait de côte" last/>
        </div>
      </div>
    </div>
  );
}

function SheetAction({ icon, title, sub, last }) {
  return (
    <button style={{
      ...btnReset, display: 'flex', alignItems: 'center', gap: 16, width: '100%',
      padding: '16px 18px',
      borderBottom: last ? 'none' : `1px solid ${C.hairlineSoft}`,
      textAlign: 'left',
    }}>
      <span style={{ color: C.tealDark, flexShrink: 0 }}>{icon}</span>
      <div style={{ flex: 1 }}>
        <div style={{ fontFamily: FONT_SERIF, fontSize: 17, fontWeight: 400, color: C.ink, letterSpacing: -0.1 }}>{title}</div>
        <div style={{ fontFamily: FONT_SANS, fontSize: 11, color: C.grey, marginTop: 3, letterSpacing: 0.04 }}>{sub}</div>
      </div>
      <span style={{ color: C.tealDark, fontSize: 16, fontWeight: 300 }}>→</span>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// App shell
// ─────────────────────────────────────────────────────────────
function CostalinaApp() {
  const [tab, setTab] = useState('home');
  const [detail, setDetail] = useState(null);
  const [sheet, setSheet] = useState(false);

  const openBeach = (id) => setDetail(id);
  const closeBeach = () => setDetail(null);
  const switchTab = (t) => { setDetail(null); setTab(t); };

  const showNav = !detail;
  const NAV_H = 86;

  return (
    <div style={{ position: 'relative', height: '100%', background: C.sand, overflow: 'hidden' }}>
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0,
        bottom: showNav ? NAV_H : 0,
        overflowY: 'auto',
      }}>
        {detail ? (
          <DetailScreen beachId={detail} onBack={closeBeach}/>
        ) : (
          <>
            {tab === 'home'    && <HomeScreen onOpenBeach={openBeach} onTab={switchTab}/>}
            {tab === 'map'     && <MapScreen  onOpenBeach={openBeach}/>}
            {tab === 'alerts'  && <AlertesScreen/>}
            {tab === 'profile' && <ProfilScreen/>}
          </>
        )}
      </div>
      {showNav && <BottomNav active={tab} onChange={switchTab} onPlus={() => setSheet(true)}/>}
      <ActionSheet open={sheet} onClose={() => setSheet(false)}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Utils
// ─────────────────────────────────────────────────────────────
const btnReset = {
  background: 'none', border: 'none', padding: 0, margin: 0,
  cursor: 'pointer', fontFamily: 'inherit', color: 'inherit',
};
function hexToRgb(hex) {
  const h = hex.replace('#','');
  const r = parseInt(h.slice(0,2), 16), g = parseInt(h.slice(2,4), 16), b = parseInt(h.slice(4,6), 16);
  return `${r},${g},${b}`;
}

Object.assign(window, { CostalinaApp, CostalinaMark });
