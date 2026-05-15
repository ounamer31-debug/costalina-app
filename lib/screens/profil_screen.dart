import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_strings.dart';
import '../main.dart' show tabNotifier, themeModeNotifier;
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/costalina_logo.dart';
import '../widgets/eyebrow.dart';
import '../widgets/hair_line.dart';
import '../widgets/icon_btn.dart';
import '../widgets/lang_picker_btn.dart';
import '../widgets/serif_title.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final p = palette(context);
    final user = AuthService.currentUser;
    final displayName = user?.name.isNotEmpty == true ? user!.name : (user?.email ?? 'Utilisateur');
    // Split name into first + rest for SerifTitle italic styling
    final nameParts = displayName.split(' ');
    final firstName = nameParts.first;
    final lastName  = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _TopBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(user?.email ?? 'Bénévole · Costalina'),
                  const SizedBox(height: 12),
                  SerifTitle('$firstName ', italic: lastName, size: 34),
                  const SizedBox(height: 12),
                  Text(
                    s.profilMember,
                    style: CType.body(size: 13, color: p.inkSoft),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border.all(color: CColors.tealLine, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(child: _ProfilStat(label: s.profilStatSignalements, value: '12')),
                    const HairLine(vertical: true, extent: 72, color: CColors.tealLineSoft),
                    Expanded(child: _ProfilStat(label: s.profilStatPhotos, value: '47')),
                    const HairLine(vertical: true, extent: 72, color: CColors.tealLineSoft),
                    Expanded(child: _ProfilStat(label: s.profilStatBeaches, value: '6')),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(s.profilMenuSection),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: p.surface,
                      border: Border.all(color: CColors.tealLine, width: 1),
                    ),
                    child: Column(
                      children: [
                        _DarkModeRow(s: s),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(icon: LucideIcons.bell, label: s.profilNotifications, hint: s.profilNotificationsHint,
                            onTap: () => _showNotifSheet(context)),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(icon: LucideIcons.map, label: s.profilFollowedBeaches, hint: '6',
                            onTap: () { tabNotifier.value = 1; }),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(icon: LucideIcons.graduationCap, label: s.profilLearnCenter,
                            onTap: () => _showLearnSheet(context)),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(icon: LucideIcons.info, label: s.profilAbout,
                            onTap: () => _showAboutSheet(context)),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(icon: LucideIcons.settings, label: s.profilSettings,
                            onTap: () => _showSettings(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 32, 22, 0),
              child: GestureDetector(
                onTap: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: CColors.redInk.withValues(alpha: 0.4), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.logOut, size: 15, color: CColors.redInk),
                      const SizedBox(width: 10),
                      Text(AppStrings.current.logout,
                          style: CType.eyebrow(size: 10, tracking: 0.22, color: CColors.redInk)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 40, 22, 0),
              child: Column(
                children: [
                  const CostalinaLogo(size: 56),
                  const SizedBox(height: 14),
                  const SizedBox(height: 10),
                  Text(
                    'v 2.4 · Littoral tunisien · 2026',
                    style: CType.eyebrow(
                        size: 9, tracking: 0.32, color: CColors.grey, w: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showNotifSheet(BuildContext context) {
  final s = AppStrings.current;
  final p = palette(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: palette(context).bg,
    shape: const RoundedRectangleBorder(),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
          child: Row(
            children: [
              Text(s.profilNotifications, style: CType.serifDisplay(size: 22, color: p.ink)),
              const Spacer(),
              GestureDetector(onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.x, size: 18, color: CColors.grey)),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        _NotifToggle(label: s.notifAlerts,   value: true),
        const HairLine(color: CColors.tealLineSoft),
        _NotifToggle(label: s.notifReports,  value: true),
        const HairLine(color: CColors.tealLineSoft),
        _NotifToggle(label: s.notifUpdates,  value: false),
        const SizedBox(height: 32),
      ],
    ),
  );
}

void _showLearnSheet(BuildContext context) {
  final s = AppStrings.current;
  final p = palette(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: palette(context).bg,
    shape: const RoundedRectangleBorder(),
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                Text(s.profilLearnCenter, style: CType.serifDisplay(size: 22, color: p.ink)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x, size: 18, color: CColors.grey)),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          for (final item in [
            (LucideIcons.waves,       s.learnErosion,    s.learnErosionSub),
            (LucideIcons.camera,      s.learnPhoto,      s.learnPhotoSub),
            (LucideIcons.barChart2,   s.learnRisk,       s.learnRiskSub),
            (LucideIcons.mapPin,      s.learnGPS,        s.learnGPSSub),
          ]) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 40, height: 40, color: CColors.tealBg,
                      alignment: Alignment.center,
                      child: Icon(item.$1, size: 18, color: CColors.tealDark)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$2, style: CType.serifDisplay(size: 16)),
                      const SizedBox(height: 4),
                      Text(item.$3, style: CType.body(size: 12, color: p.inkSoft)),
                    ],
                  )),
                ],
              ),
            ),
            const HairLine(color: CColors.tealLineSoft),
          ],
        ],
      ),
    ),
  );
}

void _showAboutSheet(BuildContext context) {
  final s = AppStrings.current;
  final p = palette(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: palette(context).bg,
    shape: const RoundedRectangleBorder(),
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36, height: 3,
              color: CColors.tealLine,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              children: [
                Text(s.profilAbout, style: CType.serifDisplay(size: 22, color: p.ink)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x, size: 18, color: CColors.grey)),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          // Logo + name
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
            child: Row(
              children: [
                const CostalinaLogo(size: 52),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COSTALINA',
                        style: CType.eyebrow(size: 14, tracking: 0.44, color: CColors.tealDark)),
                    const SizedBox(height: 4),
                    Text('v 2.4  ·  2026',
                        style: CType.eyebrow(size: 9, tracking: 0.28, color: CColors.grey, w: FontWeight.w300)),
                  ],
                ),
              ],
            ),
          ),
          // Mission body
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Text(s.aboutBody, style: CType.body(size: 13, color: p.inkSoft)),
          ),
          const SizedBox(height: 28),
          const HairLine(color: CColors.tealLineSoft),
          // Key stats
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Row(
              children: [
                Expanded(child: _AboutStat(value: '6', label: s.aboutStatBeaches)),
                const HairLine(vertical: true, extent: 50, color: CColors.tealLineSoft),
                Expanded(child: _AboutStat(value: '340+', label: s.aboutStatVolunteers)),
                const HairLine(vertical: true, extent: 50, color: CColors.tealLineSoft),
                Expanded(child: _AboutStat(value: '1 200+', label: s.aboutStatReports)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const HairLine(color: CColors.tealLineSoft),
          // Feature list
          for (final item in [
            (LucideIcons.waves,      s.aboutFeature1,   s.aboutFeature1Sub),
            (LucideIcons.camera,     s.aboutFeature2,   s.aboutFeature2Sub),
            (LucideIcons.shieldCheck,s.aboutFeature3,   s.aboutFeature3Sub),
          ]) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, size: 18, color: CColors.tealDark),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$2, style: CType.serifDisplay(size: 15)),
                      const SizedBox(height: 3),
                      Text(item.$3, style: CType.body(size: 12, color: p.inkSoft)),
                    ],
                  )),
                ],
              ),
            ),
            const HairLine(color: CColors.tealLineSoft),
          ],
          // Contact
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Eyebrow(s.aboutContact, size: 9, tracking: 0.26, color: p.inkSoft),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
            child: Row(
              children: [
                const Icon(LucideIcons.mail, size: 14, color: CColors.tealDark),
                const SizedBox(width: 10),
                Text('contact@costalina.tn',
                    style: CType.body(size: 13, color: CColors.tealDark)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: Row(
              children: [
                const Icon(LucideIcons.globe, size: 14, color: CColors.tealDark),
                const SizedBox(width: 10),
                Text('www.costalina.tn',
                    style: CType.body(size: 13, color: CColors.tealDark)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _NotifToggle extends StatefulWidget {
  final String label;
  final bool value;
  const _NotifToggle({required this.label, required this.value});
  @override
  State<_NotifToggle> createState() => _NotifToggleState();
}

class _NotifToggleState extends State<_NotifToggle> {
  late bool _on;
  @override
  void initState() { super.initState(); _on = widget.value; }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(
          children: [
            Expanded(child: Text(widget.label, style: CType.serifDisplay(size: 16))),
            Switch(
              value: _on,
              onChanged: (v) => setState(() => _on = v),
              activeThumbColor: CColors.tealDark,
              activeTrackColor: CColors.teal,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 56, 22, 14),
      decoration: BoxDecoration(
        color: p.bg,
        border: const Border(bottom: BorderSide(color: CColors.tealLineSoft, width: 1)),
      ),
      child: Row(
        children: [
          IconBtn(icon: const Icon(LucideIcons.arrowLeft), onTap: () {}),
          const Spacer(),
          const LangPickerBtn(),
          IconBtn(icon: const Icon(LucideIcons.settings), onTap: () => _showSettings(context)),
        ],
      ),
    );
  }
}

void _showSettings(BuildContext context) {
  final p = palette(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: palette(context).bg,
    shape: const RoundedRectangleBorder(),
    builder: (_) {
      final s = AppStrings.current;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                Text(s.profilSettings, style: CType.serifDisplay(size: 22, color: p.ink)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
                ),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          _SettingsItem(icon: LucideIcons.globe, label: s.chooseLanguage,
              onTap: () { Navigator.pop(context); showLangPicker(context); }),
          const HairLine(color: CColors.tealLineSoft),
          _SettingsItem(icon: LucideIcons.bell, label: s.profilNotifications),
          const HairLine(color: CColors.tealLineSoft),
          _SettingsItem(icon: LucideIcons.info, label: s.profilAbout),
          const SizedBox(height: 32),
        ],
      );
    },
  );
}

class _DarkModeRow extends StatelessWidget {
  final AppStrings s;
  const _DarkModeRow({required this.s});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(
            children: [
              Icon(isDark ? LucideIcons.moon : LucideIcons.sun,
                  size: 18, color: CColors.tealDark),
              const SizedBox(width: 16),
              Expanded(child: Text(s.darkMode,
                  style: CType.serifDisplay(size: 16, color: palette(context).ink))),
              Switch(
                value: isDark,
                onChanged: (v) =>
                    themeModeNotifier.value = v ? ThemeMode.dark : ThemeMode.light,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AboutStat extends StatelessWidget {
  final String value;
  final String label;
  const _AboutStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(value, style: CType.serifDisplay(size: 22, color: CColors.tealDark)),
          const SizedBox(height: 4),
          Text(label, style: CType.eyebrow(size: 8, tracking: 0.18, color: palette(context).inkSoft),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _SettingsItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: CColors.tealDark),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: CType.serifDisplay(size: 17))),
            Text('→', style: CType.body(size: 16, color: CColors.tealDark, w: FontWeight.w300)),
          ],
        ),
      ),
    );
  }
}

class _ProfilStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfilStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: CType.serifDisplay(size: 32, color: p.ink)),
          const SizedBox(height: 8),
          Eyebrow(label, size: 9, tracking: 0.18, color: p.inkSoft),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback? onTap;

  const _MenuRow({required this.icon, required this.label, this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: CColors.tealDark),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: CType.serifDisplay(size: 16))),
            if (hint != null) ...[
              Text(hint!,
                  style: CType.serifDisplay(size: 13, color: palette(context).inkSoft, italic: true)),
              const SizedBox(width: 10),
            ],
            Text('→', style: CType.body(size: 16, color: CColors.tealDark, w: FontWeight.w300)),
          ],
        ),
      ),
    );
  }
}