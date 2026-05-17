import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_strings.dart';
import '../models/alerte.dart';
import '../models/beach.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/costalina_logo.dart';
import '../widgets/eyebrow.dart';
import '../widgets/hair_line.dart';
import '../widgets/icon_btn.dart';
import '../widgets/lang_picker_btn.dart';
import '../widgets/risk_tag.dart';
import '../widgets/serif_title.dart';
import 'beach_detail_screen.dart';

class AlertesScreen extends StatefulWidget {
  const AlertesScreen({super.key});

  @override
  State<AlertesScreen> createState() => _AlertesScreenState();
}

class _AlertesScreenState extends State<AlertesScreen> {
  List<Alerte> _alerts = [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _failed = false; });
    try {
      final alerts = await ApiService.getAlerts();
      if (!mounted) return;
      setState(() { _alerts = alerts; _loading = false; });
      // Mark every alert as read for the current user once the list is shown.
      // Fire-and-forget so the UI never waits on it.
      ApiService.markAllAlertsRead();
    } catch (_) {
      if (mounted) setState(() { _loading = false; _failed = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final p = palette(context);
    final urgent = _alerts.where((a) => a.risk != BeachRisk.stable).length;
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _TopBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('${_alerts.length} alertes · $urgent à traiter'),
                  const SizedBox(height: 12),
                  SerifTitle(s.alertesTitle, italic: s.alertesItalic, size: 34),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: CColors.tealDark, strokeWidth: 2)),
                ),
              )
            else if (_failed)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
                child: Column(
                  children: [
                    const Icon(LucideIcons.wifiOff, size: 32, color: CColors.grey),
                    const SizedBox(height: 12),
                    Text('Impossible de charger les alertes',
                        style: CType.body(size: 13, color: p.inkSoft),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _load,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        color: CColors.tealDark,
                        child: Text('Réessayer',
                            style: CType.eyebrow(size: 10, tracking: 0.22, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: p.surface,
                    border: Border.all(color: CColors.tealLine, width: 1),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < _alerts.length; i++)
                        _AlerteRow(alerte: _alerts[i], first: i == 0),
                    ],
                  ),
                ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 56, 22, 14),
      decoration: BoxDecoration(
        color: palette(context).bg,
        border: const Border(bottom: BorderSide(color: CColors.tealLineSoft, width: 1)),
      ),
      child: Row(
        children: [
          const CostalinaLogo(size: 32),
          const Spacer(),
          const LangPickerBtn(),
          IconBtn(icon: const Icon(LucideIcons.settings), onTap: () => _showSettings(context)),
        ],
      ),
    );
  }
}

void _showSettings(BuildContext context) {
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
              Text(AppStrings.current.profilSettings,
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
        _SettingsRow(icon: LucideIcons.globe, label: AppStrings.current.chooseLanguage,
            onTap: () { Navigator.pop(context); showLangPicker(context); }),
        const SizedBox(height: 32),
      ],
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.label, this.onTap});

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

class _AlerteRow extends StatefulWidget {
  final Alerte alerte;
  final bool first;

  const _AlerteRow({required this.alerte, this.first = false});

  @override
  State<_AlerteRow> createState() => _AlerteRowState();
}

class _AlerteRowState extends State<_AlerteRow> {
  bool _navigating = false;

  Future<void> _openBeach(BuildContext context, Alerte alerte) async {
    if (_navigating) return;
    setState(() => _navigating = true);
    try {
      final beach = await ApiService.getBeach(alerte.beachId);
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => BeachDetailScreen(beach: beach)));
    } catch (_) {
      // Beach not found in API — fall back to a minimal stub so we never crash
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Plage introuvable', style: CType.body(size: 13, color: Colors.white)),
        backgroundColor: CColors.tealDark,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _navigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerte = widget.alerte;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.first) const HairLine(color: CColors.tealLineSoft),
        GestureDetector(
          onTap: () => _openBeach(context, alerte),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 14),
                  child: ClipPath(
                    clipper: _StarClipper(),
                    child: SizedBox(
                      width: 6,
                      height: 6,
                      child: ColoredBox(color: CColors.riskDot(alerte.risk)),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(alerte.beachName,
                                style: CType.serifDisplay(size: 17)),
                          ),
                          if (!alerte.read) ...[
                            const SizedBox(width: 8),
                            Container(width: 7, height: 7,
                                decoration: const BoxDecoration(
                                    color: CColors.tealDark, shape: BoxShape.circle)),
                          ],
                          const SizedBox(width: 10),
                          Eyebrow(alerte.time, size: 9, tracking: 0.18, color: CColors.grey),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(alerte.message,
                          style: CType.body(size: 12, color: palette(context).inkSoft)),
                      const SizedBox(height: 8),
                      RiskTag(alerte.risk, size: RiskTagSize.sm),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final pts = [
      Offset(0.50 * s.width, 0.00 * s.height),
      Offset(0.61 * s.width, 0.35 * s.height),
      Offset(0.98 * s.width, 0.35 * s.height),
      Offset(0.68 * s.width, 0.57 * s.height),
      Offset(0.79 * s.width, 0.91 * s.height),
      Offset(0.50 * s.width, 0.70 * s.height),
      Offset(0.21 * s.width, 0.91 * s.height),
      Offset(0.32 * s.width, 0.57 * s.height),
      Offset(0.02 * s.width, 0.35 * s.height),
      Offset(0.39 * s.width, 0.35 * s.height),
    ];
    return Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..addPolygon(pts, true);
  }

  @override
  bool shouldReclip(_) => false;
}