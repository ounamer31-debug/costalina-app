// Stroke icons used throughout the Coastwatch prototype.
// Style: lucide-ish — 1.75 stroke, round caps/joins, currentColor.

const ICON_BASE = {
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.75,
  strokeLinecap: 'round',
  strokeLinejoin: 'round',
};

const Icon = ({ size = 22, children, style }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block', ...style }} {...ICON_BASE}>
    {children}
  </svg>
);

const IconMenu      = (p) => <Icon {...p}><path d="M4 7h16M4 12h16M4 17h10"/></Icon>;
const IconBell      = (p) => <Icon {...p}><path d="M6 8a6 6 0 1 1 12 0c0 5 2 6 2 6H4s2-1 2-6"/><path d="M10 19a2 2 0 0 0 4 0"/></Icon>;
const IconBellDot   = (p) => <Icon {...p}><path d="M6 8a6 6 0 1 1 12 0c0 5 2 6 2 6H4s2-1 2-6"/><path d="M10 19a2 2 0 0 0 4 0"/><circle cx="18" cy="6" r="2.5" fill="#E55353" stroke="none"/></Icon>;
const IconBack      = (p) => <Icon {...p}><path d="M15 6l-6 6 6 6"/></Icon>;
const IconShare     = (p) => <Icon {...p}><path d="M12 4v12"/><path d="M8 8l4-4 4 4"/><path d="M5 14v4a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-4"/></Icon>;
const IconSearch    = (p) => <Icon {...p}><circle cx="11" cy="11" r="6.5"/><path d="m20 20-3.5-3.5"/></Icon>;
const IconLocate    = (p) => <Icon {...p}><circle cx="12" cy="12" r="3.5"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/></Icon>;
const IconFilter    = (p) => <Icon {...p}><path d="M4 5h16l-6 8v6l-4-2v-4z"/></Icon>;
const IconCamera    = (p) => <Icon {...p}><path d="M4 8.5A1.5 1.5 0 0 1 5.5 7H8l1.5-2h5L16 7h2.5A1.5 1.5 0 0 1 20 8.5V17a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><circle cx="12" cy="13" r="3.5"/></Icon>;
const IconAlert     = (p) => <Icon {...p}><path d="M12 3 2 20h20z"/><path d="M12 10v5"/><circle cx="12" cy="17.5" r=".4" fill="currentColor"/></Icon>;
const IconMap       = (p) => <Icon {...p}><path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2z"/><path d="M9 4v14M15 6v14"/></Icon>;
const IconCap       = (p) => <Icon {...p}><path d="M2 9l10-5 10 5-10 5z"/><path d="M6 11v5c0 1.5 2.5 3 6 3s6-1.5 6-3v-5"/></Icon>;
const IconHome      = (p) => <Icon {...p}><path d="M4 11 12 4l8 7"/><path d="M6 10v9a1 1 0 0 0 1 1h3v-5h4v5h3a1 1 0 0 0 1-1v-9"/></Icon>;
const IconPerson    = (p) => <Icon {...p}><circle cx="12" cy="8" r="4"/><path d="M4 20c1.5-4 5-6 8-6s6.5 2 8 6"/></Icon>;
const IconChevR     = (p) => <Icon {...p}><path d="m9 6 6 6-6 6"/></Icon>;
const IconChevLR    = (p) => <Icon {...p}><path d="m9 8-4 4 4 4M15 8l4 4-4 4"/></Icon>;
const IconOverview  = (p) => <Icon {...p}><rect x="4" y="4" width="16" height="16" rx="2.5"/><path d="M8 10h8M8 14h5"/></Icon>;
const IconTrend     = (p) => <Icon {...p}><path d="m3 17 6-6 4 4 8-9"/><path d="M14 6h7v7"/></Icon>;
const IconSend      = (p) => <Icon {...p}><path d="m4 12 16-7-7 16-2-7z"/></Icon>;
const IconInfo      = (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M12 11v6"/><circle cx="12" cy="8" r=".4" fill="currentColor"/></Icon>;
const IconRuler     = (p) => <Icon {...p}><rect x="3" y="9" width="18" height="6" rx="1.5" transform="rotate(-20 12 12)"/></Icon>;
const IconPin       = (p) => <Icon {...p}><path d="M12 21s7-7 7-12a7 7 0 1 0-14 0c0 5 7 12 7 12z"/><circle cx="12" cy="9.5" r="2.5"/></Icon>;
const IconPlus      = (p) => <Icon {...p}><path d="M12 5v14M5 12h14"/></Icon>;
const IconClose     = (p) => <Icon {...p}><path d="M6 6l12 12M18 6 6 18"/></Icon>;
const IconCheck     = (p) => <Icon {...p}><path d="m5 12 5 5 9-11"/></Icon>;
const IconWave      = (p) => <Icon {...p}><path d="M2 12c2 0 2-2 5-2s3 2 5 2 3-2 5-2 3 2 5 2"/><path d="M2 17c2 0 2-2 5-2s3 2 5 2 3-2 5-2 3 2 5 2"/></Icon>;
const IconClock     = (p) => <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></Icon>;
const IconSettings  = (p) => <Icon {...p}><circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 0 0-.1-1.2l2-1.5-2-3.4-2.3.9a7 7 0 0 0-2-1.2L14 3h-4l-.5 2.6a7 7 0 0 0-2 1.2l-2.4-.9-2 3.4 2.1 1.5A7 7 0 0 0 5 12a7 7 0 0 0 .1 1.2L3 14.7l2 3.4 2.4-.9a7 7 0 0 0 2 1.2L10 21h4l.5-2.6a7 7 0 0 0 2-1.2l2.3.9 2-3.4-2-1.5c.1-.4.1-.8.1-1.2z"/></Icon>;

Object.assign(window, {
  IconMenu, IconBell, IconBellDot, IconBack, IconShare, IconSearch, IconLocate, IconFilter,
  IconCamera, IconAlert, IconMap, IconCap, IconHome, IconPerson, IconChevR, IconChevLR,
  IconOverview, IconTrend, IconSend, IconInfo, IconRuler, IconPin, IconPlus, IconClose,
  IconCheck, IconWave, IconClock, IconSettings,
});
