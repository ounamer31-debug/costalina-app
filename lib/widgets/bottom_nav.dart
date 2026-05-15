import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import 'costalina_mark.dart';
import 'hair_line.dart';

class CostalinaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  const CostalinaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final bottom = MediaQuery.of(context).padding.bottom;
    final totalHeight = 62.0 + (bottom > 0 ? bottom : 22.0);

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(color: CColors.sand),
              child: Column(
                children: [
                  const HairLine(color: CColors.tealLine),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 0),
                      child: Row(
                        children: [
                          _NavItem(icon: LucideIcons.home, label: s.navHome,    active: currentIndex == 0, onTap: () => onTap(0)),
                          _NavItem(icon: LucideIcons.map,  label: s.navMap,     active: currentIndex == 1, onTap: () => onTap(1)),
                          const Expanded(child: SizedBox()),
                          _NavItem(icon: LucideIcons.bell, label: s.navAlertes, active: currentIndex == 2, onTap: () => onTap(2)),
                          _NavItem(icon: LucideIcons.user, label: s.navProfil,  active: currentIndex == 3, onTap: () => onTap(3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onFabTap,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: CColors.tealDark,
                    border: Border.all(color: CColors.sand, width: 3),
                    boxShadow: CShadows.navCenter,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CostalinaMark(size: 22, color: Colors.white),
                      const SizedBox(height: 1),
                      Text(
                        s.navAdd,
                        style: CType.eyebrow(size: 7, tracking: 0.18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? CColors.tealDark : CColors.grey;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: CType.eyebrow(
                size: 9,
                tracking: 0.18,
                color: color,
                w: active ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            if (active)
              Container(width: 14, height: 1, color: CColors.tealDark)
            else
              const SizedBox(height: 1),
          ],
        ),
      ),
    );
  }
}