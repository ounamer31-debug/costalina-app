import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_beaches.dart';
import '../l10n/app_strings.dart';
import '../main.dart' show tabNotifier;
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/beach.dart';
import '../theme/app_theme.dart';
import '../widgets/corner_ornaments.dart';
import '../widgets/costalina_logo.dart';
import '../widgets/eyebrow.dart';
import '../widgets/ghost_link.dart';
import '../widgets/hair_line.dart';
import '../widgets/icon_btn.dart';
import '../widgets/lang_picker_btn.dart';
import '../widgets/risk_tag.dart';
import '../widgets/section_head.dart';
import '../widgets/serif_title.dart';
import '../widgets/star_gauge.dart';
import '../widgets/weather_card.dart';
import 'beach_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void Function(double)? _uploadNotifier;
  List<Beach> _beaches = mockBeaches;

  @override
  void initState() {
    super.initState();
    _loadBeaches();
  }

  Future<void> _loadBeaches() async {
    try {
      final beaches = await ApiService.getBeaches();
      if (mounted) setState(() => _beaches = beaches);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final p = palette(context);
    final featured = _beaches.isNotEmpty
        ? (_beaches.firstWhere((b) => b.id == 'skanes', orElse: () => _beaches.first))
        : mockBeaches.first;
    final stable = _beaches.where((b) => b.risk == BeachRisk.stable).length;
    final modere = _beaches.where((b) => b.risk == BeachRisk.modere).length;
    final eleve  = _beaches.where((b) => b.risk == BeachRisk.eleve).length;

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _TopBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(s.homeKicker),
                  const SizedBox(height: 12),
                  SerifTitle(s.homeTitle, italic: s.homeItalic, trail: '.', size: 34),
                  const SizedBox(height: 14),
                  Text(s.homeBody, style: CType.body(size: 13), maxLines: 3),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _HeroCard(beach: featured),
            ),
            const WeatherCard(),
            // Stat strip
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 40, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHead(kicker: s.statKicker, title: s.statTitle, italic: s.statItalic),
                  Container(
                    decoration: BoxDecoration(
                      color: p.surface,
                      border: Border.all(color: CColors.tealLine, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _StatCell(count: stable, label: s.statStable, risk: BeachRisk.stable)),
                        const HairLine(vertical: true, extent: 110, color: CColors.tealLineSoft),
                        Expanded(child: _StatCell(count: modere, label: s.statModere, risk: BeachRisk.modere)),
                        const HairLine(vertical: true, extent: 110, color: CColors.tealLineSoft),
                        Expanded(child: _StatCell(count: eleve,  label: s.statEleve,  risk: BeachRisk.eleve)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Quick actions
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 36, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHead(kicker: s.quickKicker, title: s.quickTitle, italic: s.quickItalic),
                  Container(
                    decoration: BoxDecoration(
                      color: p.surface,
                      border: Border.all(color: CColors.tealLine, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _QuickAction(
                              icon: LucideIcons.camera,
                              label: s.actionPhoto,
                              sub: s.actionPhotoSub,
                              onTap: () => _showPhotoPickerSheet(context),
                            )),
                            const HairLine(vertical: true, extent: 112, color: CColors.tealLineSoft),
                            Expanded(child: _QuickAction(
                              icon: LucideIcons.alertTriangle,
                              label: s.actionReport,
                              sub: s.actionReportSub,
                              onTap: () => _showReportSheet(context, type: 'signal'),
                            )),
                          ],
                        ),
                        const HairLine(color: CColors.tealLineSoft),
                        Row(
                          children: [
                            Expanded(child: _QuickAction(
                              icon: LucideIcons.map,
                              label: s.actionMap,
                              sub: s.actionMapSub,
                              onTap: () => tabNotifier.value = 1,
                            )),
                            const HairLine(vertical: true, extent: 112, color: CColors.tealLineSoft),
                            Expanded(child: _QuickAction(
                              icon: LucideIcons.graduationCap,
                              label: s.actionLearn,
                              sub: s.actionLearnSub,
                              onTap: () => _showLearnSheet(context),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Beach list
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 36, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHead(
                    kicker: s.beachListKicker,
                    title: s.beachListTitle,
                    italic: s.beachListItalic,
                    trailing: GhostLink(
                      label: s.viewAll,
                      onTap: () => _showAllBeaches(context),
                    ),
                  ),
                  ...List.generate(mockBeaches.length.clamp(0, 4), (i) {
                    return _BeachListRow(beach: mockBeaches[i], first: i == 0);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick-action sheets ──────────────────────────────────────────────────────

  void _showPhotoPickerSheet(BuildContext context) {
    final s = AppStrings.current;
    final p = palette(context);
    final picker = ImagePicker();

    Future<void> upload(XFile xfile) async {
      if (!context.mounted) return;
      double progress = 0;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setDlg) {
            _uploadNotifier ??= (double v) {
              if (ctx.mounted) setDlg(() => progress = v);
            };
            return AlertDialog(
              backgroundColor: p.surface,
              shape: const RoundedRectangleBorder(),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.uploadingPhoto, style: CType.serifDisplay(size: 17, color: p.ink)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      color: CColors.tealDark,
                      backgroundColor: CColors.tealLine,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).round()} %',
                      style: CType.eyebrow(size: 9, tracking: 0.2, color: CColors.grey)),
                ],
              ),
            );
          },
        ),
      );

      final result = await StorageService.uploadPhoto(
        File(xfile.path),
        onProgress: (v) => _uploadNotifier?.call(v),
      );
      _uploadNotifier = null;

      if (!context.mounted) return;
      Navigator.pop(context); // close dialog

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result.success ? s.uploadSuccess : (result.error ?? s.uploadError),
          style: CType.body(size: 13, color: Colors.white),
        ),
        backgroundColor: result.success ? CColors.tealDark : CColors.redInk,
        behavior: SnackBarBehavior.floating,
      ));
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                Text(s.actionPhoto, style: CType.serifDisplay(size: 22, color: p.ink)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
                ),
              ],
            ),
          ),
          const HairLine(color: CColors.tealLine),
          _PickerOption(
            icon: LucideIcons.camera,
            label: s.addPhoto,
            sub: s.addPhotoSub,
            onTap: () async {
              Navigator.pop(context);
              final f = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
              if (f != null) await upload(f);
            },
          ),
          const HairLine(color: CColors.tealLineSoft),
          _PickerOption(
            icon: LucideIcons.image,
            label: s.addGallery,
            sub: s.addGallerySub,
            onTap: () async {
              Navigator.pop(context);
              final files = await picker.pickMultipleMedia(imageQuality: 85);
              for (final f in files) { await upload(f); }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }


  void _showReportSheet(BuildContext context, {required String type}) {
    final isPhoto = type == 'photo';
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _ReportSheet(isPhoto: isPhoto),
      ),
    );
  }

  void _showLearnSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      shape: const RoundedRectangleBorder(),
      builder: (_) => const _LearnSheet(),
    );
  }

  void _showAllBeaches(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, ctrl) => _AllBeachesSheet(controller: ctrl),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: Row(
          children: [
            Container(width: 40, height: 40, color: CColors.tealBg,
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: CColors.tealDark)),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: CType.serifDisplay(size: 17, color: p.ink)),
                const SizedBox(height: 2),
                Text(sub, style: CType.body(size: 11, color: p.inkSoft)),
              ],
            )),
            Text('→', style: CType.body(size: 16, color: CColors.tealDark, w: FontWeight.w300)),
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
          const CostalinaLogo(size: 36),
          const Spacer(),
          // Bell → go to Alertes tab
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconBtn(
                icon: const Icon(LucideIcons.bell),
                onTap: () => tabNotifier.value = 2,
              ),
              Positioned(
                right: 4, top: 4,
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: CColors.redDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const LangPickerBtn(),
          IconBtn(
            icon: const Icon(LucideIcons.menu),
            onTap: () => _showMenuSheet(context),
          ),
        ],
      ),
    );
  }

  void _showMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      shape: const RoundedRectangleBorder(),
      builder: (_) => const _MenuSheet(),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final Beach beach;
  const _HeroCard({required this.beach});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final shortName = beach.name.replaceFirst('Plage de ', '');
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => BeachDetailScreen(beach: beach))),
      child: AspectRatio(
        aspectRatio: 5 / 6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: beach.photoUrl,
              fit: BoxFit.cover,
              color: Colors.transparent,
              colorBlendMode: BlendMode.saturation,
              placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
              errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x401A2E2C), Color(0xEB1A2E2C)],
                  stops: [0.2, 0.45, 1.0],
                ),
              ),
            ),
            const CornerOrnaments(),
            Positioned(
              top: 18, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Eyebrow(s.featuredLabel, color: const Color(0xF2A8DDD8), size: 9, tracking: 0.38),
                  Eyebrow(beach.lastUpdate, color: const Color(0xB3FFFFFF), size: 9, tracking: 0.28),
                ],
              ),
            ),
            Positioned(
              left: 22, right: 22, bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('${beach.city} · ${s.coastlineEyebrow}', color: const Color(0xF2A8DDD8), size: 10, tracking: 0.35),
                  const SizedBox(height: 8),
                  Text(shortName, style: CType.serifDisplay(size: 32, color: Colors.white)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      RiskTag(beach.risk, light: true, size: RiskTagSize.sm),
                      const SizedBox(width: 10),
                      Text(
                        '${s.erosionPrefix} ${beach.erosionMeters.toStringAsFixed(1)} m',
                        style: CType.serifDisplay(size: 13, color: const Color(0xB3FFFFFF), italic: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(s.discoverDetail, style: CType.eyebrow(size: 11, tracking: 0.24, color: Colors.white, w: FontWeight.w400)),
                      const SizedBox(width: 10),
                      Text('→', style: CType.body(size: 14, color: Colors.white, w: FontWeight.w300)),
                    ],
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

// ── Stat cell ─────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final int count;
  final String label;
  final BeachRisk risk;
  const _StatCell({required this.count, required this.label, required this.risk});

  @override
  Widget build(BuildContext context) {
    final dot = CColors.riskDot(risk);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count', style: CType.serifDisplay(size: 44, color: dot)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 5, height: 5, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(child: Eyebrow(label, size: 9, tracking: 0.18, color: CColors.inkSoft)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick action tile ─────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: CColors.tealDark),
            const SizedBox(height: 14),
            Text(label, style: CType.serifDisplay(size: 16)),
            const SizedBox(height: 4),
            Text(sub, style: CType.body(size: 10, color: CColors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── Beach list row ─────────────────────────────────────────────────────────────

class _BeachListRow extends StatelessWidget {
  final Beach beach;
  final bool first;
  const _BeachListRow({required this.beach, this.first = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => BeachDetailScreen(beach: beach))),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HairLine(color: first ? CColors.tealLine : CColors.tealLineSoft),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 64, height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: beach.photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
                        errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x661A2E2C)],
                            stops: [0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(beach.city, size: 9, tracking: 0.24),
                      const SizedBox(height: 4),
                      Text(beach.name, style: CType.serifDisplay(size: 19)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StarGauge.fromRisk(beach.risk),
                          const SizedBox(width: 10),
                          Text('${beach.erosionMeters.toStringAsFixed(1)} m',
                              style: CType.serifDisplay(size: 12, color: CColors.inkSoft, italic: true)),
                        ],
                      ),
                    ],
                  ),
                ),
                Text('→', style: CType.body(size: 18, color: CColors.tealDark, w: FontWeight.w300)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── App menu sheet ─────────────────────────────────────────────────────────────

class _MenuSheet extends StatelessWidget {
  const _MenuSheet();

  @override
  Widget build(BuildContext context) {
    final items = [
      (LucideIcons.home,         'Accueil',          () { Navigator.pop(context); tabNotifier.value = 0; }),
      (LucideIcons.map,          'Carte',             () { Navigator.pop(context); tabNotifier.value = 1; }),
      (LucideIcons.bell,         'Alertes',           () { Navigator.pop(context); tabNotifier.value = 2; }),
      (LucideIcons.user,         'Profil',            () { Navigator.pop(context); tabNotifier.value = 3; }),
      (LucideIcons.graduationCap,'Centre d\'apprentissage', () { Navigator.pop(context); }),
      (LucideIcons.info,         'À propos',          () { Navigator.pop(context); }),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
          child: Row(
            children: [
              Text('Menu', style: CType.serifDisplay(size: 22, color: CColors.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        for (final item in items) ...[
          GestureDetector(
            onTap: item.$3,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
              child: Row(
                children: [
                  Icon(item.$1, size: 18, color: CColors.tealDark),
                  const SizedBox(width: 16),
                  Expanded(child: Text(item.$2, style: CType.serifDisplay(size: 17))),
                  Text('→', style: CType.body(size: 16, color: CColors.tealDark, w: FontWeight.w300)),
                ],
              ),
            ),
          ),
          const HairLine(color: CColors.tealLineSoft),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Report / photo sheet ───────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  final bool isPhoto;
  const _ReportSheet({required this.isPhoto});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final title = widget.isPhoto ? 'Ajouter une photo' : 'Signaler un problème';
    final hint  = widget.isPhoto ? 'Décrivez ce que vous voyez…' : 'Décrivez l\'érosion, la pollution…';
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(title, style: CType.serifDisplay(size: 22, color: CColors.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: CColors.white,
              border: Border.all(color: CColors.tealLine, width: 1),
            ),
            child: TextField(
              controller: _ctrl,
              maxLines: 4,
              style: CType.body(size: 13, color: CColors.ink),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: CType.body(size: 13, color: CColors.grey),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isPhoto ? 'Photo soumise ✓' : 'Signalement envoyé ✓',
                    style: CType.body(size: 13, color: Colors.white),
                  ),
                  backgroundColor: CColors.tealDark,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              height: 52,
              color: CColors.tealDark,
              alignment: Alignment.center,
              child: Text(
                widget.isPhoto ? 'SOUMETTRE LA PHOTO  →' : 'ENVOYER LE SIGNALEMENT  →',
                style: CType.eyebrow(size: 11, tracking: 0.22, color: Colors.white, w: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Learning center sheet ─────────────────────────────────────────────────────

class _LearnSheet extends StatelessWidget {
  const _LearnSheet();

  @override
  Widget build(BuildContext context) {
    final topics = [
      ('Qu\'est-ce que l\'érosion côtière ?', 'L\'érosion est le recul progressif du trait de côte sous l\'effet des vagues, du vent et de la montée des eaux.'),
      ('Pourquoi surveiller ?', 'La surveillance permet d\'anticiper les risques, de protéger les habitations et de préserver les écosystèmes littoraux.'),
      ('Comment aider ?', 'Signalez les zones dégradées, ajoutez des photos géolocalisées et partagez les alertes avec votre communauté.'),
    ];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
        children: [
          Row(
            children: [
              Text('Centre d\'apprentissage',
                  style: CType.serifDisplay(size: 20, color: CColors.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Comprendre l\'érosion du littoral',
              style: CType.body(size: 12, color: CColors.grey)),
          const SizedBox(height: 24),
          for (final t in topics) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: CColors.white,
                border: Border.all(color: CColors.tealLine, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.$1, style: CType.serifDisplay(size: 17)),
                  const SizedBox(height: 8),
                  Text(t.$2, style: CType.body(size: 12, color: CColors.inkSoft)),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

// ── All beaches sheet ─────────────────────────────────────────────────────────

class _AllBeachesSheet extends StatelessWidget {
  final ScrollController controller;
  const _AllBeachesSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
          child: Row(
            children: [
              Text('Toutes les plages',
                  style: CType.serifDisplay(size: 22, color: CColors.ink)),
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
          child: ListView.builder(
            controller: controller,
            itemCount: mockBeaches.length,
            itemBuilder: (_, i) {
              final b = mockBeaches[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BeachDetailScreen(beach: b)));
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Eyebrow(b.city, size: 9, tracking: 0.24),
                                const SizedBox(height: 3),
                                Text(b.name, style: CType.serifDisplay(size: 18)),
                              ],
                            ),
                          ),
                          RiskTag(b.risk, size: RiskTagSize.sm),
                          const SizedBox(width: 12),
                          Text('→', style: CType.body(size: 16, color: CColors.tealDark, w: FontWeight.w300)),
                        ],
                      ),
                    ),
                    const HairLine(color: CColors.tealLineSoft),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}