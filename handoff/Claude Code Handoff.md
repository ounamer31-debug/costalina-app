# Costalina — Mobile App Implementation Handoff

> **For Claude Code.** The target design lives in `Costalina Prototype.html`
> (open it side-by-side with this doc). Match it pixel-for-pixel in Flutter.
> The Web reference (Iberostar Tunisie homepage) is the visual north-star:
> **editorial, calm, hairline-thin, sand + teal, Cormorant Garamond + Jost.**
>
> This is a **full visual redesign + rebrand**. The old `Coastwatch` name,
> Plus Jakarta Sans typography, rounded-iOS cards, and deep teal `#0F6E7B`
> are *all gone*. Replace tokens, replace components, replace strings.

---

## 0. The mental model

**Old app** → "modern iOS mobile app". Round corners, chunky pills, bright
risk colors, generic sans-serif.

**New app (Costalina)** → "boutique-hotel print magazine, miniaturised
onto a phone". Sharp 0–2 px corners, hairline 1 px teal borders,
**italic serif headings** (Cormorant Garamond), **uppercase tracked
eyebrows** (Jost), sand background `#f5f0e8`, full-bleed photos with
dark gradients, brand logo (starfish + palm + waves) replacing every
star/dot moment.

Every screen has the same three editorial moves:

1. **Eyebrow** — tiny uppercase Jost, 9–11 px, .28–.35 em letter-spacing,
   teal-dark color.
2. **Serif title** — Cormorant Garamond 300, with **one word italicised
   in teal-dark** for emphasis. e.g. _Veillons sur nos **plages**_.
3. **Hairline divider** — 1 px `rgba(91,188,176,0.14–0.22)` between
   sections and inside cards.

If any new UI you build feels too "appy" (rounded, candy-coloured),
it is wrong. When in doubt, **strip a corner radius, swap a sans
heading for a serif italic, replace a pill with a hairline-bordered
tag.**

---

## 1. Goal

Rebrand `Coastwatch` → `Costalina` and replace the entire UI of the
mobile app to match `Costalina Prototype.html`.

**Five screens** sit behind one persistent bottom nav. Routes & files
unchanged from the prior plan; only contents change.

| # | Screen        | File                                       | Route   |
|---|---------------|--------------------------------------------|---------|
| 1 | Accueil       | `lib/screens/home_screen.dart`             | `/app`  |
| 2 | Carte         | `lib/screens/map_screen.dart`              | `/app`  |
| 3 | Détails plage | `lib/screens/beach_detail_screen.dart`     | pushed  |
| 4 | Alertes       | `lib/screens/alertes_screen.dart`          | `/app`  |
| 5 | Profil        | `lib/screens/profil_screen.dart`           | `/app`  |

`splash_screen.dart` and `login_screen.dart` keep their wiring but get
re-skinned to the new brand (see §8).

---

## 2. Rename pass — do this FIRST

Run a project-wide rename before touching visuals so commits stay clean.

| Find                       | Replace                  |
|----------------------------|--------------------------|
| `Coastwatch`               | `Costalina`              |
| `COASTWATCH`               | `COSTALINA`              |
| `coastwatch`               | `costalina`              |
| `CoastwatchApp`            | `CostalinaApp`           |
| App title (`pubspec.yaml` → `name:` and `description:`) | `costalina_app` / `Costalina — surveillance du littoral tunisien` |
| Android `applicationId` (`android/app/build.gradle`)    | `com.costalina.app`     |
| iOS `CFBundleName` / `CFBundleDisplayName` (`ios/Runner/Info.plist`) | `Costalina` |
| iOS bundle identifier (`PRODUCT_BUNDLE_IDENTIFIER` in `project.pbxproj`) | `com.costalina.app` |
| Splash/launch screen text  | `Costalina`              |

Then add the new logo:

```
assets/
  brand/
    costalina-logo.jpg     ← the user's master logo (720×720, teal on white)
    costalina-mark.svg     ← isolated mark (no wordmark) for compact UI
```

Source files:
- The JPG master is in `assets/costalina-logo.jpg` of the design project.
- `costalina-mark.svg` should be authored from the inline SVG used in
  `screens.jsx → CostalinaMark()` (copy the path data verbatim). Use
  `flutter_svg: ^2.0.10` to render it.

Register in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/brand/costalina-logo.jpg
    - assets/brand/costalina-mark.svg
  fonts:
    # Use google_fonts for runtime fetch; no manual font files needed.
```

---

## 3. Design tokens

**Replace `lib/theme/app_theme.dart`.** Wipe the old palette; do not
keep `Color(0xFF0F6E7B)` anywhere.

```dart
import 'package:flutter/material.dart';

class CColors {
  // Brand teal scale
  static const teal      = Color(0xFF5BBCB0);  // primary teal (logo)
  static const tealDark  = Color(0xFF3D9E93);  // emphasis / CTA / links
  static const tealDeep  = Color(0xFF1D504B);  // press / dark-on-light text
  static const tealPale  = Color(0xFFA8DDD8);  // backgrounds / overlays
  static const tealBg    = Color(0xFFE8F7F5);  // soft tint
  static const tealLine  = Color(0x385BBCB0);  // ≈ rgba(91,188,176,0.22) hairline
  static const tealLineSoft = Color(0x245BBCB0); // ≈ rgba(91,188,176,0.14)

  // Surfaces — sand-toned, NOT plain white as primary
  static const sand      = Color(0xFFF5F0E8);  // page bg (DEFAULT)
  static const sandDark  = Color(0xFFE0D8C8);
  static const white     = Color(0xFFFFFFFF);  // card surface only

  // Ink (text)
  static const ink       = Color(0xFF1A2E2C);  // headlines & body
  static const inkSoft   = Color(0xFF3A5450);  // secondary text
  static const grey      = Color(0xFF7A9490);  // tertiary / eyebrow muted

  // Risk semantics — muted, NOT traffic-light bright
  static const greenInk  = Color(0xFF1D9E75);
  static const greenBg   = Color(0x1A1D9E75);   // 10%
  static const amberInk  = Color(0xFFC4804A);
  static const amberBg   = Color(0x1FC4804A);   // 12%
  static const redInk    = Color(0xFFA84848);
  static const redBg     = Color(0x1AA84848);   // 10%
}
```

### 3.1 Typography

Use `google_fonts: ^6.2.1`. Add to `pubspec.yaml` and register both
families.

```dart
import 'package:google_fonts/google_fonts.dart';

class CType {
  // Display — Cormorant Garamond (serif). Weight 300, optional italic.
  static TextStyle serifDisplay({double size = 30, Color color = CColors.ink, bool italic = false}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: size, fontWeight: FontWeight.w300, color: color,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: 1.12, letterSpacing: -0.2,
    );

  // Body — Jost (sans). Weights 300/400/500.
  static TextStyle body({double size = 13, Color color = CColors.inkSoft, FontWeight w = FontWeight.w300}) =>
    GoogleFonts.jost(fontSize: size, color: color, fontWeight: w, height: 1.65, letterSpacing: 0.1);

  // Eyebrow — Jost uppercase tracked. THE signature element.
  static TextStyle eyebrow({double size = 10, double tracking = 0.32, Color color = CColors.tealDark, FontWeight w = FontWeight.w500}) =>
    GoogleFonts.jost(
      fontSize: size, fontWeight: w, color: color,
      letterSpacing: tracking * size,   // CSS em → Flutter px conversion
      height: 1.2,
    );
}
```

**Heading rule:** every screen has ONE serif `Text.rich` with the
emphasised word wrapped in italic:

```dart
Text.rich(TextSpan(
  style: CType.serifDisplay(size: 34),
  children: [
    const TextSpan(text: 'Veillons sur nos\n'),
    TextSpan(text: 'plages', style: CType.serifDisplay(size: 34, color: CColors.tealDark, italic: true)),
    const TextSpan(text: '.'),
  ],
))
```

Never use ALL-CAPS in a serif heading. Never centre an eyebrow under a
left-aligned title.

### 3.2 Shapes & spacing

| Token              | Value                                    |
|--------------------|------------------------------------------|
| Corner radius      | **0 px default**, 2 px max for inputs, 999 only for dot indicators. **No 12/14/16 radii anywhere.** |
| Border             | 1 px `CColors.tealLine` on every card edge |
| Page padding       | 22 px horizontal                         |
| Section gap        | 36–40 px vertical                        |
| Hero photo ratio   | 5:6 (home featured), 1:1 (detail header) |
| Bottom-nav height  | 86 px (62 visible + 24 safe area)        |
| Status-bar offset  | 56 px (iOS notch)                        |

### 3.3 Shadows — almost none

Editorial design earns depth from hairlines, not blur. Allowed shadows:

- Map info card: `BoxShadow(blurRadius: 36, offset: (0,14), color: 0x592e2c1a /* rgba(26,46,44,0.35) at 90% spread, simulate via spreadRadius -10 */)`
- Center "Ajouter" nav button: `BoxShadow(blurRadius: 18, offset: (0,8), color: 0x991D504B /* rgba(29,80,75,0.6) at low alpha*/)`

Everywhere else: **zero shadow**. If a card needs separation, give it a
1 px hairline border instead.

---

## 4. The brand mark — `CostalinaMark` widget

Build once, use everywhere. The logo is a circle ring containing a
starfish (upper-left), a palm tree on a dune (upper-right), and three
flowing waves at the bottom.

```dart
// lib/widgets/costalina_mark.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CostalinaMark extends StatelessWidget {
  final double size;
  final Color color;
  const CostalinaMark({super.key, this.size = 28, this.color = CColors.tealDark});
  @override
  Widget build(BuildContext c) => SvgPicture.asset(
    'assets/brand/costalina-mark.svg',
    width: size, height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}
```

The asset SVG should be authored to use `currentColor` on every stroke
& fill so `ColorFilter.srcIn` can recolour the whole mark.

### Usage rules
- **Top app bar** — mark @ 22–26 px, beside `COSTALINA` wordmark
  (Jost 300, 13 px, `letterSpacing: 4.9` ≈ .38 em).
- **Map pin** — mark @ 10–12 px, coloured by the beach's risk.
- **Center nav button** — mark @ 22 px in white, on `tealDark` square.
- **Profil footer / Action-sheet header** — mark @ 56 px, centred,
  with the wordmark below.
- **Star severity gauge (1–5 marks)** — use the *simple star clip*
  (`BrandMark` in prototype), not the full Costalina mark. The full
  mark only appears once per screen for brand clarity.

---

## 5. Shared widgets — build once, reuse everywhere

All live in `lib/widgets/`.

### 5.1 `Eyebrow`
```dart
Eyebrow('Littoral tunisien · 2026', color: CColors.tealDark, size: 10, tracking: 0.32)
```
Renders Jost uppercase tracked text. Default colour `tealDark`, size 10,
tracking 0.32 em. **Use ABOVE every section and every title.**

### 5.2 `SerifTitle`
A `Text.rich` helper that accepts `(plain, italicEmphasis, plainTrail)`:
```dart
SerifTitle('Alertes\n', italic: 'côtières', size: 34)
```
The italic word is rendered in `tealDark`, italic style. Always lets
the user pick the size (22 for section heads, 30–34 for screen heads).

### 5.3 `HairLine`
A 1 px coloured rule. Supports horizontal & vertical via a `vertical`
flag. Default colour `CColors.tealLineSoft`.

### 5.4 `SectionHead`
The compound section header used on Home / Detail / Alertes / Profil:
```dart
SectionHead(
  kicker: 'Synthèse',
  title: 'État du',
  italic: 'littoral',
  trailing: GhostLink(label: 'Voir tout'),
)
```
Layout: small eyebrow → serif title (with italic em) → 1 px hairline
divider below. 18 px bottom margin.

### 5.5 `GhostLink`
Tiny uppercase tracked link with a 1 px teal-pale underline:
```
VOIR TOUT
─────────
```
Tap target ≥ 44 px (pad if needed); visual size 10 px / .22 em tracking.

### 5.6 `StarGauge`
Five star-shape marks. Filled count = severity (1 stable / 3 modéré /
5 élevé). Use a `ClipPath` with the 10-vertex polygon below:
```dart
// star polygon (50% 0, 61% 35, 98% 35, 68% 57, 79% 91, 50% 70, 21% 91, 32% 57, 2% 35, 39% 35)
```
Used on home list rows, detail hero, map info card.

### 5.7 `RiskTag`
Small uppercase Jost tag with a hairline border. **Not a chunky pill.**
- Light variant (over dark photos): white text, `rgba(255,255,255,0.14)` bg, white-alpha border.
- Default variant: ink text matching risk, `risk.bg` fill, `risk.dot @ 25%` border.
- 5 px dot prefix, 6 px gap, 10 px / .16 em tracking.
- Padding 5 × 10 (md) or 3 × 8 (sm).

### 5.8 `IconBtn`
A bare 32 × 32 transparent button. **No circle background, no border.**
The icon (20–22 px stroke 1.75) sits on the surface colour directly.

### 5.9 `BottomNav`
Sand background `#F5F0E8`, 1 px top hairline `tealLine`, 86 px tall
(62 visible + 24 safe-area). Five slots in `Row`:

```
[Accueil] [Carte] [ Ajouter ] [Alertes] [Profil]
                  ↑ 52×52, tealDark bg, 3px sand border halo,
                    Costalina mark @ 22 + "AJOUTER" 7px caption
```

- Active tab: `tealDark` icon + label, with a 14-px hairline rule below
  the label.
- Inactive: grey icon + label.
- Tapping `Ajouter` opens the `ActionSheet` modal (§7).

### 5.10 `ActionSheet`
A bottom modal, sand background, top hairline, 36×2 drag handle,
serif title with italic em (_Nouvelle **observation**_), then a
single bordered list of three rows:

| Icon         | Title                       | Sub                                     |
|--------------|-----------------------------|-----------------------------------------|
| Camera       | Ajouter une photo           | Capturez l'état actuel de la plage       |
| Alert        | Signaler un problème        | Érosion, pollution, construction…       |
| Ruler        | Relevé terrain              | Mesure manuelle du trait de côte        |

Each row: icon (teal-dark) → serif title 17 px → Jost sub 11 px → `→` chevron.

---

## 6. Screen specs

For every screen below the layout is **`Column`** scrollable from the
top, with `SafeArea(top: false)` so the 56 px status-bar offset is
explicit. Bottom nav is rendered by the AppShell, not the screen.

### 6.1 Accueil (Home)

```
┌─ 56 px notch ─────────────────────────────────┐
│ [✦ COSTALINA]            [🔔]  [≡]            │  TopBar (sand, hairline bottom)
├───────────────────────────────────────────────┤
│  LITTORAL TUNISIEN · 2026                     │  Eyebrow
│  Veillons sur nos                             │  Serif 34, w300
│  plages.                                      │  italic em, tealDark
│                                               │
│  Surveillance du trait de côte…               │  Jost 13, w300, inkSoft
├───────────────────────────────────────────────┤
│  ╔═══════════════════════════════════════╗   │
│  ║  À LA UNE                  20·05·2026  ║   │  Hero card 5:6
│  ║   ┌───────┐  ┌───────┐                ║   │  ▸ Full-bleed photo
│  ║   └───────┘  └───────┘                ║   │  ▸ Dark gradient bottom
│  ║                  (corner brackets)    ║   │  ▸ 14-px hairline corner ornaments
│  ║                                       ║   │  ▸ Eyebrow + serif name
│  ║   MONASTIR · TRAIT DE CÔTE            ║   │  ▸ Risk tag + italic erosion
│  ║   Skanes                              ║   │  ▸ "DÉCOUVRIR LE DÉTAIL →"
│  ║   ● RISQUE MODÉRÉ  · recul −3.2 m     ║   │
│  ║                                       ║   │
│  ║   DÉCOUVRIR LE DÉTAIL →               ║   │
│  ╚═══════════════════════════════════════╝   │
├───────────────────────────────────────────────┤
│  SYNTHÈSE                                     │
│  État du littoral                             │
│  ─────────                                    │
│  ┌──── ┬───── ┬─────┐                         │  3-col stat strip,
│  │ 12  │ 8    │ 5   │                         │  ▸ serif 44 numbers
│  │ ● Stables │ ● Modéré │ ● Élevé │           │  ▸ 1 px column dividers
│  └──── ┴───── ┴─────┘                         │
├───────────────────────────────────────────────┤
│  À VOTRE MAIN                                 │
│  Actions rapides                              │
│  ┌─────────────┬─────────────┐                │  2×2 grid, hairline cross
│  │ 📷 Ajouter   │ ⚠ Signaler  │                │  ▸ Icon 20 + serif 16
│  │   une photo │  un problème │                │  ▸ Jost 10 sub, .06 em
│  ├─────────────┼─────────────┤                │
│  │ 🗺 Voir la   │ 🎓 Centre   │                │
│  │   carte     │   d'apprent.│                │
│  └─────────────┴─────────────┘                │
├───────────────────────────────────────────────┤
│  VEILLE ACTIVE              VOIR TOUT         │
│  Plages surveillées                           │
│  ─────────                                    │
│  [📷] MONASTIR                                │  Row: 64×80 photo +
│       Plage de Sayada                         │  ▸ Eyebrow city
│       ✦✦✦✦✦  −5.8 m              →            │  ▸ Serif 19 name
│  ─────────                                    │  ▸ StarGauge + italic erosion
│  [📷] MONASTIR                                │
│       Plage de Skanes                         │
│       ✦✦✦☆☆  −3.2 m              →            │
│  …                                            │
└───────────────────────────────────────────────┘
```

Photos: square-ish 64 × 80 with a darken-gradient overlay. Severity →
star count: stable=1, modéré=3, élevé=5 (yes, lower severity = fewer
filled marks; flip if your stakeholders prefer the inverse, but stay
consistent).

### 6.2 Carte (Map)

```
┌─ Sand header (no teal block!) ────────────────┐
│ [≡]   [✦ CARTOGRAPHIE]   [▼]                  │
│                                               │
│ Trait de côte                                 │  Serif 26
│ tunisien                                      │  italic em
│                                               │
│ [🔍 Rechercher une plage…]   [📍]              │  hairline input + button
├───────────────────────────────────────────────┤
│  (Map area — desaturated sea/sand,            │
│   thin sandy coast edge, star-shaped pins)    │
│                                               │
│   ✦ ← active pin pulses with a 28 px ring     │
│                                               │
│   ┌─ MAPINFOCARD ─────────┐                   │  Sand card,
│   │ MONASTIR              │                   │  ▸ Eyebrow city
│   │ Plage de Skanes  →    │                   │  ▸ Serif 18 name
│   │ ✦✦✦☆☆  Risque modéré  │                   │  ▸ StarGauge + label
│   │ ───────────           │                   │
│   │ MAJ · 20·05·2026  −3.2 m │                 │  ▸ tail pointing down to pin
│   └─────────────────────────┘                 │
│                                                │
│  [Stable] ┃ [Modéré] ┃ [Élevé]                 │  Hairline-separated legend
└────────────────────────────────────────────────┘
```

Pins use `CostalinaMark` at 10–12 px (active 12, idle 8 or 10), tinted
by risk. **Do not** use chunky white-bordered dots.

### 6.3 Détails de la plage

```
┌─ 360 px hero photo ───────────────────────────┐
│ [←]      FICHE PLAGE                  [↗]     │  Light icon buttons over photo
│ (corner brackets — same hairline ornament)   │
│                                               │
│ MONASTIR · MISE À JOUR 20·05·2026             │  Eyebrow (tealPale)
│ Plage de Skanes                               │  Serif 32 white
│ ● RISQUE MODÉRÉ  ✦✦✦☆☆                       │  Light RiskTag + StarGauge
├───────────────────────────────────────────────┤
│  Aperçu  Évolution  Signalements  Infos       │  Uppercase tabs,
│  ─────                                        │  ▸ tealDark 2-px underline
├───────────────────────────────────────────────┤
│  TRAIT DE CÔTE                  VOIR PLUS     │
│  Avant / après                                │
│  ┌─────────┬─────────┐                        │  2-up 4:5 photos
│  │  2023   │  2024   │                        │  ▸ 2024 desaturated
│  └─────────┴─────────┘                        │  ▸ Sand label tile (9 px eyebrow)
│  ┌─────────────────────────────┐              │  Recul card:
│  │ RECUL ESTIMÉ                │              │  ▸ Serif 38 red ink
│  │ −3.2 m                      │              │  ▸ italic period
│  │ ‟sur 12 mois”               │              │  ▸ Vertical hairline divider
│  │ ─ │ SÉVÉRITÉ ✦✦✦☆☆ Modéré   │              │  ▸ StarGauge + label
│  └─────────────────────────────┘              │
│                                               │
│  COMMUNAUTÉ                     VOIR TOUT     │
│  Signalements récents                         │
│  [photo] 18·05·2026 · 10:30                   │
│          Érosion              [EN COURS]      │  Hairline border tag
└───────────────────────────────────────────────┘
```

Tabs `Aperçu / Évolution / Signalements / Infos` switch the body
content. Other tab specs:

- **Évolution** — sparkline (12 months, area gradient at 28→0% teal,
  1.6-px tealDark stroke, 3.5-px dot at last point). Below: 2×2 KPI
  grid with hairlines (Total reculé / Vitesse / Pire mois / Confiance).
- **Signalements** — list of `SignalementRow`s (56×70 photo + serif
  type + Jost timestamp + hairline-bordered status tag).
- **Infos** — definition list, `padding: 14 × 18`, eyebrow keys,
  serif 14 values, hairlines between rows.

### 6.4 Alertes

```
[✦ COSTALINA]                                 [⚙]
                                                
5 NOUVELLES · 2 À TRAITER
Alertes
côtières

┌────────────────────────────────────────────┐
│  ✦ Plage de Sayada              il y a 2 h │  Serif 17 name, eyebrow time
│    Recul du trait de côte de 5,8 m détecté. │  Jost 12.5 body
│    ● RISQUE ÉLEVÉ                           │  RiskTag sm
├────────────────────────────────────────────┤
│  ✦ Plage de Skanes              il y a 5 h │
│    Nouveau signalement d'érosion à vérifier.│
│    ● RISQUE MODÉRÉ                          │
├────────────────────────────────────────────┤
│  …                                         │
└────────────────────────────────────────────┘
```

Each alert row leads with a small **star-clip mark** in the risk
colour (not the full Costalina mark — too detailed at this size).

### 6.5 Profil

```
[←]   [✦ COSTALINA]                          [⚙]

BÉNÉVOLE · MONASTIR
Yasmine Taoufik                  ← serif w/ italic on surname
Inscrite depuis mars 2025 · Costalinienne active

┌──── ┬───── ┬──────┐
│ 12  │ 47   │ 6    │              ← 3-col stats, serif 30 tealDark
│ Signal. │ Photos │ Plages │
└──── ┴───── ┴──────┘

MON ESPACE
┌──────────────────────────────┐
│ 🔔 Notifications     Activées →│
│ 🗺 Plages suivies         6  →│
│ 🎓 Centre d'apprentissage  →  │
│ ℹ À propos de Costalina    →  │
│ ⚙ Paramètres                  │
└──────────────────────────────┘

                ✦ Costalina ✦              ← full mark @ 56 px, centred
            COSTALINA                       ← Jost 14, .48 em tracking
       V 2.4 · LITTORAL TUNISIEN · 2026     ← grey caption
```

Bottom padding **80 px** so the editorial footer clears the bottom-nav
"Ajouter" button.

---

## 7. ActionSheet — the only modal

Triggered by the centre `Ajouter` button. See §5.10 for layout.
Critical: the modal background is **sand** (`#F5F0E8`), not white,
so it feels of-a-piece with the rest of the app.

Animation: 220 ms ease-out spring on enter (transform Y 28→0 px, opacity
0.4→1). Dim layer behind is `rgba(26,46,44,0.55)` with 6 px backdrop blur.

---

## 8. Splash & Login

The user keeps these screens but they must be re-skinned:

- **Background:** `CColors.sand`.
- **Logo:** `CostalinaMark` @ 96 px, centred 1/3 from the top, plus
  `COSTALINA` wordmark below (Jost 16, .5 em tracking).
- **Login fields:** sand surfaces, 1 px `tealLine` border, no rounding
  (radius 2 px max). Floating labels disabled — use a static
  uppercase **eyebrow** above each field (`EMAIL`, `MOT DE PASSE`).
- **Primary CTA (`Se connecter`):** full-width 52 px, `tealDark` bg,
  white Jost 11 px `.22 em` tracking, label "SE CONNECTER →".
- **Secondary link (`Créer un compte`):** GhostLink style.

---

## 9. Icons

Lucide stroke 1.75, currentColor. The prototype's `icons.jsx` lists
the canonical set. In Flutter use `lucide_icons: ^0.257.0` and the
mapping below:

| Use                | Icon                  |
|--------------------|-----------------------|
| Menu               | `LucideIcons.menu`    |
| Bell (with dot)    | `LucideIcons.bell`    |
| Back               | `LucideIcons.chevronLeft` |
| Share              | `LucideIcons.share`   |
| Search             | `LucideIcons.search`  |
| Locate             | `LucideIcons.locate`  |
| Filter             | `LucideIcons.filter`  |
| Camera             | `LucideIcons.camera`  |
| Alert              | `LucideIcons.alertTriangle` |
| Map                | `LucideIcons.map`     |
| Cap (learn)        | `LucideIcons.graduationCap` |
| Home               | `LucideIcons.home`    |
| Person             | `LucideIcons.user`    |
| Ruler              | `LucideIcons.ruler`   |
| Settings           | `LucideIcons.settings`|
| Pin                | `LucideIcons.mapPin`  |
| Chevron Right      | `LucideIcons.chevronRight` (or render an arrow `→` glyph) |

Many "chevron" moments in the prototype are actually a Jost `→` glyph
(U+2192) at 14–18 px weight 300, in `tealDark`. Prefer the glyph over
an icon when it sits inside a button or list row — it matches the
editorial vibe.

---

## 10. Things you must NOT do

Reject any of these visual moves in code review:

1. **Don't** use `BorderRadius.circular(12 | 14 | 16 | 20)` on any
   card, button, input, or tag. Sharp edges only.
2. **Don't** show solid colour-filled pills (`E4F4E7` etc.) without a
   matching hairline border at 25–40 % alpha of the risk dot.
3. **Don't** use Plus Jakarta Sans, Inter, Roboto, or SF Pro anywhere.
   Serif = Cormorant Garamond, sans = Jost. Period.
4. **Don't** centre body copy. Editorial layouts are flush-left.
5. **Don't** use emoji in production strings. (Prototype uses one wave
   emoji 🌊 as a placeholder — drop it.)
6. **Don't** raise the elevation of cards. Surfaces are flat with
   hairlines. Only the map info card and the centre nav button have
   shadows.
7. **Don't** uppercase serif headings. Uppercase is reserved for
   eyebrows / tabs / nav labels / CTAs in Jost.
8. **Don't** put the full `CostalinaMark` at sizes below 16 px — the
   palm fronds collapse. Use the simple star-clip mark below 16 px.
9. **Don't** swap the brand mark colour on dark photos to pale teal —
   use solid white.
10. **Don't** ship the bottom-nav border as `tealPale`. It must be
    `tealLine` (the .22 alpha variant) for the correct optical weight.

---

## 11. Acceptance checklist

A reviewer should be able to tick every box before merging:

- [ ] App icon, splash, all visible "Coastwatch" strings replaced with "Costalina".
- [ ] `assets/brand/costalina-logo.jpg` and `costalina-mark.svg` shipped.
- [ ] `lib/theme/app_theme.dart` exports `CColors` and `CType` exactly as in §3.
- [ ] No `Color(0xFF0F6E7B)` or `Plus Jakarta` reference anywhere in the codebase (`grep` clean).
- [ ] Every screen has: 1 eyebrow above 1 serif title with italic emphasis.
- [ ] Every "card" is a `Container` with `border: Border.all(color: CColors.tealLine, width: 1)` and `borderRadius: BorderRadius.zero`.
- [ ] Risk severity uses the 5-mark `StarGauge`, not a coloured progress bar.
- [ ] Bottom nav: 5 slots + centred 52 × 52 `Ajouter` button with the Costalina mark.
- [ ] Home featured-beach hero is 5:6, has corner-bracket ornaments, dark gradient, eyebrow + serif name + risk tag + "DÉCOUVRIR LE DÉTAIL →".
- [ ] Detail hero is 360-px photo with overlay (back + share light icons; ornament; eyebrow + serif name + risk tag + StarGauge).
- [ ] Profil footer shows full mark @ 56 px + "COSTALINA" wordmark + version caption, ≥ 80 px bottom padding.
- [ ] Splash & login re-skinned to sand background, sharp inputs, eyebrow labels, full-mark logo.
- [ ] No console warnings about missing fonts (Google Fonts fetched OK).
- [ ] All five tabs preserve scroll position when switched (IndexedStack).
- [ ] Smoke-test on an iPhone SE 1st-gen (small screen) — eyebrows and tracked uppercase don't wrap mid-word.

---

## 12. Reference files in this design project

| File                              | What it is                                |
|-----------------------------------|-------------------------------------------|
| `Costalina Prototype.html`        | **The single source of visual truth.**    |
| `screens.jsx`                     | React components matching every Flutter widget you build. Mirror class names where possible (`CostalinaMark`, `Eyebrow`, `SerifTitle`, `RiskTag`, `StarGauge`, `SectionHead`, `GhostLink`, `BottomNav`, `ActionSheet`). |
| `icons.jsx`                       | Stroke-icon definitions; use as paste-source for `lucide` substitution table. |
| `ios-frame.jsx`                   | Just a phone bezel; ignore.               |
| `assets/costalina-logo.jpg`       | 720 × 720 brand master. Import to Flutter as the JPG and ALSO author the SVG mark from `CostalinaMark` in `screens.jsx`. |
| `Coastwatch Prototype v1.html` + `screens-v1.jsx` | Old design, kept for diff context only. Do NOT implement it. |

---

## 13. Suggested PR order

1. **PR 1 — Rebrand & tokens.** Rename pass (§2), drop new logo assets,
   replace `app_theme.dart`, register Google Fonts. App still compiles
   with the old screens (they'll look broken until PR 2 lands).
2. **PR 2 — Shared widgets.** `CostalinaMark`, `Eyebrow`, `SerifTitle`,
   `HairLine`, `SectionHead`, `GhostLink`, `StarGauge`, `RiskTag`,
   `IconBtn`. Cover every prop in widget tests.
3. **PR 3 — App shell + bottom nav + action sheet.** No screens yet.
4. **PR 4 — Accueil.**
5. **PR 5 — Carte.**
6. **PR 6 — Détails plage (all four tabs).**
7. **PR 7 — Alertes.**
8. **PR 8 — Profil.**
9. **PR 9 — Splash + Login re-skin.**

Each PR can ship behind a feature flag (`costalina_redesign`) if you
prefer to ship incrementally.

---

_End of handoff. Open `Costalina Prototype.html` and compare every
screen, every section, every micro-spacing. If something is unclear,
the prototype wins — code to that, not to this doc._
