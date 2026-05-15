// Coastwatch — all screens + app shell.
// Five screens: Accueil (home), Carte (map), Détails de la plage, Alertes, Profil.

const { useState, useEffect, useRef } = React;

// ─────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────
const C = {
  teal: '#0F6E7B',
  tealDark: '#0B5660',
  tealSoft: '#E3F0F2',
  ink: '#0E1B22',
  ink70: '#4B5963',
  ink50: '#7C8893',
  ink20: '#D8DEE2',
  bg: '#FFFFFF',
  bgSoft: '#F5F7F8',
  line: '#ECEEF0',
  // Risk semantics
  green:  { bg: '#E4F4E7', ink: '#1F7A37', dot: '#34A853' },
  amber:  { bg: '#FFF1DB', ink: '#A96A0B', dot: '#F0A12B' },
  red:    { bg: '#FCE2E2', ink: '#B23838', dot: '#E55353' },
};
const RISK = {
  stable:  { label: 'Stable',        ...C.green },
  modere:  { label: 'Risque modéré', ...C.amber },
  eleve:   { label: 'Risque élevé',  ...C.red },
};

// ─────────────────────────────────────────────────────────────
// Mock data (would come from API in production)
// ─────────────────────────────────────────────────────────────
const BEACHES = [
  { id: 'sayada',    name: 'Plage de Sayada',     city: 'Monastir',   risk: 'eleve',  x: 58, y: 18, lastUpdate: '21/05/2024',
    photo: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?w=900&q=80&auto=format&fit=crop',
    erosion: '- 5.8 m', period: 'Sur les 12 derniers mois' },
  { id: 'skanes',    name: 'Plage de Skanes',     city: 'Monastir',   risk: 'modere', x: 60, y: 32, lastUpdate: '20/05/2024',
    photo: 'https://images.unsplash.com/photo-1473625247510-8ceb1760943f?w=900&q=80&auto=format&fit=crop',
    erosion: '- 3.2 m', period: 'Sur les 12 derniers mois' },
  { id: 'sousse',    name: 'Plage de Sousse',     city: 'Sousse',     risk: 'stable', x: 62, y: 46, lastUpdate: '19/05/2024',
    photo: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=80&auto=format&fit=crop',
    erosion: '- 0.4 m', period: 'Sur les 12 derniers mois' },
  { id: 'teboulba',  name: 'Plage de Teboulba',   city: 'Monastir',   risk: 'stable', x: 60, y: 60, lastUpdate: '18/05/2024',
    photo: 'https://images.unsplash.com/photo-1502311526760-7bdf6c2e8e75?w=900&q=80&auto=format&fit=crop',
    erosion: '- 0.7 m', period: 'Sur les 12 derniers mois' },
  { id: 'bekalta',   name: 'Plage de Bekalta',    city: 'Monastir',   risk: 'modere', x: 62, y: 74, lastUpdate: '16/05/2024',
    photo: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=80&auto=format&fit=crop',
    erosion: '- 2.4 m', period: 'Sur les 12 derniers mois' },
  { id: 'kuriat',    name: 'Îles Kuriat',         city: 'Monastir',   risk: 'stable', x: 88, y: 56, lastUpdate: '17/05/2024',
    photo: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=80&auto=format&fit=crop',
    erosion: '- 0.1 m', period: 'Sur les 12 derniers mois' },
];

const SIGNALEMENTS = [
  { id: 1, type: 'Érosion',                    when: '18/05/2024 • 10:30', status: 'En cours',  statusColor: 'amber',
    thumb: 'https://images.unsplash.com/photo-1473625247510-8ceb1760943f?w=200&q=70&auto=format&fit=crop' },
  { id: 2, type: 'Pollution plastique',        when: '15/05/2024 • 16:12', status: 'Résolu',    statusColor: 'green',
    thumb: 'https://images.unsplash.com/photo-1502311526760-7bdf6c2e8e75?w=200&q=70&auto=format&fit=crop' },
  { id: 3, type: 'Construction non-déclarée',  when: '12/05/2024 • 09:05', status: 'En cours',  statusColor: 'amber',
    thumb: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=200&q=70&auto=format&fit=crop' },
];

const ALERTES = [
  { id: 1, beach: 'Plage de Sayada',  msg: 'Recul du trait de côte de 5,8 m détecté.',     time: 'Il y a 2 h',  risk: 'eleve'  },
  { id: 2, beach: 'Plage de Skanes',  msg: 'Nouveau signalement d\'érosion à vérifier.',   time: 'Il y a 5 h',  risk: 'modere' },
  { id: 3, beach: 'Plage de Bekalta', msg: 'Mise à jour satellite disponible.',            time: 'Hier',        risk: 'modere' },
  { id: 4, beach: 'Plage de Sousse',  msg: 'État stable confirmé par relevé terrain.',     time: 'Hier',        risk: 'stable' },
  { id: 5, beach: 'Îles Kuriat',      msg: 'Campagne de mesure planifiée le 25/05.',       time: '2 jours',     risk: 'stable' },
];

// ─────────────────────────────────────────────────────────────
// Shared atoms
// ─────────────────────────────────────────────────────────────
function RiskPill({ risk, size = 'md' }) {
  const r = RISK[risk];
  const padY = size === 'sm' ? 3 : 5;
  const padX = size === 'sm' ? 8 : 10;
  const fs = size === 'sm' ? 11 : 12;
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: `${padY}px ${padX}px`, borderRadius: 999,
      background: r.bg, color: r.ink, fontWeight: 600, fontSize: fs,
    }}>
      <span style={{ width: 7, height: 7, borderRadius: 99, background: r.dot }}/>
      {r.label}
    </div>
  );
}

function SectionTitle({ children, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 14 }}>
      <h2 style={{ margin: 0, fontSize: 17, fontWeight: 700, color: C.ink, letterSpacing: -0.2 }}>{children}</h2>
      {right && <button style={{
        background: 'none', border: 'none', color: C.teal, fontSize: 13, fontWeight: 600, cursor: 'pointer',
        fontFamily: 'inherit', padding: 0,
      }}>{right}</button>}
    </div>
  );
}

function CircleBtn({ children, onClick, light = false, size = 38 }) {
  return (
    <button onClick={onClick} style={{
      width: size, height: size, borderRadius: 999,
      background: light ? 'rgba(255,255,255,0.18)' : '#fff',
      backdropFilter: light ? 'blur(8px)' : 'none',
      border: light ? '1px solid rgba(255,255,255,0.25)' : `1px solid ${C.line}`,
      color: light ? '#fff' : C.ink,
      display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
      boxShadow: light ? 'none' : '0 1px 2px rgba(0,0,0,0.04)',
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
    <div data-screen-label="01 Accueil" style={{ paddingTop: 56 /* status bar */ }}>
      {/* App bar */}
      <div style={{ padding: '14px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button style={btnReset}><IconMenu size={26} style={{ color: C.ink }}/></button>
        <button style={btnReset}><IconBellDot size={24} style={{ color: C.ink }}/></button>
      </div>

      {/* Greeting */}
      <div style={{ padding: '18px 20px 22px' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
          <h1 style={{ margin: 0, fontSize: 30, fontWeight: 800, color: C.ink, letterSpacing: -0.7 }}>Bonjour !</h1>
          <span style={{ fontSize: 26, fontFamily: '"Apple Color Emoji","Segoe UI Emoji","Noto Color Emoji",sans-serif' }}>🌊</span>
        </div>
        <p style={{ margin: '6px 0 0', color: C.ink50, fontSize: 14 }}>Protégeons nos plages tunisiennes</p>
      </div>

      {/* Featured beach card */}
      <div style={{ padding: '0 20px' }}>
        <button onClick={() => onOpenBeach(featured.id)} style={{
          ...btnReset, width: '100%', display: 'block', textAlign: 'left',
          position: 'relative', borderRadius: 20, overflow: 'hidden',
          aspectRatio: '16 / 9',
          boxShadow: '0 8px 24px -10px rgba(11,86,96,0.35)',
        }}>
          <img src={featured.photo} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}/>
          <div style={{
            position: 'absolute', inset: 0,
            background: 'linear-gradient(to top, rgba(0,0,0,0.55) 0%, rgba(0,0,0,0.1) 45%, transparent 80%)',
          }}/>
          <div style={{ position: 'absolute', left: 20, bottom: 18, right: 130 }}>
            <div style={{ color: '#fff', fontSize: 26, fontWeight: 800, letterSpacing: -0.4, lineHeight: 1.1 }}>
              {featured.city}
            </div>
            <div style={{ color: 'rgba(255,255,255,0.9)', fontSize: 14, marginTop: 4 }}>
              {featured.name}
            </div>
          </div>
          <div style={{ position: 'absolute', right: 14, bottom: 14 }}>
            <RiskPill risk={featured.risk}/>
          </div>
        </button>
      </div>

      {/* État des plages */}
      <div style={{ padding: '28px 20px 0' }}>
        <SectionTitle right="Voir tout">État des plages</SectionTitle>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
          <StatusCard risk="stable" count={counts.stable}/>
          <StatusCard risk="modere" count={counts.modere}/>
          <StatusCard risk="eleve"  count={counts.eleve}/>
        </div>
      </div>

      {/* Actions rapides */}
      <div style={{ padding: '28px 20px 30px' }}>
        <SectionTitle>Actions rapides</SectionTitle>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10 }}>
          <QuickAction tint={C.teal}   icon={<IconCamera size={22}/>}    label="Ajouter une photo"/>
          <QuickAction tint="#C77A0D"  icon={<IconAlert size={22}/>}     label="Signaler un problème"/>
          <QuickAction tint="#1F7A37"  icon={<IconMap size={22}/>}       label="Voir la carte" onClick={() => onTab('map')}/>
          <QuickAction tint="#6B4DBA"  icon={<IconCap size={22}/>}       label="Apprendre"/>
        </div>
      </div>
    </div>
  );
}

function StatusCard({ risk, count }) {
  const r = RISK[risk];
  const labelMap = { stable: 'Plages stables', modere: 'Risque modéré', eleve: 'Risque élevé' };
  return (
    <div style={{
      background: r.bg, borderRadius: 16, padding: '14px 12px 12px', minHeight: 110,
      display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
    }}>
      <div>
        <div style={{ fontSize: 30, fontWeight: 800, color: r.ink, lineHeight: 1, letterSpacing: -0.5 }}>{count}</div>
        <div style={{ fontSize: 12, color: r.ink, marginTop: 6, fontWeight: 500 }}>{labelMap[risk]}</div>
      </div>
      <div style={{ alignSelf: 'flex-end', color: r.dot, opacity: 0.9 }}>
        <IconWave size={26}/>
      </div>
    </div>
  );
}

function QuickAction({ tint, icon, label, onClick }) {
  return (
    <button onClick={onClick} style={{
      ...btnReset, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
      padding: '12px 6px', borderRadius: 16, background: '#fff', border: `1px solid ${C.line}`,
    }}>
      <div style={{
        width: 46, height: 46, borderRadius: 14, background: hexA(tint, 0.12), color: tint,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{icon}</div>
      <div style={{ fontSize: 11, color: C.ink, textAlign: 'center', lineHeight: 1.25, fontWeight: 500, textWrap: 'pretty' }}>
        {label}
      </div>
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
    <div data-screen-label="02 Carte" style={{ height: '100%', position: 'relative', background: C.bgSoft, display: 'flex', flexDirection: 'column' }}>
      {/* Teal header */}
      <div style={{
        background: C.teal, color: '#fff', paddingTop: 56,
        padding: '56px 16px 18px',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 4 }}>
          <button style={btnReset}><IconMenu size={26} style={{ color: '#fff' }}/></button>
          <div style={{ fontSize: 17, fontWeight: 700, letterSpacing: -0.2 }}>Carte des plages</div>
          <button style={btnReset}><IconFilter size={22} style={{ color: '#fff' }}/></button>
        </div>
        {/* Search */}
        <div style={{ marginTop: 18, display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{
            flex: 1, background: '#fff', borderRadius: 14, padding: '11px 14px',
            display: 'flex', alignItems: 'center', gap: 10,
            boxShadow: '0 1px 4px rgba(0,0,0,0.06)',
          }}>
            <IconSearch size={18} style={{ color: C.ink50 }}/>
            <input placeholder="Rechercher une plage…" style={{
              flex: 1, border: 'none', outline: 'none', background: 'transparent',
              fontSize: 14, color: C.ink, fontFamily: 'inherit',
            }}/>
          </div>
          <CircleBtn size={44}><IconLocate size={20} style={{ color: C.teal }}/></CircleBtn>
        </div>
      </div>

      {/* Map */}
      <div style={{ position: 'relative', flex: 1, minHeight: 460, overflow: 'hidden' }}>
        <SatelliteMap/>
        {/* Pins */}
        {BEACHES.map(b => (
          <BeachPin key={b.id} beach={b} active={b.id === selected} onClick={() => setSelected(b.id)}/>
        ))}
        {/* City labels — kept off the active-pin column */}
        <MapLabel x={30} y={20} size={14}>Sayada</MapLabel>
        <MapLabel x={30} y={55} size={15}>Monastir</MapLabel>
        <MapLabel x={80} y={38} size={13} italic>Golfe de<br/>Monastir</MapLabel>

        {/* Info card */}
        {sel && <MapInfoCard beach={sel} onOpen={() => onOpenBeach(sel.id)}/>}

        {/* Locate FAB — moved well above legend & nav FAB */}
        <div style={{ position: 'absolute', right: 14, bottom: 92 }}>
          <CircleBtn size={46}><IconLocate size={22} style={{ color: C.teal }}/></CircleBtn>
        </div>

        {/* Legend — clear of the bottom-nav FAB which protrudes ~28px above nav top */}
        <div style={{
          position: 'absolute', left: 14, right: 14, bottom: 56,
          background: '#fff', borderRadius: 14, padding: '11px 14px',
          display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 6,
          boxShadow: '0 6px 22px -8px rgba(0,0,0,0.18)',
        }}>
          <LegendDot color={RISK.stable.dot} label="Stable"/>
          <LegendDot color={RISK.modere.dot} label="Modéré"/>
          <LegendDot color={RISK.eleve.dot}  label="Élevé"/>
        </div>
      </div>
    </div>
  );
}

function SatelliteMap() {
  // Layered SVG approximation of Monastir coastline — sea on the right, land on the left.
  return (
    <div style={{ position: 'absolute', inset: 0, background: '#1F5C73' }}>
      <svg viewBox="0 0 400 600" preserveAspectRatio="xMidYMid slice" style={{ width: '100%', height: '100%', display: 'block' }}>
        <defs>
          <linearGradient id="sea" x1="0" x2="1" y1="0" y2="1">
            <stop offset="0%"  stopColor="#1C5670"/>
            <stop offset="100%" stopColor="#0E3B52"/>
          </linearGradient>
          <linearGradient id="land" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%"  stopColor="#A89472"/>
            <stop offset="60%" stopColor="#8C7657"/>
            <stop offset="100%" stopColor="#7A6849"/>
          </linearGradient>
          <pattern id="grid" width="14" height="14" patternUnits="userSpaceOnUse">
            <path d="M0 14h14M14 0v14" stroke="rgba(0,0,0,0.12)" strokeWidth="0.6" fill="none"/>
          </pattern>
          <pattern id="dense" width="6" height="6" patternUnits="userSpaceOnUse">
            <rect width="3" height="3" fill="rgba(255,255,255,0.04)"/>
            <rect x="3" y="3" width="3" height="3" fill="rgba(0,0,0,0.05)"/>
          </pattern>
        </defs>
        {/* Sea base */}
        <rect width="400" height="600" fill="url(#sea)"/>
        {/* Land mass (Monastir peninsula) */}
        <path d="M0,0 L260,0 C220,80 180,120 200,200 C220,260 180,320 220,400 C240,460 200,540 240,600 L0,600 Z"
          fill="url(#land)"/>
        <path d="M0,0 L260,0 C220,80 180,120 200,200 C220,260 180,320 220,400 C240,460 200,540 240,600 L0,600 Z"
          fill="url(#grid)" opacity="0.55"/>
        <path d="M0,0 L260,0 C220,80 180,120 200,200 C220,260 180,320 220,400 C240,460 200,540 240,600 L0,600 Z"
          fill="url(#dense)"/>
        {/* Beach edge (light sandy strip) */}
        <path d="M260,0 C220,80 180,120 200,200 C220,260 180,320 220,400 C240,460 200,540 240,600"
          stroke="#E2D2A8" strokeWidth="6" fill="none" opacity="0.9"/>
        {/* Sea ripples */}
        <g stroke="rgba(255,255,255,0.08)" fill="none" strokeWidth="1">
          <path d="M270 60 q40 -10 80 0"/>
          <path d="M260 160 q40 -10 80 0"/>
          <path d="M280 280 q40 -10 80 0"/>
          <path d="M260 380 q40 -10 80 0"/>
          <path d="M290 480 q40 -10 80 0"/>
        </g>
        {/* Small offshore island */}
        <ellipse cx="340" cy="350" rx="18" ry="10" fill="#8C7657" opacity="0.8"/>
      </svg>
    </div>
  );
}

function BeachPin({ beach, active, onClick }) {
  const color = RISK[beach.risk].dot;
  const size = active ? 22 : 16;
  return (
    <button onClick={onClick} style={{
      ...btnReset, position: 'absolute', left: `${beach.x}%`, top: `${beach.y}%`,
      transform: 'translate(-50%,-50%)', cursor: 'pointer',
    }}>
      <div style={{
        width: size, height: size, borderRadius: 999, background: color,
        border: '3px solid #fff',
        boxShadow: `0 0 0 ${active ? 6 : 0}px ${hexA(color, 0.25)}, 0 2px 4px rgba(0,0,0,0.3)`,
        transition: 'all 160ms ease',
      }}/>
    </button>
  );
}

function MapLabel({ x, y, size = 14, italic, children }) {
  return (
    <div style={{
      position: 'absolute', left: `${x}%`, top: `${y}%`, transform: 'translate(-50%,-50%)',
      color: '#fff', fontSize: size, fontWeight: italic ? 500 : 700,
      fontStyle: italic ? 'italic' : 'normal',
      textShadow: '0 1px 4px rgba(0,0,0,0.6)', pointerEvents: 'none', textAlign: 'center',
      lineHeight: 1.15,
    }}>{children}</div>
  );
}

function MapInfoCard({ beach, onOpen }) {
  // Anchor above the active pin. Clamp to keep card on-screen.
  const cardW = 230;
  const cardLeft = Math.min(Math.max(beach.x - 18, 4), 96 - 50); // % of map
  return (
    <div style={{
      position: 'absolute', left: `${cardLeft}%`, top: `calc(${beach.y}% - 110px)`,
      background: '#fff', borderRadius: 14, padding: '12px 14px',
      width: cardW, boxShadow: '0 10px 30px -8px rgba(0,0,0,0.28)',
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 6 }}>
        <div style={{ minWidth: 0 }}>
          <div style={{ fontWeight: 700, color: C.ink, fontSize: 15, letterSpacing: -0.1 }}>{beach.name}</div>
          <div style={{ color: C.ink50, fontSize: 13, marginTop: 1 }}>{beach.city}</div>
        </div>
        <button onClick={onOpen} style={{ ...btnReset, color: C.teal }}><IconChevR size={20}/></button>
      </div>
      <div style={{ marginTop: 8 }}><RiskPill risk={beach.risk} size="sm"/></div>
      <div style={{ color: C.ink50, fontSize: 11, marginTop: 8 }}>Dernière mise à jour : {beach.lastUpdate}</div>
      {/* Anchor tail pointing down to the pin */}
      <div style={{
        position: 'absolute', left: `${(beach.x - cardLeft) / 50 * 100}%`,
        bottom: -8, transform: 'translateX(-50%)',
        width: 16, height: 9, background: '#fff', clipPath: 'polygon(50% 100%, 0 0, 100% 0)',
        filter: 'drop-shadow(0 2px 2px rgba(0,0,0,0.08))',
      }}/>
    </div>
  );
}

function LegendDot({ color, label }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
      <span style={{ width: 9, height: 9, borderRadius: 99, background: color }}/>
      <span style={{ fontSize: 12, color: C.ink, fontWeight: 500 }}>{label}</span>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 3. DÉTAILS DE LA PLAGE
// ─────────────────────────────────────────────────────────────
function DetailScreen({ beachId, onBack }) {
  const beach = BEACHES.find(b => b.id === beachId) || BEACHES[0];
  const [tab, setTab] = useState('apercu');

  return (
    <div data-screen-label="03 Détail" style={{ background: '#fff' }}>
      {/* Teal app bar — overlays photo */}
      <div style={{
        position: 'sticky', top: 0, zIndex: 5,
        background: C.teal, color: '#fff', paddingTop: 56, padding: '56px 16px 14px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <button onClick={onBack} style={btnReset}><IconBack size={24} style={{ color: '#fff' }}/></button>
        <div style={{ fontSize: 17, fontWeight: 700, letterSpacing: -0.2 }}>Détails de la plage</div>
        <button style={btnReset}><IconShare size={22} style={{ color: '#fff' }}/></button>
      </div>

      {/* Hero photo with overlay name */}
      <div style={{ position: 'relative', height: 200, overflow: 'hidden' }}>
        <img src={beach.photo} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}/>
        <div style={{
          position: 'absolute', inset: 0,
          background: 'linear-gradient(to bottom, transparent 30%, rgba(0,0,0,0.55) 100%)',
        }}/>
      </div>

      <div style={{ padding: '18px 20px 8px', display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
        <div>
          <h1 style={{ margin: 0, fontSize: 24, fontWeight: 800, color: C.ink, letterSpacing: -0.4 }}>{beach.name}</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginTop: 6, color: C.ink50, fontSize: 14 }}>
            <IconPin size={16}/> {beach.city}
          </div>
        </div>
        <div style={{ paddingTop: 6 }}><RiskPill risk={beach.risk}/></div>
      </div>

      {/* Tabs */}
      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)',
        borderBottom: `1px solid ${C.line}`, marginTop: 8,
      }}>
        <TabBtn icon={<IconOverview size={20}/>} label="Aperçu"       active={tab==='apercu'}    onClick={() => setTab('apercu')}/>
        <TabBtn icon={<IconTrend size={20}/>}    label="Évolution"    active={tab==='evolution'} onClick={() => setTab('evolution')}/>
        <TabBtn icon={<IconSend size={20}/>}     label="Signalements" active={tab==='signal'}    onClick={() => setTab('signal')}/>
        <TabBtn icon={<IconInfo size={20}/>}     label="Infos"        active={tab==='infos'}     onClick={() => setTab('infos')}/>
      </div>

      {/* Tab content */}
      <div style={{ padding: '22px 20px 30px' }}>
        {tab === 'apercu'    && <ApercuTab beach={beach}/>}
        {tab === 'evolution' && <EvolutionTab beach={beach}/>}
        {tab === 'signal'    && <SignalementsTab/>}
        {tab === 'infos'     && <InfosTab beach={beach}/>}
      </div>
    </div>
  );
}

function TabBtn({ icon, label, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      ...btnReset, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      padding: '12px 4px 14px', color: active ? C.teal : C.ink50,
      borderBottom: active ? `2.5px solid ${C.teal}` : '2.5px solid transparent',
      marginBottom: -1, transition: 'color 140ms ease',
    }}>
      {icon}
      <span style={{ fontSize: 12, fontWeight: active ? 700 : 500 }}>{label}</span>
    </button>
  );
}

function ApercuTab({ beach }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      {/* Évolution */}
      <div>
        <SectionTitle right="Voir plus">Évolution du trait de côte</SectionTitle>
        <div style={{ position: 'relative', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <ComparePhoto src={beach.photo} year="Mai 2023"/>
          <ComparePhoto src={beach.photo} year="Mai 2024" desat/>
          <div style={{
            position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%,-50%)',
            width: 36, height: 36, borderRadius: 999, background: '#fff', color: C.teal,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 4px 14px -2px rgba(0,0,0,0.25)',
          }}>
            <IconChevLR size={18}/>
          </div>
        </div>

        {/* Recul estimé */}
        <div style={{
          marginTop: 14, background: C.tealSoft, borderRadius: 16, padding: '14px 16px',
          display: 'flex', alignItems: 'center', gap: 14,
        }}>
          <div style={{
            width: 42, height: 42, borderRadius: 12, background: '#fff', color: C.teal,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <IconRuler size={22}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, color: C.ink70 }}>Recul estimé</div>
            <div style={{ fontSize: 22, fontWeight: 800, color: C.red.ink, letterSpacing: -0.3, lineHeight: 1.1, marginTop: 2 }}>
              {beach.erosion}
            </div>
            <div style={{ fontSize: 12, color: C.ink50, marginTop: 2 }}>{beach.period}</div>
          </div>
        </div>
      </div>

      {/* Signalements récents (preview) */}
      <div>
        <SectionTitle right="Voir tout">Signalements récents</SectionTitle>
        <SignalementRow item={SIGNALEMENTS[0]}/>
      </div>
    </div>
  );
}

function ComparePhoto({ src, year, desat }) {
  return (
    <div style={{ position: 'relative', aspectRatio: '4 / 3', borderRadius: 14, overflow: 'hidden', background: C.line }}>
      <img src={src} alt="" style={{
        width: '100%', height: '100%', objectFit: 'cover', display: 'block',
        filter: desat ? 'saturate(0.7) contrast(1.05)' : 'none',
      }}/>
      <div style={{
        position: 'absolute', left: 8, top: 8, padding: '4px 10px', borderRadius: 999,
        background: 'rgba(0,0,0,0.55)', backdropFilter: 'blur(6px)', color: '#fff',
        fontSize: 11, fontWeight: 600,
      }}>{year}</div>
    </div>
  );
}

function EvolutionTab({ beach }) {
  // Synthetic time-series sparkline (recul cumulé en mètres)
  const points = [0, -0.3, -0.6, -1.1, -1.5, -2.0, -2.4, -2.6, -2.9, -3.0, -3.1, -3.2];
  const months = ['J','F','M','A','M','J','J','A','S','O','N','D'];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
      <div>
        <SectionTitle>Recul cumulé · 12 mois</SectionTitle>
        <Sparkline points={points} months={months}/>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <KpiCard label="Total reculé"  value={beach.erosion} tint={C.red.ink}/>
        <KpiCard label="Vitesse"       value="0.27 m/mois"   tint={C.amber.ink}/>
        <KpiCard label="Pire mois"     value="Sept. 2023"    tint={C.ink}/>
        <KpiCard label="Confiance"     value="92 %"          tint={C.green.ink}/>
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
    <div style={{
      background: '#fff', border: `1px solid ${C.line}`, borderRadius: 16, padding: '14px 12px 10px',
    }}>
      <svg viewBox={`0 0 ${w} ${h + 20}`} style={{ width: '100%', height: 'auto', display: 'block' }}>
        <defs>
          <linearGradient id="spark" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%"  stopColor={C.teal} stopOpacity="0.25"/>
            <stop offset="100%" stopColor={C.teal} stopOpacity="0"/>
          </linearGradient>
        </defs>
        <path d={area} fill="url(#spark)"/>
        <path d={path} fill="none" stroke={C.teal} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        <circle cx={last[0]} cy={last[1]} r="4" fill={C.teal}/>
        <circle cx={last[0]} cy={last[1]} r="8" fill={C.teal} opacity="0.18"/>
        {months.map((m, i) => (
          <text key={i} x={pad + i * step} y={h + 14} textAnchor="middle" fontSize="10" fill={C.ink50}>{m}</text>
        ))}
      </svg>
    </div>
  );
}

function KpiCard({ label, value, tint }) {
  return (
    <div style={{ background: '#fff', border: `1px solid ${C.line}`, borderRadius: 14, padding: '12px 14px' }}>
      <div style={{ fontSize: 11, color: C.ink50, fontWeight: 500, textTransform: 'uppercase', letterSpacing: 0.5 }}>{label}</div>
      <div style={{ fontSize: 18, fontWeight: 800, color: tint, marginTop: 4, letterSpacing: -0.3 }}>{value}</div>
    </div>
  );
}

function SignalementsTab() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {SIGNALEMENTS.map(s => <SignalementRow key={s.id} item={s}/>)}
    </div>
  );
}

function SignalementRow({ item }) {
  const sc = RISK[item.statusColor === 'green' ? 'stable' : item.statusColor === 'amber' ? 'modere' : 'eleve'];
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: 10, borderRadius: 14, border: `1px solid ${C.line}`, background: '#fff',
    }}>
      <img src={item.thumb} alt="" style={{ width: 52, height: 52, borderRadius: 11, objectFit: 'cover', display: 'block' }}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: C.ink }}>{item.type}</div>
        <div style={{ fontSize: 12, color: C.ink50, marginTop: 2 }}>{item.when}</div>
      </div>
      <div style={{
        fontSize: 11, fontWeight: 600, color: sc.ink, background: sc.bg,
        padding: '4px 10px', borderRadius: 999,
      }}>{item.status}</div>
    </div>
  );
}

function InfosTab({ beach }) {
  const rows = [
    ['Région',          beach.city],
    ['Longueur',        '2.4 km'],
    ['Type',            'Plage de sable'],
    ['Accès public',    'Oui'],
    ['Dernier relevé',  beach.lastUpdate],
    ['Source données',  'Satellite Sentinel-2 + relevés terrain'],
  ];
  return (
    <div style={{ background: '#fff', border: `1px solid ${C.line}`, borderRadius: 16, overflow: 'hidden' }}>
      {rows.map(([k, v], i) => (
        <div key={k} style={{
          display: 'flex', justifyContent: 'space-between', padding: '14px 16px',
          borderTop: i ? `1px solid ${C.line}` : 'none', gap: 16,
        }}>
          <span style={{ color: C.ink50, fontSize: 13 }}>{k}</span>
          <span style={{ color: C.ink, fontSize: 13, fontWeight: 600, textAlign: 'right' }}>{v}</span>
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
    <div data-screen-label="04 Alertes" style={{ paddingTop: 56 }}>
      <div style={{ padding: '14px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button style={btnReset}><IconMenu size={26} style={{ color: C.ink }}/></button>
        <button style={btnReset}><IconSettings size={22} style={{ color: C.ink }}/></button>
      </div>
      <div style={{ padding: '18px 20px 18px' }}>
        <h1 style={{ margin: 0, fontSize: 28, fontWeight: 800, color: C.ink, letterSpacing: -0.6 }}>Alertes</h1>
        <p style={{ margin: '4px 0 0', color: C.ink50, fontSize: 14 }}>5 nouvelles · 2 nécessitent une action</p>
      </div>
      <div style={{ padding: '0 20px 30px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {ALERTES.map(a => <AlerteRow key={a.id} a={a}/>)}
      </div>
    </div>
  );
}

function AlerteRow({ a }) {
  const r = RISK[a.risk];
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-start', gap: 12,
      padding: '14px 14px', borderRadius: 16, background: '#fff', border: `1px solid ${C.line}`,
    }}>
      <div style={{
        width: 38, height: 38, borderRadius: 12, background: r.bg, color: r.ink,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>
        <IconAlert size={20}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: 8 }}>
          <div style={{ fontSize: 14, fontWeight: 700, color: C.ink, textWrap: 'pretty' }}>{a.beach}</div>
          <div style={{ fontSize: 11, color: C.ink50, flexShrink: 0 }}>{a.time}</div>
        </div>
        <div style={{ fontSize: 13, color: C.ink70, marginTop: 3, lineHeight: 1.4, textWrap: 'pretty' }}>{a.msg}</div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 5. PROFIL
// ─────────────────────────────────────────────────────────────
function ProfilScreen() {
  return (
    <div data-screen-label="05 Profil" style={{ paddingTop: 56, background: C.bgSoft, minHeight: '100%' }}>
      <div style={{ padding: '14px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button style={btnReset}><IconBack size={24} style={{ color: C.ink }}/></button>
        <div style={{ fontSize: 16, fontWeight: 700, color: C.ink }}>Mon profil</div>
        <button style={btnReset}><IconSettings size={22} style={{ color: C.ink }}/></button>
      </div>

      {/* Avatar block */}
      <div style={{ padding: '22px 20px 18px', textAlign: 'center' }}>
        <div style={{
          width: 92, height: 92, borderRadius: 999, margin: '0 auto',
          background: `linear-gradient(135deg, ${C.teal}, ${C.tealDark})`,
          color: '#fff', fontSize: 36, fontWeight: 700, display: 'flex',
          alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 8px 20px -8px rgba(11,86,96,0.45)',
        }}>YT</div>
        <div style={{ fontSize: 19, fontWeight: 700, color: C.ink, marginTop: 12 }}>Yasmine T.</div>
        <div style={{ fontSize: 13, color: C.ink50, marginTop: 2 }}>Bénévole · Monastir</div>
      </div>

      {/* Stats */}
      <div style={{ padding: '0 20px' }}>
        <div style={{
          background: '#fff', borderRadius: 16, border: `1px solid ${C.line}`,
          padding: '14px 4px', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)',
        }}>
          <ProfilStat label="Signalements" value="12"/>
          <ProfilStat label="Photos" value="47" divider/>
          <ProfilStat label="Plages suivies" value="6" divider/>
        </div>
      </div>

      {/* List */}
      <div style={{ padding: '20px 20px 30px' }}>
        <div style={{ background: '#fff', borderRadius: 16, border: `1px solid ${C.line}`, overflow: 'hidden' }}>
          <ProfilRow icon={<IconBell size={20}/>}      label="Notifications"           hint="Activées"/>
          <ProfilRow icon={<IconMap size={20}/>}       label="Mes plages suivies"      hint="6"/>
          <ProfilRow icon={<IconCap size={20}/>}       label="Centre d'apprentissage"/>
          <ProfilRow icon={<IconInfo size={20}/>}      label="À propos de Coastwatch"/>
          <ProfilRow icon={<IconSettings size={20}/>}  label="Paramètres" last/>
        </div>
      </div>
    </div>
  );
}

function ProfilStat({ label, value, divider }) {
  return (
    <div style={{
      textAlign: 'center', padding: '4px 8px',
      borderLeft: divider ? `1px solid ${C.line}` : 'none',
    }}>
      <div style={{ fontSize: 20, fontWeight: 800, color: C.ink, letterSpacing: -0.3 }}>{value}</div>
      <div style={{ fontSize: 11, color: C.ink50, marginTop: 2 }}>{label}</div>
    </div>
  );
}

function ProfilRow({ icon, label, hint, last }) {
  return (
    <button style={{
      ...btnReset, display: 'flex', alignItems: 'center', gap: 12, width: '100%',
      padding: '14px 16px', borderBottom: last ? 'none' : `1px solid ${C.line}`,
    }}>
      <div style={{
        width: 34, height: 34, borderRadius: 10, background: C.tealSoft, color: C.teal,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>{icon}</div>
      <div style={{ flex: 1, fontSize: 14, color: C.ink, fontWeight: 500, textAlign: 'left' }}>{label}</div>
      {hint && <div style={{ fontSize: 12, color: C.ink50 }}>{hint}</div>}
      <IconChevR size={18} style={{ color: C.ink20 }}/>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// Bottom navigation (5 tabs + floating FAB)
// ─────────────────────────────────────────────────────────────
function BottomNav({ active, onChange, onPlus }) {
  const tabs = [
    { id: 'home',     label: 'Accueil', icon: IconHome },
    { id: 'map',      label: 'Carte',   icon: IconMap },
    { id: '__fab' },
    { id: 'alerts',   label: 'Alertes', icon: IconBell },
    { id: 'profile',  label: 'Profil',  icon: IconPerson },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0,
      height: 82, // matches NAV_H in CoastwatchApp
      paddingBottom: 24, // home indicator clearance
      background: '#fff', borderTop: `1px solid ${C.line}`,
      boxShadow: '0 -6px 18px -8px rgba(0,0,0,0.08)',
    }}>
      {/* FAB */}
      <button onClick={onPlus} style={{
        ...btnReset,
        position: 'absolute', left: '50%', top: -28, transform: 'translateX(-50%)',
        width: 58, height: 58, borderRadius: 999,
        background: C.teal, color: '#fff',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 8px 20px -6px rgba(11,86,96,0.5), 0 0 0 5px #fff',
      }}>
        <IconPlus size={26}/>
      </button>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr 1fr', padding: '8px 6px 2px' }}>
        {tabs.map(t => {
          if (t.id === '__fab') return <div key="fab"/>;
          const I = t.icon;
          const isActive = active === t.id;
          return (
            <button key={t.id} onClick={() => onChange(t.id)} style={{
              ...btnReset, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
              padding: '8px 4px', color: isActive ? C.teal : C.ink50,
            }}>
              <I size={22}/>
              <span style={{ fontSize: 11, fontWeight: isActive ? 700 : 500 }}>{t.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// FAB action sheet (when + is tapped)
// ─────────────────────────────────────────────────────────────
function ActionSheet({ open, onClose }) {
  if (!open) return null;
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, background: 'rgba(14,27,34,0.45)', zIndex: 80,
      display: 'flex', alignItems: 'flex-end',
      animation: 'cwFade 180ms ease-out',
    }}>
      <div onClick={e => e.stopPropagation()} style={{
        background: '#fff', width: '100%', borderTopLeftRadius: 24, borderTopRightRadius: 24,
        padding: '14px 20px 36px',
        animation: 'cwSlideUp 220ms cubic-bezier(.2,.8,.2,1)',
      }}>
        <div style={{ width: 40, height: 4, borderRadius: 999, background: C.line, margin: '0 auto 14px' }}/>
        <div style={{ fontSize: 16, fontWeight: 700, color: C.ink, marginBottom: 12 }}>Nouvelle contribution</div>
        <SheetAction icon={<IconCamera size={22}/>} tint={C.teal}    title="Ajouter une photo"    sub="Capturez l'état actuel de la plage"/>
        <SheetAction icon={<IconAlert size={22}/>}  tint="#C77A0D"   title="Signaler un problème" sub="Érosion, pollution, construction…"/>
        <SheetAction icon={<IconRuler size={22}/>}  tint="#6B4DBA"   title="Relevé terrain"       sub="Mesure manuelle du trait de côte" last/>
      </div>
    </div>
  );
}

function SheetAction({ icon, tint, title, sub, last }) {
  return (
    <button style={{
      ...btnReset, display: 'flex', alignItems: 'center', gap: 14, width: '100%',
      padding: '12px 0', borderBottom: last ? 'none' : `1px solid ${C.line}`, textAlign: 'left',
    }}>
      <div style={{
        width: 44, height: 44, borderRadius: 12, background: hexA(tint, 0.12), color: tint,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>{icon}</div>
      <div>
        <div style={{ fontSize: 14, fontWeight: 700, color: C.ink }}>{title}</div>
        <div style={{ fontSize: 12, color: C.ink50, marginTop: 2 }}>{sub}</div>
      </div>
    </button>
  );
}

// ─────────────────────────────────────────────────────────────
// App shell
// ─────────────────────────────────────────────────────────────
function CoastwatchApp() {
  const [tab, setTab] = useState('home');
  const [detail, setDetail] = useState(null); // beachId or null
  const [sheet, setSheet] = useState(false);

  const openBeach = (id) => setDetail(id);
  const closeBeach = () => setDetail(null);
  const switchTab = (t) => { setDetail(null); setTab(t); };

  const showNav = !detail; // nav hidden on detail screen
  const NAV_H = 82; // visual nav height; home indicator sits below this

  return (
    <div style={{ position: 'relative', height: '100%', background: '#fff', overflow: 'hidden' }}>
      {/* Scrollable content area, bounded above the nav */}
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
function hexA(hex, a) {
  const h = hex.replace('#','');
  const r = parseInt(h.slice(0,2), 16), g = parseInt(h.slice(2,4), 16), b = parseInt(h.slice(4,6), 16);
  return `rgba(${r},${g},${b},${a})`;
}

Object.assign(window, { CoastwatchApp });
