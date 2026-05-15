import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double tracking;
  final FontWeight weight;

  const Eyebrow(
    this.text, {
    super.key,
    this.color = CColors.tealDark,
    this.size = 10,
    this.tracking = 0.32,
    this.weight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: CType.eyebrow(size: size, tracking: tracking, color: color, w: weight),
      );
}