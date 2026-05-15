import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/beach.dart';

// Star clip polygon from the handoff spec.
class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width;
    final h = s.height;
    // 10-vertex star: (50,0) (61,35) (98,35) (68,57) (79,91) (50,70) (21,91) (32,57) (2,35) (39,35)
    final pts = [
      Offset(0.50 * w, 0.00 * h),
      Offset(0.61 * w, 0.35 * h),
      Offset(0.98 * w, 0.35 * h),
      Offset(0.68 * w, 0.57 * h),
      Offset(0.79 * w, 0.91 * h),
      Offset(0.50 * w, 0.70 * h),
      Offset(0.21 * w, 0.91 * h),
      Offset(0.32 * w, 0.57 * h),
      Offset(0.02 * w, 0.35 * h),
      Offset(0.39 * w, 0.35 * h),
    ];
    return Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..addPolygon(pts, true);
  }

  @override
  bool shouldReclip(_StarClipper _) => false;
}

class StarGauge extends StatelessWidget {
  final int severity;
  final Color color;
  final double size;
  final double gap;

  const StarGauge({
    super.key,
    required this.severity,
    required this.color,
    this.size = 6,
    this.gap = 4,
  });

  factory StarGauge.fromRisk(BeachRisk risk, {double size = 6, double gap = 4}) =>
      StarGauge(
        severity: risk.severity,
        color: CColors.riskDot(risk),
        size: size,
        gap: gap,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < severity;
        return Padding(
          padding: EdgeInsets.only(right: i < 4 ? gap : 0),
          child: ClipPath(
            clipper: _StarClipper(),
            child: SizedBox(
              width: size,
              height: size,
              child: ColoredBox(
                color: filled ? color : const Color(0x2E1A2E2C),
              ),
            ),
          ),
        );
      }),
    );
  }
}

extension BeachRiskSeverity on BeachRisk {
  int get severity {
    switch (this) {
      case BeachRisk.stable: return 1;
      case BeachRisk.modere: return 3;
      case BeachRisk.eleve:  return 5;
    }
  }
}