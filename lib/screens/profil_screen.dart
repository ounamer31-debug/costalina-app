import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_strings.dart';
import '../main.dart' show tabNotifier, themeModeNotifier;
import '../models/badge.dart';
import '../models/report_type.dart';
import '../models/signalement.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'leaderboard_screen.dart';
import 'rewards_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/costalina_logo.dart';
import '../widgets/eyebrow.dart';
import '../widgets/hair_line.dart';
import '../widgets/icon_btn.dart';
import '../widgets/lang_picker_btn.dart';
import '../widgets/serif_title.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _picker = ImagePicker();
  File? _localAvatar;
  bool _uploadingAvatar = false;
  UserStats _stats = const UserStats();

  @override
  void initState() {
    super.initState();
    _loadStats();
    tabNotifier.addListener(_onTabChange);
  }

  @override
  void dispose() {
    tabNotifier.removeListener(_onTabChange);
    super.dispose();
  }

  void _onTabChange() {
    if (tabNotifier.value == 3) _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final s = await ApiService.getMyStats();
      if (mounted) setState(() => _stats = s);
    } catch (_) {}
  }

  void _showMyReports(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (_) => const _MyReportsSheet(),
    );
  }

  // Tap handler — open sheet if photo exists, else go straight to picker
  void _onAvatarTap() {
    final hasPhoto =
        _localAvatar != null ||
        (AuthService.currentUser?.avatarUrl.isNotEmpty == true);
    if (hasPhoto) {
      _showAvatarSheet();
    } else {
      _pickAvatar();
    }
  }

  void _showAvatarSheet() {
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
                Text(
                  'Photo de profil',
                  style: CType.serifDisplay(
                    size: 22,
                    color: palette(context).ink,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    LucideIcons.x,
                    size: 18,
                    color: CColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          _AvatarSheetOption(
            icon: LucideIcons.camera,
            label: 'Modifier la photo',
            onTap: () {
              Navigator.pop(context);
              _pickAvatar();
            },
          ),
          const HairLine(color: CColors.tealLineSoft),
          _AvatarSheetOption(
            icon: LucideIcons.trash2,
            label: 'Supprimer la photo',
            danger: true,
            onTap: () {
              Navigator.pop(context);
              _removeAvatar();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (file == null || !mounted) return;

    // Show the picked file instantly — no waiting for upload
    setState(() {
      _localAvatar = File(file.path);
      _uploadingAvatar = true;
    });

    final result = await StorageService.uploadPhoto(File(file.path));
    if (!mounted) return;

    if (result.success) {
      await AuthService.updateProfile(avatarUrl: result.downloadUrl!);
      if (mounted) setState(() => _uploadingAvatar = false);
    } else {
      setState(() {
        _localAvatar = null; // revert — upload failed
        _uploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Échec upload: ${result.error}',
            style: CType.body(size: 12, color: Colors.white),
          ),
          backgroundColor: CColors.redInk,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _uploadingAvatar = true);
    await AuthService.updateProfile(avatarUrl: '');
    if (mounted) {
      setState(() {
        _localAvatar = null;
        _uploadingAvatar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final p = palette(context);
    final user = AuthService.currentUser;
    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : (user?.email ?? 'Utilisateur');
    final nameParts = displayName.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _onAvatarTap,
                    child: Stack(
                      children: [
                        _AvatarCircle(
                          url: user?.avatarUrl,
                          localFile: _localAvatar,
                          name: displayName,
                          loading: _uploadingAvatar,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: CColors.tealDark,
                              border: Border.all(color: p.bg, width: 2),
                            ),
                            child: const Icon(
                              LucideIcons.camera,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Eyebrow(user?.email ?? 'Bénévole · Costalina'),
                        const SizedBox(height: 10),
                        SerifTitle('$firstName ', italic: lastName, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          s.profilMember,
                          style: CType.body(size: 13, color: p.inkSoft),
                        ),
                      ],
                    ),
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
                    Expanded(
                      child: _ProfilStat(
                        label: s.profilStatSignalements,
                        value: '${_stats.total}',
                      ),
                    ),
                    const HairLine(
                      vertical: true,
                      extent: 72,
                      color: CColors.tealLineSoft,
                    ),
                    Expanded(
                      child: _ProfilStat(
                        label: 'Vérifiés',
                        value: '${_stats.verified}',
                      ),
                    ),
                    const HairLine(
                      vertical: true,
                      extent: 72,
                      color: CColors.tealLineSoft,
                    ),
                    Expanded(
                      child: _ProfilStat(
                        label: 'En attente',
                        value: '${_stats.pending}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('BADGES'),
                  const SizedBox(height: 14),
                  _BadgesStrip(stats: _stats),
                  const SizedBox(height: 28),
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
                        _MenuRow(
                          icon: LucideIcons.trophy,
                          label: 'Classement',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(
                          icon: LucideIcons.clipboardList,
                          label: 'Mes signalements',
                          hint: '${_stats.total}',
                          onTap: () => _showMyReports(context),
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(
                          icon: LucideIcons.gift,
                          label: 'Récompenses',
                          hint: '${user?.points ?? 0} pts',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RewardsScreen()),
                            );
                            // refresh points display when we come back
                            if (mounted) setState(() {});
                          },
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(
                          icon: LucideIcons.bell,
                          label: s.profilNotifications,
                          hint: s.profilNotificationsHint,
                          onTap: () => _showNotifSheet(context),
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(
                          icon: LucideIcons.map,
                          label: s.profilFollowedBeaches,
                          hint: '6',
                          onTap: () {
                            tabNotifier.value = 1;
                          },
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(
                          icon: LucideIcons.graduationCap,
                          label: s.profilLearnCenter,
                          onTap: () => _showLearnSheet(context),
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(
                          icon: LucideIcons.info,
                          label: s.profilAbout,
                          onTap: () => _showAboutSheet(context),
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        _MenuRow(
                          icon: LucideIcons.settings,
                          label: s.profilSettings,
                          onTap: () => _showSettings(context),
                        ),
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
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CColors.redInk.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.logOut, size: 15, color: CColors.redInk),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.current.logout,
                        style: CType.eyebrow(
                          size: 10,
                          tracking: 0.22,
                          color: CColors.redInk,
                        ),
                      ),
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
                      size: 9,
                      tracking: 0.32,
                      color: CColors.grey,
                      w: FontWeight.w300,
                    ),
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
              Text(
                s.profilNotifications,
                style: CType.serifDisplay(size: 22, color: p.ink),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        _NotifToggle(label: s.notifAlerts, value: true),
        const HairLine(color: CColors.tealLineSoft),
        _NotifToggle(label: s.notifReports, value: true),
        const HairLine(color: CColors.tealLineSoft),
        _NotifToggle(label: s.notifUpdates, value: false),
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
                Text(
                  s.profilLearnCenter,
                  style: CType.serifDisplay(size: 22, color: p.ink),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    LucideIcons.x,
                    size: 18,
                    color: CColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          for (final item in [
            (LucideIcons.waves, s.learnErosion, s.learnErosionSub),
            (LucideIcons.camera, s.learnPhoto, s.learnPhotoSub),
            (LucideIcons.barChart2, s.learnRisk, s.learnRiskSub),
            (LucideIcons.mapPin, s.learnGPS, s.learnGPSSub),
          ]) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    color: CColors.tealBg,
                    alignment: Alignment.center,
                    child: Icon(item.$1, size: 18, color: CColors.tealDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$2, style: CType.serifDisplay(size: 16)),
                        const SizedBox(height: 4),
                        Text(
                          item.$3,
                          style: CType.body(size: 12, color: p.inkSoft),
                        ),
                      ],
                    ),
                  ),
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
              width: 36,
              height: 3,
              color: CColors.tealLine,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              children: [
                Text(
                  s.profilAbout,
                  style: CType.serifDisplay(size: 22, color: p.ink),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    LucideIcons.x,
                    size: 18,
                    color: CColors.grey,
                  ),
                ),
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
                    Text(
                      'COSTALINA',
                      style: CType.eyebrow(
                        size: 14,
                        tracking: 0.44,
                        color: CColors.tealDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v 2.4  ·  2026',
                      style: CType.eyebrow(
                        size: 9,
                        tracking: 0.28,
                        color: CColors.grey,
                        w: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Mission body
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Text(
              s.aboutBody,
              style: CType.body(size: 13, color: p.inkSoft),
            ),
          ),
          const SizedBox(height: 28),
          const HairLine(color: CColors.tealLineSoft),
          // Key stats
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Row(
              children: [
                Expanded(
                  child: _AboutStat(value: '6', label: s.aboutStatBeaches),
                ),
                const HairLine(
                  vertical: true,
                  extent: 50,
                  color: CColors.tealLineSoft,
                ),
                Expanded(
                  child: _AboutStat(
                    value: '340+',
                    label: s.aboutStatVolunteers,
                  ),
                ),
                const HairLine(
                  vertical: true,
                  extent: 50,
                  color: CColors.tealLineSoft,
                ),
                Expanded(
                  child: _AboutStat(value: '1 200+', label: s.aboutStatReports),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const HairLine(color: CColors.tealLineSoft),
          // Feature list
          for (final item in [
            (LucideIcons.waves, s.aboutFeature1, s.aboutFeature1Sub),
            (LucideIcons.camera, s.aboutFeature2, s.aboutFeature2Sub),
            (LucideIcons.shieldCheck, s.aboutFeature3, s.aboutFeature3Sub),
          ]) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, size: 18, color: CColors.tealDark),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$2, style: CType.serifDisplay(size: 15)),
                        const SizedBox(height: 3),
                        Text(
                          item.$3,
                          style: CType.body(size: 12, color: p.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const HairLine(color: CColors.tealLineSoft),
          ],
          // Contact
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Eyebrow(
              s.aboutContact,
              size: 9,
              tracking: 0.26,
              color: p.inkSoft,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
            child: Row(
              children: [
                const Icon(LucideIcons.mail, size: 14, color: CColors.tealDark),
                const SizedBox(width: 10),
                Text(
                  'contact@costalina.tn',
                  style: CType.body(size: 13, color: CColors.tealDark),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.globe,
                  size: 14,
                  color: CColors.tealDark,
                ),
                const SizedBox(width: 10),
                Text(
                  'www.costalina.tn',
                  style: CType.body(size: 13, color: CColors.tealDark),
                ),
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
  void initState() {
    super.initState();
    _on = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(
          children: [
            Expanded(
              child: Text(widget.label, style: CType.serifDisplay(size: 16)),
            ),
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
        border: const Border(
          bottom: BorderSide(color: CColors.tealLineSoft, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconBtn(
            icon: const Icon(LucideIcons.arrowLeft),
            onTap: () => tabNotifier.value = 0,
          ),
          const Spacer(),
          const LangPickerBtn(),
          IconBtn(
            icon: const Icon(LucideIcons.settings),
            onTap: () => _showSettings(context),
          ),
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
                Text(
                  s.profilSettings,
                  style: CType.serifDisplay(size: 22, color: p.ink),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    LucideIcons.x,
                    size: 18,
                    color: CColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          _SettingsItem(
            icon: LucideIcons.globe,
            label: s.chooseLanguage,
            onTap: () {
              Navigator.pop(context);
              showLangPicker(context);
            },
          ),
          const HairLine(color: CColors.tealLineSoft),
          _SettingsItem(
            icon: LucideIcons.bell,
            label: s.profilNotifications,
            onTap: () {
              Navigator.pop(context);
              _showNotifSheet(context);
            },
          ),
          const HairLine(color: CColors.tealLineSoft),
          _SettingsItem(
            icon: LucideIcons.info,
            label: s.profilAbout,
            onTap: () {
              Navigator.pop(context);
              _showAboutSheet(context);
            },
          ),
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
              Icon(
                isDark ? LucideIcons.moon : LucideIcons.sun,
                size: 18,
                color: CColors.tealDark,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  s.darkMode,
                  style: CType.serifDisplay(
                    size: 16,
                    color: palette(context).ink,
                  ),
                ),
              ),
              Switch(
                value: isDark,
                onChanged: (v) => themeModeNotifier.value = v
                    ? ThemeMode.dark
                    : ThemeMode.light,
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
          Text(
            value,
            style: CType.serifDisplay(size: 22, color: CColors.tealDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: CType.eyebrow(
              size: 8,
              tracking: 0.18,
              color: palette(context).inkSoft,
            ),
            textAlign: TextAlign.center,
          ),
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
            Text(
              '→',
              style: CType.body(
                size: 16,
                color: CColors.tealDark,
                w: FontWeight.w300,
              ),
            ),
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

  const _MenuRow({
    required this.icon,
    required this.label,
    this.hint,
    this.onTap,
  });

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
              Text(
                hint!,
                style: CType.serifDisplay(
                  size: 13,
                  color: palette(context).inkSoft,
                  italic: true,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              '→',
              style: CType.body(
                size: 16,
                color: CColors.tealDark,
                w: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar circle ─────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  final String? url;
  final File? localFile;
  final String name;
  final bool loading;

  const _AvatarCircle({
    this.url,
    this.localFile,
    required this.name,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    Widget photo;
    if (localFile != null) {
      // Show picked file immediately — no network needed
      photo = Image.file(localFile!, width: 68, height: 68, fit: BoxFit.cover);
    } else if (url != null && url!.isNotEmpty) {
      photo = CachedNetworkImage(
        imageUrl: url!,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        placeholder: (_, _) => Center(
          child: Text(
            initials,
            style: CType.serifDisplay(size: 22, color: CColors.tealDark),
          ),
        ),
        errorWidget: (_, _, _) => Center(
          child: Text(
            initials,
            style: CType.serifDisplay(size: 22, color: CColors.tealDark),
          ),
        ),
      );
    } else {
      photo = Center(
        child: Text(
          initials,
          style: CType.serifDisplay(size: 22, color: CColors.tealDark),
        ),
      );
    }

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: CColors.tealBg,
        border: Border.all(color: CColors.tealLine, width: 1),
      ),
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            photo,
            if (loading)
              Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar sheet option row ───────────────────────────────────────────────────

class _AvatarSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _AvatarSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? CColors.redInk : CColors.tealDark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: CType.serifDisplay(
                  size: 17,
                  color: danger ? CColors.redInk : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesStrip extends StatelessWidget {
  final UserStats stats;
  const _BadgesStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final badges = BadgeService.compute(stats);
    final earned = badges.where((b) => b.earned).length;
    final p = palette(context);

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: CColors.tealLine, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$earned / ${badges.length} obtenus',
                  style: CType.serifDisplay(size: 17, color: p.ink),
                ),
              ),
              GestureDetector(
                onTap: () => _showBadgesSheet(context, badges),
                child: Text(
                  'TOUS  →',
                  style: CType.eyebrow(
                    size: 9,
                    tracking: 0.28,
                    color: CColors.tealDark,
                    w: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _BadgeChip(badge: badges[i]),
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgesSheet(BuildContext context, List<CoastBadge> badges) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Row(
                children: [
                  Text('Vos badges',
                      style: CType.serifDisplay(size: 22, color: palette(context).ink)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
                  ),
                ],
              ),
            ),
            const HairLine(color: CColors.tealLine),
            Expanded(
              child: ListView.separated(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
                itemCount: badges.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _BadgeRow(badge: badges[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final CoastBadge badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final tierColor = BadgeService.tierColor(badge.tier);
    final earned = badge.earned;
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: earned ? tierColor.withValues(alpha: 0.15) : p.bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: earned ? tierColor : CColors.tealLineSoft,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              badge.icon,
              size: 22,
              color: earned ? tierColor : CColors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.name.split(' ').first,
            style: CType.body(
                size: 9,
                color: earned ? p.ink : CColors.grey,
                w: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final CoastBadge badge;
  const _BadgeRow({required this.badge});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final tierColor = BadgeService.tierColor(badge.tier);
    final earned = badge.earned;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: CColors.tealLine, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: earned ? tierColor.withValues(alpha: 0.15) : p.bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: earned ? tierColor : CColors.tealLineSoft,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(badge.icon, size: 20,
                color: earned ? tierColor : CColors.grey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.name,
                    style: CType.serifDisplay(size: 16,
                        color: earned ? p.ink : p.inkSoft)),
                const SizedBox(height: 3),
                Text(badge.description,
                    style: CType.body(size: 11, color: p.inkSoft)),
                const SizedBox(height: 8),
                if (!earned) ...[
                  Container(
                    height: 3,
                    color: CColors.tealLineSoft,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: badge.progressFraction,
                      child: ColoredBox(color: tierColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${badge.progress} / ${badge.threshold}',
                    style: CType.eyebrow(
                        size: 9, tracking: 0.24, color: p.inkSoft, w: FontWeight.w400),
                  ),
                ] else
                  Eyebrow('OBTENU', size: 9, tracking: 0.28, color: tierColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── My Reports Sheet ──────────────────────────────────────────────────────────

class _MyReportsSheet extends StatefulWidget {
  const _MyReportsSheet();

  @override
  State<_MyReportsSheet> createState() => _MyReportsSheetState();
}

class _MyReportsSheetState extends State<_MyReportsSheet> {
  late Future<List<Signalement>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getMyReports();
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
            child: Row(
              children: [
                Text('Mes signalements', style: CType.serifDisplay(size: 22, color: p.ink)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
                ),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          Expanded(
            child: FutureBuilder<List<Signalement>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: CColors.tealDark)),
                  );
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clipboardList, size: 36, color: p.inkSoft),
                          const SizedBox(height: 16),
                          Text('Aucun signalement pour l\'instant',
                              style: CType.body(size: 13, color: p.inkSoft),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final r = list[i];
                    final statusColor = switch (r.status) {
                      'verified' => CColors.greenInk,
                      'resolved' => CColors.tealDark,
                      'rejected' => CColors.redInk,
                      _ => CColors.amberInk,
                    };
                    final statusLabel = switch (r.status) {
                      'verified' => 'Vérifié',
                      'resolved' => 'Résolu',
                      'rejected' => 'Rejeté',
                      _ => 'En attente',
                    };
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 38, height: 38,
                                color: CColors.tealBg,
                                alignment: Alignment.center,
                                child: Icon(r.type.icon, size: 18, color: CColors.tealDark),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.type.label, style: CType.serifDisplay(size: 16, color: p.ink)),
                                    const SizedBox(height: 3),
                                    Eyebrow(r.when, size: 9, tracking: 0.2, color: p.inkSoft),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                                ),
                                child: Eyebrow(statusLabel, size: 9, tracking: 0.22, color: statusColor),
                              ),
                            ],
                          ),
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
