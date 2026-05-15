# Coastwatch — Mobile App Implementation Handoff

> **For Claude Code.** Reference design: `Coastwatch Prototype.html` (open it
> alongside this doc). The prototype shows the *target* UX. Match it pixel-for-pixel
> in Flutter using the tokens, components, and screen specs below.

---

## 1. Goal

Replace the current `home_screen.dart` "landing page" with a full multi-screen app
that lets a user browse Tunisian beaches, view erosion data, and report problems.

**Five screens** sit behind one persistent bottom nav:

| # | Screen          | File                                | Route   |
|---|-----------------|-------------------------------------|---------|
| 1 | Accueil         | `lib/screens/home_screen.dart`      | `/app`  |
| 2 | Carte           | `lib/screens/map_screen.dart`       | `/app`  |
| 3 | Détails plage   | `lib/screens/beach_detail_screen.dart` | pushed |
| 4 | Alertes         | `lib/screens/alertes_screen.dart`   | `/app`  |
| 5 | Profil          | `lib/screens/profil_screen.dart`    | `/app`  |

`splash_screen.dart` and `login_screen.dart` stay as-is. After `/login` success,
push `/app` (the shell with bottom nav) instead of the old home.

---

## 2. Design tokens

**Replace `lib/theme/app_theme.dart` colors.** The current palette is a dark
turquoise/navy landing page. The new app is **light surface, deep-teal primary,
traffic-light risk semantics**.

```dart
class AppColors {
  // Brand
  static const teal      = Color(0xFF0F6E7B);   // primary, app bar, FAB
  static const tealDark  = Color(0xFF0B5660);   // gradient end
  static const tealSoft  = Color(0xFFE3F0F2);   // highlight bg

  // Surfaces
  static const bg        = Color(0xFFFFFFFF);
  static const bgSoft    = Color(0xFFF5F7F8);
  static const line      = Color(0xFFECEEF0);

  // Ink (text)
  static const ink       = Color(0xFF0E1B22);
  static const ink70     = Color(0xFF4B5963);
  static const ink50     = Color(0xFF7C8893);
  static const ink20     = Color(0xFFD8DEE2);

  // Risk semantics — every beach maps to one of these
  static const greenBg   = Color(0xFFE4F4E7);
  static const greenInk  = Color(0xFF1F7A37);
  static const greenDot  = Color(0xFF34A853);

  static const amberBg   = Color(0xFFFFF1DB);
  static const amberInk  = Color(0xFFA96A0B);
  static const amberDot  = Color(0xFFF0A12B);

  static const redBg     = Color(0xFFFCE2E2);
  static const redInk    = Color(0xFFB23838);
  static const redDot    = Color(0xFFE55353);
}
```

**Typography** — add Plus Jakarta Sans via `google_fonts: ^6.2.1` (add to
`pubspec.yaml`):

```dart
TextTheme jakarta(BuildContext ctx) => GoogleFonts.plusJakartaSansTextTheme(
  Theme.of(ctx).textTheme,
);
```

Weight scale: 500 (body), 600 (label), 700 (heading), 800 (hero/numeric).

**Radii** — 12 (controls), 14 (cards), 16 (large cards), 20 (hero card), 999 (pills).

**Spacing** — base 4 px. Page padding 20 px horizontal. Vertical rhythm 22–28
between sections.

**Shadows** — keep restrained:
- card: `BoxShadow(blurRadius: 2, color: rgba(0,0,0,0.04))`
- elevated card: `BoxShadow(blurRadius: 24, offset: (0,8), color: rgba(11,86,96,0.18))`
- nav: `BoxShadow(blurRadius: 18, offset: (0,-6), color: rgba(0,0,0,0.06))`

---

## 3. Data model

Add `lib/models/beach.dart`:

```dart
enum BeachRisk { stable, modere, eleve }

class Beach {
  final String id, name, city, photoUrl;
  final BeachRisk risk;
  final String lastUpdate;
  final double erosionMeters;   // negative number
  final double lat, lng;
  const Beach({...});
}
```

For now use a hard-coded `lib/data/mock_beaches.dart` with the 6 beaches in the
prototype (Sayada, Skanes, Sousse, Teboulba, Bekalta, Îles Kuriat). When the
backend is ready, replace with an `Api.fetchBeaches()` call returning the same
type.

Also: `lib/models/signalement.dart` (type, when, status, thumbUrl) and
`lib/models/alerte.dart` (beachName, message, time, risk).

---

## 4. Shared widgets

Build these once in `lib/widgets/` and reuse everywhere:

### `RiskPill`
Pill with colored dot + label. Variants `small` / `medium`.
- Reads from `BeachRisk` to pick background / ink / dot colors.

### `SectionTitle`
`Row` with left title (17/700) and optional right "Voir tout" trailing button
(13/600 in teal).

### `BottomNav`  — **shared by Home / Carte / Alertes / Profil**
- White, top border, ~82 px tall, 24 px bottom safe-area padding.
- 5 children: Accueil, Carte, **center FAB**, Alertes, Profil.
- Center FAB: 58 px circle, teal, white "+" icon, sits 28 px above nav top
  with a 5 px white halo to "punch" through the border.
- Tapping FAB opens an `ActionSheet` (modal bottom sheet with 3 entries:
  Ajouter une photo, Signaler un problème, Relevé terrain).

### `AppShell`
The persistent scaffold. Holds the `BottomNav` and switches between Home/Carte/
Alertes/Profil with `IndexedStack` (preserve each screen's scroll position).
`BeachDetailScreen` is **pushed** on top, hiding the nav.

---

## 5. Screen specs

### 5.1 Accueil (Home)

```
┌─ App bar (transparent, ink icons) ──────────────┐
│  [☰]                                      [🔔•] │
├─────────────────────────────────────────────────┤
│  Bonjour !  🌊                                  │
│  Protégeons nos plages tunisiennes              │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │  [beach photo, 16:9]                    │    │
│  │  Monastir                               │    │
│  │  Plage de Skanes        [● Risque modéré] │  │  ← tap → BeachDetailScreen('skanes')
│  └─────────────────────────────────────────┘    │
│                                                 │
│  État des plages                    Voir tout   │
│  ┌──────┐ ┌──────┐ ┌──────┐                    │
│  │ 12   │ │ 8    │ │ 5    │  ← StatusCard       │
│  │stable│ │modér.│ │élevé │     (green/amber/red bg)
│  │  ≋   │ │  ≋   │ │  ≋   │                    │
│  └──────┘ └──────┘ └──────┘                    │
│                                                 │
│  Actions rapides                                │
│  [📷] [⚠] [🗺] [🎓]                              │
│  Ajouter Signaler Voir   Apprendre              │
│   photo problème carte                          │
└─────────────────────────────────────────────────┘
```

**Featured card** = aspect-ratio 16:9 image with a dark→transparent vertical
gradient overlay; city/beach text bottom-left in white; risk pill bottom-right.

**StatusCard** — bold count (30/800), label (12/500), small wave glyph in
bottom-right corner. Background colors come from the risk palette.

**Quick action tile** — 46 px tinted square (12 % tint of accent), centered
icon, 11 px caption below. Four colors: teal, amber, green, purple.

### 5.2 Carte (Map)

- Full-bleed **teal app bar** (status bar in light brightness, "Carte des
  plages" centered, hamburger left, filter right).
- White search input below ("Rechercher une plage…") + locate button (circle,
  white, teal icon).
- Below: the **map view**.

**Map implementation:** use `flutter_map: ^7.0.2` with `ESRI World Imagery`
tiles (free, no API key):

```
https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}
```

Center on Monastir (35.7643, 10.8113), zoom 13. Plot one `Marker` per beach
colored by risk. On tap → set `selectedBeachId`. When a beach is selected,
overlay a **floating info card** anchored above the marker (use `flutter_map`'s
`PopupMarkerLayer`, or stack a custom card with `LatLngBounds.contains` math).

**Info card** — 230 px wide, white, 14 radius, drop shadow. Contents:
beach name (15/700), city (13/500 ink50), `RiskPill` small, "Dernière mise à jour:
{date}" (11/500 ink50), trailing chev → push `BeachDetailScreen`. Triangle tail
points down to the marker.

**Legend** — pinned 56 px above the bottom nav so the FAB doesn't cover it.
Three `LegendDot`s (Stable / Modéré / Élevé) spaced evenly. White card, radius 14.

**Locate FAB** — 46 px white circle with teal crosshair icon, anchored
bottom-right, 92 px above nav (clear of legend).

### 5.3 Détails de la plage

Pushed route (`Navigator.push`). Hides the bottom nav.

```
┌─ Teal app bar (sticky) ──────────────────────┐
│  [←]      Détails de la plage         [↗]    │
├──────────────────────────────────────────────┤
│  [Hero photo, 200 px, bottom gradient]       │
├──────────────────────────────────────────────┤
│  Plage de Skanes              ● Risque modéré│
│  📍 Monastir                                 │
├──────────────────────────────────────────────┤
│  [Aperçu] [Évolution] [Signalements] [Infos] │  ← TabBar
├──────────────────────────────────────────────┤
│  (tab content)                               │
└──────────────────────────────────────────────┘
```

**TabBar** — 4 columns, icon on top (20 px), label below (12 px). Active tab
has a 2.5 px teal underline and teal-bold label.

**Tab: Aperçu**
- `SectionTitle("Évolution du trait de côte", trailing "Voir plus")`
- Two side-by-side photo cards (Mai 2023 / Mai 2024), 4:3, label pill top-left
  in each. **Center overlay** circle button (white, 36 px, teal `↔` icon) —
  invokes the before/after slider when tapped.
- **Recul card**: teal-soft pill row — ruler icon in white square (left), then
  "Recul estimé / **− 3.2 m** / Sur les 12 derniers mois".
- `SectionTitle("Signalements récents", trailing "Voir tout")` with one preview
  row (thumb + type + date + status pill).

**Tab: Évolution**
- Sparkline chart of cumulative recul over 12 months (teal line, gradient fill).
  Use `fl_chart: ^0.69.0` (`LineChart`).
- 2×2 KPI grid: Total reculé, Vitesse, Pire mois, Confiance.

**Tab: Signalements**
- Full list of `SignalementRow`s.

**Tab: Infos**
- Key/value table inside a card: Région, Longueur, Type, Accès public, Dernier
  relevé, Source données.

### 5.4 Alertes

Simple scrollable list. Header: large title "Alertes" + "5 nouvelles · 2
nécessitent une action".

Each `AlerteRow`: tinted square icon (38 px) using risk color, then beach name
+ message + relative time. Tap → push `BeachDetailScreen(beachId)`.

### 5.5 Profil

- Centered avatar (92 px circle, teal gradient, initials).
- Stats row (3 columns: Signalements / Photos / Plages suivies) inside a white
  card with dividers.
- Settings list (5 rows: Notifications, Mes plages suivies, Centre
  d'apprentissage, À propos, Paramètres). Each row: tinted-teal icon (34 px),
  label, optional hint (right), chev. Use `ListTile` with custom leading.

---

## 6. Migration plan

Execute in this order. Each step is independently testable.

1. **Theme refresh** — replace `AppColors` and `AppText` in
   `lib/theme/app_theme.dart` with the tokens in §2. Add `google_fonts` to
   `pubspec.yaml`, wire `GoogleFonts.plusJakartaSansTextTheme(...)` into
   `ThemeData.textTheme`. Switch `MaterialApp.theme` from `ColorScheme.dark` to
   `ColorScheme.light(primary: AppColors.teal, surface: AppColors.bg)`.
2. **Models & mock data** (§3) — pure Dart, no UI yet.
3. **Shared widgets** (§4) — `RiskPill`, `SectionTitle`, `StatusCard`,
   `QuickActionTile`, `LegendDot`. Drop them in `lib/widgets/`.
4. **AppShell** — new file `lib/screens/app_shell.dart`. Stack-based, hosts
   `BottomNav` + `IndexedStack` of the four root screens (placeholder containers
   for now). Add route `/app` in `main.dart` and route from `LoginScreen` on
   submit success.
5. **Home redesign** — rewrite `home_screen.dart` matching §5.1. Old
   "challenges/login" content goes away. Keep no animations on first pass —
   wire `flutter_animate: ^4.5.0` later if desired (`.animate().fadeIn().slideY()`
   on the featured card and stat cards is enough).
6. **Map screen** — add `flutter_map` + `latlong2` to `pubspec.yaml`. Build
   §5.2. The marker popup info card is the trickiest piece; use
   `flutter_map_marker_popup: ^7.0.0` for the anchored popup.
7. **Beach detail** — §5.3. The four tabs share the same scaffold; use
   `DefaultTabController(length: 4)` + `TabBar` + `TabBarView`. Comparison
   slider can start as static (two `Image.network`s side-by-side with a center
   chip); upgrade to `before_after: ^3.0.0` later.
8. **Alertes & Profil** — §5.4, §5.5. Both are read-only lists.
9. **Bottom-sheet "+" action** — `showModalBottomSheet(useSafeArea: true,
   isScrollControlled: false)`. Three rounded `ListTile`-style rows; rounded
   top corners 24.
10. **Polish pass** — empty states, loading skeletons, dark-mode pass (optional
    for this milestone).

---

## 7. Packages to add to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  flutter_map_marker_popup: ^7.0.0
  fl_chart: ^0.69.0
  cached_network_image: ^3.4.1
  flutter_animate: ^4.5.0   # optional, for entry animations
  before_after: ^3.0.0      # optional, evolution comparison slider
```

Use `cached_network_image` for every `Image.network` (faster repeat loads,
graceful failures).

---

## 8. Acceptance checklist

Before declaring this milestone done, every box must tick:

- [ ] Splash → Login → AppShell flow works (replace, not push).
- [ ] AppShell shows the correct bottom nav on Home/Carte/Alertes/Profil and
      hides it on BeachDetail.
- [ ] FAB is centered, lifts above the nav, opens the action sheet.
- [ ] Risk pill renders the right color trio for all three states.
- [ ] Featured beach card → BeachDetail navigation works.
- [ ] Map shows 6 markers in correct risk colors on Monastir coastline.
- [ ] Tapping a marker shows the floating info card; tapping the chev pushes
      BeachDetail.
- [ ] Map legend never overlaps the FAB (test on iPhone SE size and tall
      devices).
- [ ] Detail tabs switch cleanly; sparkline draws on Évolution.
- [ ] Alertes & Profil scroll correctly; safe-area honored top and bottom.
- [ ] Hot-reload survives a tab switch (no state lost on Home).
- [ ] `flutter analyze` clean. No unused imports left over from the old home.

---

## 9. Things to ask the user before / during implementation

- **Auth flow** — current login is offline mock; should `/app` require a logged
  user, or proceed as guest?
- **Real beach data** — is there an API to call, or do we ship with mock data
  for this milestone?
- **Localisation** — French only for now? Should we set up `flutter_localizations`
  + `intl` even if we only have one locale, to make adding Arabic painless
  later?
- **Map tiles** — ESRI free tier is fine for development; for production traffic
  Mapbox or MapTiler is recommended. Do you have an account?
- **Photo upload** — "Ajouter une photo" sheet entry: do you want camera +
  gallery picker via `image_picker`, or just camera?

