# CoastWatch — project notes

Flutter prototype for a Tunisian beach erosion app. **Design-only**: no real backend, no real auth, no business logic. Treat every screen as a visual mockup wired with mock data.

## Status

This is a **prototype**. The user asked for design fidelity, not features. Don't add validation, API calls, or state management unless explicitly asked. If a tap target should do something "real," wire it to navigate or no-op — don't invent backend behavior.

## Flow

`/` (Splash) → `/login` → `/app` (AppShell with bottom nav).

- Splash auto-navigates to `/login` after ~3s.
- Login submit / social buttons all just `pushReplacementNamed('/app')`. No validation.
- `AppShell` ([lib/screens/app_shell.dart](lib/screens/app_shell.dart)) holds an `IndexedStack` of Home / Carte / Alertes / Profil. `BeachDetailScreen` is pushed on top (hides nav).
- The bottom-nav center "+" FAB opens `showCoastActionSheet` (3 stub actions).

## Design tokens & dark mode

All in [lib/theme/app_theme.dart](lib/theme/app_theme.dart). Theme is driven by a `CoastPalette` `ThemeExtension` with two instances: `CoastPalette.light` and `CoastPalette.dark`. `buildCoastTheme(Brightness)` injects the matching one into `ThemeData.extensions`. Font: Plus Jakarta Sans via `google_fonts`.

**Reading colors in widgets:** `final p = palette(context);` then use `p.bg`, `p.surface`, `p.surfaceSoft`, `p.line`, `p.ink`, `p.ink70/50/20`, `p.teal`, `p.tealDark`, `p.tealSoft`, `p.navBg`. Never hardcode `Colors.white`, `Color(0xFFF5F7F8)`, etc., for semantic surfaces — only for things that are intentionally fixed (image overlays, the brand teal AppBar's white text, etc.).

**Risk colors** are also on the palette: `p.riskBg(risk)`, `p.riskInk(risk)`, `p.riskDot(risk)`. The `BeachRiskX` extension only owns labels (`.label`, `.short`) now — *not* colors. Don't add color getters back to it; they'd be brightness-blind.

**Switching modes:** `themeModeNotifier` (a `ValueNotifier<ThemeMode>` exported from [lib/main.dart](lib/main.dart)) drives `MaterialApp.themeMode` via `ValueListenableBuilder`. The toggle UI lives in `_ThemeToggleRow` inside [lib/screens/profil_screen.dart](lib/screens/profil_screen.dart). Defaults to light. No persistence — flips reset on app restart (fine for a prototype; add `shared_preferences` if asked).

`AppColors` static class is kept only as legacy compat (used by `splash_screen.dart` which intentionally stays brand-teal in both modes). New code should always go through `palette(context)`.

## Mock data

[lib/data/mock_beaches.dart](lib/data/mock_beaches.dart) — 6 beaches around Monastir, plus `mockSignalements` and `mockAlertes`. Every screen reads from these constants. Photo URLs are Unsplash. If the user wants to swap to a real API, the replacement point is here — `Beach`, `Signalement`, `Alerte` are plain data classes.

## Shared widgets

Reuse these — don't re-roll:
- `RiskPill` (small/medium, optional short label)
- `SectionTitle` (title + optional "Voir tout" trailing)
- `StatusCard`, `QuickActionTile`, `LegendDot`
- `CoastBottomNav` (the punched-through FAB lives inside it — `Stack` with `clipBehavior: Clip.none` and a `Positioned(top: -28)`)

## Map screen

Uses `flutter_map` 7 with free ESRI World Imagery tiles (no API key). If the user wants prod-grade tiles, switch to Mapbox/MapTiler. The info card is a manual `Positioned` overlay, not `flutter_map_marker_popup` (the dep is in pubspec but unused — fine to remove if asked).

## GPS / geolocation

Real, not stub. `geolocator: ^13.0.1` is wired up via [lib/services/location_service.dart](lib/services/location_service.dart), which returns a `LocationResult` carrying a `LocationStatus` enum (`ok`/`denied`/`deniedForever`/`serviceDisabled`) plus the `Position`. Callers should branch on status and surface the right UI — don't just `try/catch` and assume failure means denial. `LocationService.watch()` is a continuous stream (10 m distance filter); [lib/screens/map_screen.dart](lib/screens/map_screen.dart) subscribes only **after** the first successful fix so we don't burn battery on a denied permission.

**Permissions are already declared:**
- Android: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
- iOS: `NSLocationWhenInUseUsageDescription` in [ios/Runner/Info.plist](ios/Runner/Info.plist) (French copy)

The locate FAB on the map (a) requests permission, (b) centers on user, (c) starts the position stream. The user dot is a teal-with-halo `Marker` rendered in the same `MarkerLayer` as beach markers. Map recentering uses `MapController.move(LatLng, zoom)` — there's one `MapController` instance owned by `_MapScreenState`. If you add other recentering triggers (e.g. tapping a beach in a list), reuse that controller, don't spin up a new one.

**`LocationService` is injectable for tests.** `LocationService` is an abstract class with a mutable `static instance` field; production code is `_RealLocationService`. The map screen calls `LocationService.instance.getCurrent()` / `.watch()`. To test GPS behavior without hitting Geolocator, swap `LocationService.instance` with a fake — see [test/gps_test.dart](test/gps_test.dart) for the pattern (4 tests covering ok / denied / serviceDisabled / live-stream subscription). Don't make `LocationService` static-only again; the test seam is the whole point of the abstract-class indirection.

**Web tile perf:** the map uses `CancellableNetworkTileProvider` from `flutter_map_cancellable_tile_provider`. Without it, flutter_map prints a perf warning on every tile fetch on web. Keep it.

## Known issues / non-issues

- `flutter analyze` reports ~22 `unnecessary_underscores` info lints (`(_, __)` style in builder callbacks). Cosmetic. Don't bulk-fix unless asked.
- Splash uses `Future.delayed` chains for staggered animations — works, but `flutter_animate` is in pubspec if a rewrite is wanted.
- The old "challenges/landing page" home is gone. If the user references it, they mean the pre-redesign version (see git history).

## Adding a new screen

1. Drop it in `lib/screens/`.
2. If it's a root tab, add it to `AppShell`'s `IndexedStack` and a nav item to `CoastBottomNav` (currently hardcoded to 4 items + FAB slot).
3. If it's a pushed detail, just `Navigator.push` from wherever — it'll cover the nav automatically.
4. Use existing widgets and theme tokens. Page padding is 20 px horizontal.

## Handoff source

The original design spec lives in [.handoff-zip/coastwatch/project/Claude Code Handoff.md](.handoff-zip/coastwatch/project/Claude%20Code%20Handoff.md). Re-read it before any redesign work — it has the pixel-level intent (radii, shadows, screen layouts) that this CLAUDE.md only summarizes.
