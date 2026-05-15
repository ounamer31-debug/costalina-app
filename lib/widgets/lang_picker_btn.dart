import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_strings.dart';
import '../main.dart' show localeNotifier;
import '../theme/app_theme.dart';
import 'hair_line.dart';

/// Compact globe icon that opens the language picker sheet.
class LangPickerBtn extends StatelessWidget {
  final Color? color;
  const LangPickerBtn({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showLangPicker(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(LucideIcons.globe,
            size: 18, color: color ?? CColors.tealDark),
      ),
    );
  }
}

/// Shows the language picker modal bottom sheet.
void showLangPicker(BuildContext context) {
  final s = AppStrings.current;
  showModalBottomSheet(
    context: context,
    backgroundColor: CColors.sand,
    shape: const RoundedRectangleBorder(),
    builder: (_) => _LangSheet(title: s.chooseLanguage),
  );
}

class _LangSheet extends StatelessWidget {
  final String title;
  const _LangSheet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
          child: Row(
            children: [
              Text(title, style: CType.serifDisplay(size: 20, color: CColors.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        for (final lang in langOptions) ...[
          _LangRow(lang: lang),
          const HairLine(color: CColors.tealLineSoft),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LangRow extends StatelessWidget {
  final LangOption lang;
  const _LangRow({required this.lang});

  @override
  Widget build(BuildContext context) {
    final isActive = localeNotifier.value.languageCode == lang.code;
    return GestureDetector(
      onTap: () {
        localeNotifier.value = Locale(lang.code);
        Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(lang.nativeName,
                  style: CType.serifDisplay(
                      size: 17,
                      color: isActive ? CColors.tealDark : CColors.ink)),
            ),
            if (isActive)
              const Icon(LucideIcons.check, size: 16, color: CColors.tealDark),
          ],
        ),
      ),
    );
  }
}