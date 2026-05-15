import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows the real Costalina JPG logo (starfish + palm + waves + wordmark).
/// On dark/teal backgrounds set [onDark] = true to wrap in a white card.
class CostalinaLogo extends StatelessWidget {
  final double size;
  final bool onDark;

  const CostalinaLogo({super.key, this.size = 80, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/brand/costalina-logo.jpg',
      width: size,
      height: size,
      fit: BoxFit.contain,
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