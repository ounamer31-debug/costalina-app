import 'package:flutter/material.dart';
import 'eyebrow.dart';
import 'serif_title.dart';
import 'hair_line.dart';

class SectionHead extends StatelessWidget {
  final String kicker;
  final String title;
  final String? italic;
  final Widget? trailing;
  final bool divider;
  final double titleSize;

  const SectionHead({
    super.key,
    required this.kicker,
    required this.title,
    this.italic,
    this.trailing,
    this.divider = true,
    this.titleSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(kicker),
                    const SizedBox(height: 8),
                    SerifTitle(title, italic: italic, size: titleSize),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          if (divider) ...[
            const SizedBox(height: 10),
            const HairLine(),
          ],
        ],
      ),
    );
  }
}