import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CostalinaLogo extends StatelessWidget {
  final double size;
  final bool onDark;
  final Color? bgColor;

  const CostalinaLogo({super.key, this.size = 80, this.onDark = false, this.bgColor});

  @override
  Widget build(BuildContext context) {
    // Multiply blends the JPG's white pixels with the background color,
    // making them visually transparent on any solid background.
    final bg = bgColor ?? palette(context).bg;
    final img = Image.asset(
      'assets/brand/costalina-logo.jpg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: bg,
      colorBlendMode: BlendMode.multiply,
    );
    if (!onDark) return img;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CColors.white,
        border: Border.all(color: CColors.tealLine, width: 1),
      ),
      child: img,
    );
  }
}