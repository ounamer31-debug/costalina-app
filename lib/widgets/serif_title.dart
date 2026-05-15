import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Serif heading with an optional italicised emphasis word in tealDark.
///
/// Usage:
///   SerifTitle('Veillons sur nos\n', italic: 'plages', trail: '.', size: 34)
class SerifTitle extends StatelessWidget {
  final String text;
  final String? italic;
  final String trail;
  final double size;
  final Color color;

  const SerifTitle(
    this.text, {
    super.key,
    this.italic,
    this.trail = '',
    this.size = 30,
    this.color = CColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    if (italic == null) {
      return Text(text + trail, style: CType.serifDisplay(size: size, color: color));
    }
    return Text.rich(
      TextSpan(
        style: CType.serifDisplay(size: size, color: color),
        children: [
          TextSpan(text: text),
          TextSpan(
            text: italic,
            style: CType.serifDisplay(size: size, color: CColors.tealDark, italic: true),
          ),
          if (trail.isNotEmpty) TextSpan(text: trail),
        ],
      ),
    );
  }
}