import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_beaches.dart';
import '../l10n/app_strings.dart';
import '../main.dart' show tabNotifier;
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/report_queue.dart';
import '../services/storage_service.dart';
import '../models/beach.dart';
import '../models/report_type.dart';
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
  List<Beach> _beaches = mockBeaches;

  @override
  void initState() {
    super.initState();
    _loadBeaches();
    _flushQueueQuietly();
  }

  Future<void> _loadBeaches() async {
    try {
      final beaches = await ApiService.getBeaches();
      if (mounted) setState(() => _beaches = beaches);
    } catch (_) {}
  }

  Future<void> _flushQueueQuietly() async {
    final sent = await ReportQueue.flush();
    if (sent > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          sent == 1
              ? '1 signalement en attente envoyé ✓'
              : '$sent signalements en attente envoyés ✓',
          style: CType.body(size: 13, color: Colors.white),
        ),
        backgroundColor: CColors.tealDark,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final p = palette(context);
    // Featured = highest-risk beach; tie-break by most erosion
    Beach pickFeatured(List<Beach> list) {
      if (list.isEmpty) return mockBeaches.first;
      const order = [BeachRisk.eleve, BeachRisk.modere, BeachRisk.stable];
      for (final risk in order) {
        final group = list.where((b) => b.risk == risk).toList()
          ..sort((a, b) => b.erosionMeters.compareTo(a.erosionMeters));
        if (group.isNotEmpty) return group.first;
      }
      return list.first;
    }
    final featured = pickFeatured(_beaches);
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
                              onTap: () => _showReportSheet(context, type: 'photo'),
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
                  ...List.generate(_beaches.length.clamp(0, 4), (i) {
                    return _BeachListRow(beach: _beaches[i], first: i == 0);
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

  void _showReportSheet(BuildContext context, {required String type}) {
    final isPhoto = type == 'photo';
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _ReportSheet(isPhoto: isPhoto, beaches: _beaches),
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
    final beaches = _beaches;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette(context).bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, ctrl) => _AllBeachesSheet(beaches: beaches, controller: ctrl),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

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
              Expanded(child: Eyebrow(label, size: 9, tracking: 0.18, color: palette(context).inkSoft)),
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
                              style: CType.serifDisplay(size: 12, italic: true)),
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
              Text('Menu', style: CType.serifDisplay(size: 22, color: palette(context).ink)),
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

// ── Public helper: open the report sheet from anywhere ──────────────────────

/// Opens the report-creation bottom sheet. If [beaches] is null, the beach list
/// is fetched lazily from [ApiService.getBeaches] (with the bundled mock list as
/// a fallback if the network is down).
Future<void> showCreateReportSheet(BuildContext context, {bool isPhoto = false, List<Beach>? beaches}) async {
  var list = beaches;
  if (list == null) {
    try {
      list = await ApiService.getBeaches();
    } catch (_) {
      list = mockBeaches;
    }
  }
  if (!context.mounted) return;
  await showModalBottomSheet(
    context: context,
    backgroundColor: palette(context).bg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _ReportSheet(isPhoto: isPhoto, beaches: list!),
    ),
  );
}

// ── Report / photo sheet ───────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  final bool isPhoto;
  final List<Beach> beaches;
  const _ReportSheet({required this.isPhoto, required this.beaches});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _ctrl    = TextEditingController();
  final _picker  = ImagePicker();
  ReportType _type = ReportType.erosion;
  int _severity   = 3;
  File? _photo;
  String? _photoUrl;
  bool _uploading = false;
  bool _loading   = false;
  double? _lat, _lng;
  Beach? _selectedBeach;

  @override
  void initState() {
    super.initState();
    _type = widget.isPhoto ? ReportType.photo : ReportType.erosion;
    if (widget.beaches.isNotEmpty) _selectedBeach = widget.beaches.first;
    _captureGps();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _captureGps() async {
    try {
      final r = await LocationService.instance.getCurrent();
      if (r.status == LocationStatus.ok && r.position != null && mounted) {
        setState(() {
          _lat = r.position!.latitude;
          _lng = r.position!.longitude;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final f = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
    if (f == null || !mounted) return;
    setState(() { _photo = File(f.path); _uploading = true; _photoUrl = null; });
    final result = await StorageService.uploadPhoto(File(f.path));
    if (!mounted) return;
    if (result.success) {
      setState(() { _photoUrl = result.downloadUrl; _uploading = false; });
    } else {
      setState(() { _photo = null; _uploading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Échec photo: ${result.error}', style: CType.body(size: 12, color: Colors.white)),
        backgroundColor: CColors.redInk,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _submit() async {
    if (_loading || _uploading) return;
    if (_selectedBeach == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sélectionnez une plage', style: CType.body(size: 13, color: Colors.white)),
        backgroundColor: CColors.redInk,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _loading = true);
    final payload = <String, dynamic>{
      'beachId':  _selectedBeach!.id,
      'type':     _type.apiValue,
      'severity': _severity,
      'message':  _ctrl.text.trim(),
      'photoUrl': _photoUrl ?? '',
      if (_lat != null) 'lat': _lat,
      if (_lng != null) 'lng': _lng,
    };

    bool sentNow = false;
    try {
      await ApiService.createReport(payload);
      sentNow = true;
      // Opportunistically flush anything that piled up offline
      unawaited(ReportQueue.flush());
    } catch (_) {
      // Network failure → queue locally for later
      await ReportQueue.enqueue(payload);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        sentNow
            ? 'Signalement envoyé ✓'
            : 'Hors-ligne — signalement enregistré, envoi automatique au retour du réseau',
        style: CType.body(size: 13, color: Colors.white),
      ),
      backgroundColor: sentNow ? CColors.tealDark : CColors.amberInk,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: sentNow ? 3 : 5),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final hasGps = _lat != null && _lng != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Nouveau signalement', style: CType.serifDisplay(size: 22, color: p.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Eyebrow('PLAGE', size: 9, tracking: 0.24),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: CColors.tealLine),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButton<Beach>(
              value: _selectedBeach,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: p.surface,
              style: CType.body(size: 13, color: p.ink),
              icon: const Icon(LucideIcons.chevronDown, size: 16, color: CColors.grey),
              items: widget.beaches.map((b) => DropdownMenuItem(
                value: b,
                child: Text(b.name, overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (b) => setState(() => _selectedBeach = b),
            ),
          ),
          const SizedBox(height: 16),
          Eyebrow('TYPE', size: 9, tracking: 0.24),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in ReportType.values)
                _TypeChip(
                  type: t,
                  selected: _type == t,
                  onTap: () => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Eyebrow('SÉVÉRITÉ', size: 9, tracking: 0.24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => setState(() => _severity = i),
                  child: Container(
                    width: 48, height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i <= _severity ? CColors.tealDark : p.surface,
                      border: Border.all(color: CColors.tealLine),
                    ),
                    child: Text('$i',
                        style: CType.serifDisplay(
                            size: 16,
                            color: i <= _severity ? Colors.white : p.inkSoft)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Eyebrow('DESCRIPTION', size: 9, tracking: 0.24),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: CColors.tealLine, width: 1),
            ),
            child: TextField(
              controller: _ctrl,
              maxLines: 3,
              style: CType.body(size: 13, color: p.ink),
              decoration: InputDecoration(
                hintText: 'Décrivez ce que vous observez…',
                hintStyle: CType.body(size: 13, color: CColors.grey),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Eyebrow('PHOTO (FACULTATIVE)', size: 9, tracking: 0.24),
          const SizedBox(height: 10),
          Row(
            children: [
              if (_photo != null)
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: FileImage(_photo!), fit: BoxFit.cover),
                    border: Border.all(color: CColors.tealLine),
                  ),
                  alignment: Alignment.center,
                  child: _uploading
                      ? Container(color: Colors.black54,
                          child: const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))))
                      : null,
                ),
              if (_photo != null) const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _PhotoBtn(
                      icon: LucideIcons.camera,
                      label: 'Caméra',
                      onTap: () => _pickPhoto(ImageSource.camera),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _PhotoBtn(
                      icon: LucideIcons.image,
                      label: 'Galerie',
                      onTap: () => _pickPhoto(ImageSource.gallery),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(hasGps ? LucideIcons.mapPin : LucideIcons.mapPinOff,
                  size: 13, color: hasGps ? CColors.tealDark : CColors.grey),
              const SizedBox(width: 6),
              Text(
                hasGps
                    ? 'GPS: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                    : 'GPS non disponible',
                style: CType.body(size: 11, color: hasGps ? CColors.tealDark : CColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: (_loading || _uploading) ? null : _submit,
            child: Container(
              height: 52,
              color: (_loading || _uploading) ? CColors.grey : CColors.tealDark,
              alignment: Alignment.center,
              child: _loading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(
                      'ENVOYER LE SIGNALEMENT  →',
                      style: CType.eyebrow(size: 11, tracking: 0.22, color: Colors.white, w: FontWeight.w400),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final ReportType type;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
        decoration: BoxDecoration(
          color: selected ? CColors.tealDark : p.surface,
          border: Border.all(color: selected ? CColors.tealDark : CColors.tealLine),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 14, color: selected ? Colors.white : p.inkSoft),
            const SizedBox(width: 6),
            Text(type.label,
                style: CType.body(size: 12,
                    color: selected ? Colors.white : p.ink,
                    w: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _PhotoBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PhotoBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(color: CColors.tealLine),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: CColors.tealDark),
            const SizedBox(width: 6),
            Text(label, style: CType.body(size: 12, color: p.ink, w: FontWeight.w500)),
          ],
        ),
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
                  style: CType.serifDisplay(size: 20, color: palette(context).ink)),
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
                color: palette(context).surface,
                border: Border.all(color: CColors.tealLine, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.$1, style: CType.serifDisplay(size: 17)),
                  const SizedBox(height: 8),
                  Text(t.$2, style: CType.body(size: 12, color: palette(context).inkSoft)),
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

class _AllBeachesSheet extends StatefulWidget {
  final List<Beach> beaches;
  final ScrollController controller;
  const _AllBeachesSheet({required this.beaches, required this.controller});

  @override
  State<_AllBeachesSheet> createState() => _AllBeachesSheetState();
}

class _AllBeachesSheetState extends State<_AllBeachesSheet> {
  final _q = TextEditingController();
  BeachRisk? _filter;

  @override
  void dispose() { _q.dispose(); super.dispose(); }

  List<Beach> get _filtered {
    final q = _q.text.trim().toLowerCase();
    return widget.beaches.where((b) {
      if (_filter != null && b.risk != _filter) return false;
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q) || b.city.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    final list = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
          child: Row(
            children: [
              Text('Toutes les plages',
                  style: CType.serifDisplay(size: 22, color: p.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          child: Container(
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: CColors.tealLine),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(LucideIcons.search, size: 15, color: CColors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _q,
                    onChanged: (_) => setState(() {}),
                    style: CType.body(size: 13, color: p.ink),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une plage ou une ville…',
                      hintStyle: CType.body(size: 13, color: CColors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_q.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _q.clear()),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(LucideIcons.x, size: 14, color: CColors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          child: Row(
            children: [
              _RiskFilterChip(
                label: 'Toutes',
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              const SizedBox(width: 8),
              _RiskFilterChip(
                label: 'Stable',
                selected: _filter == BeachRisk.stable,
                onTap: () => setState(() => _filter = BeachRisk.stable),
              ),
              const SizedBox(width: 8),
              _RiskFilterChip(
                label: 'Modéré',
                selected: _filter == BeachRisk.modere,
                onTap: () => setState(() => _filter = BeachRisk.modere),
              ),
              const SizedBox(width: 8),
              _RiskFilterChip(
                label: 'Élevé',
                selected: _filter == BeachRisk.eleve,
                onTap: () => setState(() => _filter = BeachRisk.eleve),
              ),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('Aucune plage trouvée',
                        style: CType.body(size: 13, color: p.inkSoft)),
                  ),
                )
              : ListView.builder(
                  controller: widget.controller,
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final b = list[i];
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

class _RiskFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RiskFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
        decoration: BoxDecoration(
          color: selected ? CColors.tealDark : p.surface,
          border: Border.all(color: selected ? CColors.tealDark : CColors.tealLine),
        ),
        child: Text(label,
            style: CType.body(size: 11,
                color: selected ? Colors.white : p.ink, w: FontWeight.w500)),
      ),
    );
  }
}