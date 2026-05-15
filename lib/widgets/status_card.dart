import 'package:flutter/material.dart';
import '../models/beach.dart';
import '../theme/app_theme.dart';

class StatusCard extends StatelessWidget {
  final int count;
  final String label;
  final BeachRisk risk;

  const StatusCard({
    super.key,
    required this.count,
    required this.label,
    required this.risk,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: p.riskBg(risk),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: p.riskInk(risk),
                  height: 1.0,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: p.riskInk(risk),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.waves_rounded,
              size: 22,
              color: p.riskDot(risk).withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
