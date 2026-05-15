import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'eyebrow.dart';
import 'serif_title.dart';
import 'hair_line.dart';

void showCostalinaActionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C1A2E2C),
    isScrollControlled: true,
    builder: (_) => const _ActionSheetBody(),
  );
}

class _ActionSheetBody extends StatelessWidget {
  const _ActionSheetBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CColors.sand,
        border: Border(top: BorderSide(color: CColors.tealLine, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 2,
              color: CColors.tealLine,
              margin: const EdgeInsets.only(bottom: 18),
            ),
          ),
          const Eyebrow('Contribuer'),
          const SizedBox(height: 8),
          const SerifTitle('Nouvelle ', italic: 'observation', size: 24),
          const SizedBox(height: 18),
          // Bordered action list
          Container(
            decoration: BoxDecoration(
              color: CColors.white,
              border: Border.all(color: CColors.tealLine, width: 1),
            ),
            child: Column(
              children: const [
                _SheetAction(
                  icon: LucideIcons.camera,
                  title: 'Ajouter une photo',
                  sub: "Capturez l'état actuel de la plage",
                ),
                _SheetAction(
                  icon: LucideIcons.alertTriangle,
                  title: 'Signaler un problème',
                  sub: 'Érosion, pollution, construction…',
                ),
                _SheetAction(
                  icon: LucideIcons.ruler,
                  title: 'Relevé terrain',
                  sub: 'Mesure manuelle du trait de côte',
                  last: true,
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final bool last;

  const _SheetAction({
    required this.icon,
    required this.title,
    required this.sub,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: CColors.tealDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: CType.serifDisplay(size: 17)),
                    const SizedBox(height: 3),
                    Text(sub, style: CType.body(size: 11, color: CColors.grey)),
                  ],
                ),
              ),
              Text(
                '→',
                style: CType.body(size: 16, color: CColors.tealDark, w: FontWeight.w300),
              ),
            ],
          ),
        ),
        if (!last) const HairLine(),
      ],
    );
  }
}