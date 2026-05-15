import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/beach.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Costalina design tokens — light/dark aware via CoastPalette
// ─────────────────────────────────────────────────────────────────────────────

class CColors {
  // Brand teal scale — fixed, same in both modes
  static const teal        = Color(0xFF5BBCB0);
  static const tealDark    = Color(0xFF3D9E93);
  static const tealDeep    = Color(0xFF1D504B);
  static const tealPale    = Color(0xFFA8DDD8);
  static const tealBg      = Color(0xFFE8F7F5);
  static const tealLine    = Color(0x385BBCB0);
  static const tealLineSoft= Color(0x245BBCB0);

  // Light mode surfaces
  static const sand        = Color(0xFFF5F0E8);
  static const sandDark    = Color(0xFFE0D8C8);
  static const white       = Color(0xFFFFFFFF);

  // Ink
  static const ink         = Color(0xFF1A2E2C);
  static const inkSoft     = Color(0xFF3A5450);
  static const grey        = Color(0xFF7A9490);

  // Risk semantics
  static const greenInk    = Color(0xFF1D9E75);
  static const greenBg     = Color(0x1A1D9E75);
  static const greenDot    = Color(0xFF1D9E75);
  static const amberInk    = Color(0xFFC4804A);
  static const amberBg     = Color(0x1FC4804A);
  static const amberDot    = Color(0xFFC4804A);
  static const redInk      = Color(0xFFA84848);
  static const redBg       = Color(0x1AA84848);
  static const redDot      = Color(0xFFA84848);

  static Color riskInk(BeachRisk r) {
    switch (r) {
      case BeachRisk.stable: return greenInk;
      case BeachRisk.modere: return amberInk;
      case BeachRisk.eleve:  return redInk;
    }
  }
  static Color riskBg(BeachRisk r) {
    switch (r) {
      case BeachRisk.stable: return greenBg;
      case BeachRisk.modere: return amberBg;
      case BeachRisk.eleve:  return redBg;
    }
  }
  static Color riskDot(BeachRisk r) {
    switch (r) {
      case BeachRisk.stable: return greenDot;
      case BeachRisk.modere: return amberDot;
      case BeachRisk.eleve:  return redDot;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Semantic palette — light and dark instances
// ─────────────────────────────────────────────────────────────────────────────

class CoastPalette {
  final Color bg;
  final Color surface;
  final Color surfaceSoft;
  final Color line;
  final Color lineSoft;
  final Color ink;
  final Color inkSoft;
  final Color grey;
  final Color teal;
  final Color tealDark;
  final Color tealBg;
  final Color navBg;

  const CoastPalette._({
    required this.bg,
    required this.surface,
    required this.surfaceSoft,
    required this.line,
    required this.lineSoft,
    required this.ink,
    required this.inkSoft,
    required this.grey,
    required this.teal,
    required this.tealDark,
    required this.tealBg,
    required this.navBg,
  });

  static const light = CoastPalette._(
    bg:          Color(0xFFF5F0E8),
    surface:     Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFE8F7F5),
    line:        Color(0x385BBCB0),
    lineSoft:    Color(0x245BBCB0),
    ink:         Color(0xFF1A2E2C),
    inkSoft:     Color(0xFF3A5450),
    grey:        Color(0xFF7A9490),
    teal:        Color(0xFF5BBCB0),
    tealDark:    Color(0xFF3D9E93),
    tealBg:      Color(0xFFE8F7F5),
    navBg:       Color(0xFFF5F0E8),
  );

  static const dark = CoastPalette._(
    bg:          Color(0xFF0F1918),
    surface:     Color(0xFF172221),
    surfaceSoft: Color(0xFF1D2D2B),
    line:        Color(0x525BBCB0),
    lineSoft:    Color(0x305BBCB0),
    ink:         Color(0xFFF0EDE8),
    inkSoft:     Color(0xFFBDD4D1),
    grey:        Color(0xFF7A9490),
    teal:        Color(0xFF6FCCC2),
    tealDark:    Color(0xFF5BBCB0),
    tealBg:      Color(0xFF1C2E2C),
    navBg:       Color(0xFF0A1413),
  );

  Color get ink70 => ink.withValues(alpha: 0.70);
  Color get ink50 => ink.withValues(alpha: 0.50);
  Color get ink20 => ink.withValues(alpha: 0.20);

  Color riskBg(BeachRisk r)  => CColors.riskBg(r);
  Color riskInk(BeachRisk r) => CColors.riskInk(r);
  Color riskDot(BeachRisk r) => CColors.riskDot(r);
}

/// Reads the palette from the current theme brightness.
CoastPalette palette(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? CoastPalette.dark
        : CoastPalette.light;

// Legacy alias used by older code
typedef ShimPalette = CoastPalette;

// ─────────────────────────────────────────────────────────────────────────────
// Typography
// ─────────────────────────────────────────────────────────────────────────────

class CType {
  static TextStyle serifDisplay({
    double size = 30,
    Color color = CColors.ink,
    bool italic = false,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: color,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        height: 1.12,
        letterSpacing: -0.2,
      );

  static TextStyle body({
    double size = 13,
    Color color = CColors.inkSoft,
    FontWeight w = FontWeight.w300,
  }) =>
      GoogleFonts.jost(
        fontSize: size,
        color: color,
        fontWeight: w,
        height: 1.65,
        letterSpacing: 0.1,
      );

  static TextStyle eyebrow({
    double size = 10,
    double tracking = 0.32,
    Color color = CColors.tealDark,
    FontWeight w = FontWeight.w500,
  }) =>
      GoogleFonts.jost(
        fontSize: size,
        fontWeight: w,
        color: color,
        letterSpacing: tracking * size,
        height: 1.2,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shadows
// ─────────────────────────────────────────────────────────────────────────────

class CShadows {
  static const mapInfoCard = [
    BoxShadow(blurRadius: 36, offset: Offset(0, 14), spreadRadius: -10, color: Color(0x592E2C1A)),
  ];
  static const navCenter = [
    BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x991D504B)),
  ];
}

class AppRadius {
  static const control   = 2.0;
  static const card      = 0.0;
  static const cardLarge = 0.0;
  static const hero      = 0.0;
  static const pill      = 999.0;
}

class AppShadows {
  static const card     = <BoxShadow>[];
  static const elevated = CShadows.mapInfoCard;
  static const nav      = <BoxShadow>[];
}

// Legacy
class AppColors {
  static const teal     = CColors.teal;
  static const tealDark = CColors.tealDark;
  static const bgDark   = CColors.tealDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme builder
// ─────────────────────────────────────────────────────────────────────────────

ThemeData buildCostalinaTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? CoastPalette.dark : CoastPalette.light;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary:    p.tealDark,
      onPrimary:  const Color(0xFFFFFFFF),
      secondary:  p.teal,
      onSecondary: const Color(0xFFFFFFFF),
      surface:    p.surface,
      onSurface:  p.ink,
      error:      CColors.redInk,
      onError:    const Color(0xFFFFFFFF),
    ),
    textTheme: GoogleFonts.jostTextTheme().apply(
      bodyColor:    p.inkSoft,
      displayColor: p.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.ink,
      elevation: 0,
      centerTitle: true,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.tealDark : p.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.tealBg : p.lineSoft,
      ),
    ),
  );
}