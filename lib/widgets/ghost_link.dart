import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GhostLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GhostLink({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Ensure 44 px minimum tap target vertically
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: CType.eyebrow(size: 10, tracking: 0.22, color: CColors.tealDark),
            ),
            const SizedBox(height: 3),
            Container(height: 1, color: CColors.tealPale),
          ],
        ),
      ),
    );
  }
}