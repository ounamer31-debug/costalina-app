import 'package:flutter/material.dart';
import '../models/beach.dart';
import '../theme/app_theme.dart';

enum RiskPillSize { small, medium }

class RiskPill extends StatelessWidget {
  final BeachRisk risk;
  final RiskPillSize size;
  final bool useShort;

  const RiskPill({
    super.key,
    required this.risk,
    this.size = RiskPillSize.medium,
    this.useShort = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final small = size == RiskPillSize.small;
    final fontSize = small ? 10.5 : 12.0;
    final hPad = small ? 8.0 : 10.0;
    final vPad = small ? 4.0 : 6.0;
    final dotSize = small ? 6.0 : 8.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: p.riskBg(risk),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: p.riskDot(risk),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: small ? 5 : 6),
          Text(
            useShort ? risk.short : risk.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: p.riskInk(risk),
            ),
          ),
        ],
      ),
    );
  }
}
