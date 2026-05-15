import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../models/beach.dart';

enum RiskTagSize { sm, md }

class RiskTag extends StatelessWidget {
  final BeachRisk risk;
  final bool light;
  final RiskTagSize size;

  const RiskTag(this.risk, {super.key, this.light = false, this.size = RiskTagSize.md});

  @override
  Widget build(BuildContext context) {
    final fs  = size == RiskTagSize.sm ? 9.0  : 10.0;
    final py  = size == RiskTagSize.sm ? 3.0  : 5.0;
    final px  = size == RiskTagSize.sm ? 8.0  : 10.0;
    final fg  = light ? Colors.white         : CColors.riskInk(risk);
    final bg  = light ? const Color(0x26FFFFFF) : CColors.riskBg(risk);
    final dot = light ? Colors.white         : CColors.riskDot(risk);
    final borderColor = light
        ? const Color(0x66FFFFFF)
        : CColors.riskDot(risk).withValues(alpha: 0.40);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            AppStrings.current.riskLabel(risk).toUpperCase(),
            style: CType.eyebrow(size: fs, tracking: 0.16, color: fg),
          ),
        ],
      ),
    );
  }
}