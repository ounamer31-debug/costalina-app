import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';

import '../data/mock_beaches.dart';
import '../l10n/app_strings.dart';
import '../models/beach.dart';
import '../models/report_type.dart';
import '../models/signalement.dart';
import '../services/api_service.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import '../widgets/corner_ornaments.dart';
import '../widgets/eyebrow.dart';
import '../widgets/ghost_link.dart';
import '../widgets/hair_line.dart';
import '../widgets/icon_btn.dart';
import '../widgets/lang_picker_btn.dart';
import '../widgets/risk_tag.dart';
import '../widgets/section_head.dart';
import '../widgets/serif_title.dart';
import '../widgets/star_gauge.dart';

class BeachDetailScreen extends StatelessWidget {
  final Beach beach;
  const BeachDetailScreen({super.key, required this.beach});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: CColors.sand,
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 360,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: beach.photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: CColors.tealBg),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: CColors.tealBg),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x731A2E2C),
                            Color(0x261A2E2C),
                            Color(0xEB1A2E2C),
                          ],
                          stops: [0.0, 0.40, 1.0],
                        ),
                      ),
                    ),
                    const CornerOrnaments(),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                          child: Row(
                            children: [
                              IconBtn(
                                icon: const Icon(LucideIcons.arrowLeft),
                                onTap: () => Navigator.pop(context),
                                light: true,
                              ),
                              const Spacer(),
                              Eyebrow(
                                s.detailLabel,
                                color: const Color(0xD9FFFFFF),
                                size: 10,
                                tracking: 0.32,
                              ),
                              const Spacer(),
                              LangPickerBtn(color: const Color(0xD9FFFFFF)),
                              if (AuthService.currentUser != null)
                                _FollowButton(beachId: beach.id),
                              IconBtn(
                                icon: const Icon(LucideIcons.share2),
                                onTap: () {
                                  Share.share(
                                    'Costalina — ${beach.name}, ${beach.city}. '
                                        'Surveillance du littoral tunisien.',
                                    subject: 'Costalina · ${beach.name}',
                                  );
                                },
                                light: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      right: 22,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(
                            '${beach.city} · ${s.updateLabel} ${beach.lastUpdate}',
                            color: const Color(0xF2A8DDD8),
                            size: 10,
                            tracking: 0.35,
                          ),
                          const SizedBox(height: 8),
                          SerifTitle(beach.name, size: 32, color: Colors.white),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              RiskTag(
                                beach.risk,
                                light: true,
                                size: RiskTagSize.sm,
                              ),
                              const SizedBox(width: 12),
                              StarGauge.fromRisk(beach.risk, size: 7, gap: 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(pinned: true, delegate: _TabDelegate()),
          ],
          body: TabBarView(
            children: [
              _ApercuTab(beach: beach),
              _EvolutionTab(beach: beach),
              _SignalementsTab(beachId: beach.id),
              _InfosTab(beach: beach),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final s = AppStrings.current;
    return Container(
      color: CColors.sand,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            indicatorColor: CColors.tealDark,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: CColors.tealDark,
            unselectedLabelColor: CColors.grey,
            labelStyle: CType.eyebrow(
              size: 10,
              tracking: 0.22,
              color: CColors.tealDark,
            ),
            unselectedLabelStyle: CType.eyebrow(
              size: 10,
              tracking: 0.22,
              color: CColors.grey,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: s.tabApercu),
              Tab(text: s.tabEvolution),
              Tab(text: s.tabSignalements),
              Tab(text: s.tabInfos),
            ],
          ),
          const HairLine(color: CColors.tealLine),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant _TabDelegate _) => true;
}

// ── Aperçu tab ────────────────────────────────────────────────────────────────

class _ApercuTab extends StatelessWidget {
  final Beach beach;
  const _ApercuTab({required this.beach});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 60),
      children: [
        SectionHead(
          kicker: s.sectionBeforeAfterKicker,
          title: s.sectionBeforeAfterTitle,
          italic: s.sectionBeforeAfterItalic,
          trailing: GhostLink(
            label: s.viewMore,
            onTap: () => DefaultTabController.of(context).animateTo(1),
          ),
        ),
        _BeforeAfterSlider(
          beforeUrl: beach.photos.isNotEmpty ? beach.photos.first : beach.photoUrl,
          afterUrl:  beach.photos.length > 1 ? beach.photos.last : beach.photoUrl,
          beforeLabel: 'Mai 2023',
          afterLabel:  'Mai 2026',
          desatAfter: beach.photos.length < 2,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          decoration: BoxDecoration(
            color: palette(context).surface,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(s.estimatedRecul, size: 9, tracking: 0.32),
                    const SizedBox(height: 8),
                    Text(
                      '${beach.erosionMeters.toStringAsFixed(1)} m',
                      style: CType.serifDisplay(
                        size: 38,
                        color: CColors.riskInk(beach.risk),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.over12months,
                      style: CType.serifDisplay(
                        size: 13,
                        color: palette(context).inkSoft,
                        italic: true,
                      ),
                    ),
                  ],
                ),
              ),
              const HairLine(
                vertical: true,
                extent: 70,
                color: CColors.tealLineSoft,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(s.severity, size: 9, tracking: 0.28),
                    const SizedBox(height: 8),
                    StarGauge.fromRisk(beach.risk, size: 8, gap: 4),
                    const SizedBox(height: 8),
                    Text(
                      s.riskLabel(beach.risk),
                      style: CType.serifDisplay(
                        size: 12,
                        color: CColors.riskInk(beach.risk),
                        italic: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SectionHead(
          kicker: 'PRÉVISION IA',
          title: 'Tendance ',
          italic: 'estimée',
        ),
        _AiForecastCard(beachId: beach.id),
        const SizedBox(height: 30),
        SectionHead(
          kicker: 'MARÉE & MER',
          title: 'Conditions ',
          italic: 'maritimes',
        ),
        _MarineCard(lat: beach.lat, lng: beach.lng),
        if (beach.photos.length > 1) ...[
          const SizedBox(height: 30),
          SectionHead(
            kicker: 'GALERIE',
            title: 'Photos ',
            italic: 'du terrain',
          ),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: beach.photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _showFullPhoto(context, beach.photos, i),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: beach.photos[i],
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: CColors.tealBg),
                    errorWidget: (_, _, _) =>
                        const ColoredBox(color: CColors.tealBg),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 30),
        SectionHead(
          kicker: s.communityKicker,
          title: s.communityTitle,
          italic: s.communityItalic,
          trailing: GhostLink(
            label: s.viewAll,
            onTap: () => DefaultTabController.of(context).animateTo(2),
          ),
        ),
        if (mockSignalements.isNotEmpty)
          _SignalementRow(s: mockSignalements.first, first: true),
      ],
    );
  }
}

void _showFullPhoto(BuildContext context, List<String> photos, int initial) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (_, _, _) =>
          _FullPhotoView(photos: photos, initial: initial),
    ),
  );
}

class _FullPhotoView extends StatefulWidget {
  final List<String> photos;
  final int initial;
  const _FullPhotoView({required this.photos, required this.initial});

  @override
  State<_FullPhotoView> createState() => _FullPhotoViewState();
}

class _FullPhotoViewState extends State<_FullPhotoView> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.photos.length,
            itemBuilder: (_, i) => InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.photos[i],
                fit: BoxFit.contain,
                placeholder: (_, _) => const Center(
                  child: CircularProgressIndicator(color: CColors.teal),
                ),
                errorWidget: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: CColors.grey,
                  size: 48,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeforeAfterSlider extends StatefulWidget {
  final String beforeUrl;
  final String afterUrl;
  final String beforeLabel;
  final String afterLabel;
  final bool desatAfter;
  const _BeforeAfterSlider({
    required this.beforeUrl,
    required this.afterUrl,
    required this.beforeLabel,
    required this.afterLabel,
    this.desatAfter = false,
  });

  @override
  State<_BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<_BeforeAfterSlider> {
  double _frac = 0.5;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 5 / 4,
      child: LayoutBuilder(
        builder: (_, c) {
          final w = c.maxWidth;
          final handleX = (w * _frac).clamp(0.0, w);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) {
              setState(() {
                _frac = ((handleX + d.delta.dx) / w).clamp(0.0, 1.0);
              });
            },
            onTapDown: (d) {
              setState(() => _frac = (d.localPosition.dx / w).clamp(0.0, 1.0));
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // "After" image (full width, bottom layer)
                CachedNetworkImage(
                  imageUrl: widget.afterUrl,
                  fit: BoxFit.cover,
                  color: widget.desatAfter ? const Color(0xFF808080) : null,
                  colorBlendMode: widget.desatAfter ? BlendMode.saturation : null,
                  placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
                  errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
                ),
                // "Before" image clipped to left fraction
                ClipRect(
                  clipper: _RightClip(_frac),
                  child: CachedNetworkImage(
                    imageUrl: widget.beforeUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
                    errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
                  ),
                ),
                // Labels
                Positioned(
                  left: 10, bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
                    color: palette(context).bg.withValues(alpha: 0.92),
                    child: Eyebrow(widget.beforeLabel,
                        size: 9, tracking: 0.28, color: palette(context).ink),
                  ),
                ),
                Positioned(
                  right: 10, bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
                    color: palette(context).bg.withValues(alpha: 0.92),
                    child: Eyebrow(widget.afterLabel,
                        size: 9, tracking: 0.28, color: palette(context).ink),
                  ),
                ),
                // Drag handle (vertical line + dot)
                Positioned(
                  left: handleX - 1, top: 0, bottom: 0, width: 2,
                  child: Container(color: Colors.white),
                ),
                Positioned(
                  left: handleX - 18, top: 0, bottom: 0,
                  child: Center(
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(LucideIcons.moveHorizontal,
                          size: 16, color: CColors.tealDark),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RightClip extends CustomClipper<Rect> {
  final double frac;
  const _RightClip(this.frac);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * frac, size.height);

  @override
  bool shouldReclip(_RightClip old) => old.frac != frac;
}

// ── Évolution tab ─────────────────────────────────────────────────────────────

class _EvolutionTab extends StatelessWidget {
  final Beach beach;
  const _EvolutionTab({required this.beach});

  static const _spots = [
    FlSpot(0, 0),
    FlSpot(1, -0.3),
    FlSpot(2, -0.6),
    FlSpot(3, -1.1),
    FlSpot(4, -1.5),
    FlSpot(5, -2.0),
    FlSpot(6, -2.4),
    FlSpot(7, -2.6),
    FlSpot(8, -2.9),
    FlSpot(9, -3.0),
    FlSpot(10, -3.1),
    FlSpot(11, -3.2),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 60),
      children: [
        SectionHead(
          kicker: s.evolutionKicker,
          title: s.evolutionTitle,
          italic: s.evolutionItalic,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
          decoration: BoxDecoration(
            color: palette(context).surface,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 6,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    color: CColors.tealDark,
                    barWidth: 1.6,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x475BBCB0), Color(0x005BBCB0)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: palette(context).surface,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _KpiCell(
                        label: s.kpiTotal,
                        value: '${beach.erosionMeters.toStringAsFixed(1)} m',
                        tint: CColors.redInk,
                      ),
                    ),
                    const HairLine(vertical: true, color: CColors.tealLineSoft),
                    Expanded(
                      child: _KpiCell(
                        label: s.kpiSpeed,
                        value: '0,27 m/mois',
                        tint: CColors.amberInk,
                      ),
                    ),
                  ],
                ),
              ),
              const HairLine(color: CColors.tealLineSoft),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _KpiCell(
                        label: s.kpiWorstMonth,
                        value: 'Sept. 2025',
                        tint: CColors.ink,
                      ),
                    ),
                    const HairLine(vertical: true, color: CColors.tealLineSoft),
                    Expanded(
                      child: _KpiCell(
                        label: s.kpiConfidence,
                        value: '92 %',
                        tint: CColors.greenInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SectionHead(
          kicker: 'SIGNALEMENTS',
          title: 'Activité ',
          italic: '12 derniers mois',
        ),
        _ReportsTimelineChart(beachId: beach.id),
      ],
    );
  }
}

class _ReportsTimelineChart extends StatefulWidget {
  final String beachId;
  const _ReportsTimelineChart({required this.beachId});

  @override
  State<_ReportsTimelineChart> createState() => _ReportsTimelineChartState();
}

class _ReportsTimelineChartState extends State<_ReportsTimelineChart> {
  late Future<List<TimelineBucket>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getBeachTimeline(widget.beachId);
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return FutureBuilder<List<TimelineBucket>>(
      future: _future,
      builder: (_, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final data = snap.data ?? const <TimelineBucket>[];
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: loading
              ? const SizedBox(
                  height: 140,
                  child: Center(
                    child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: CColors.teal)),
                  ),
                )
              : data.every((b) => b.total == 0)
                  ? SizedBox(
                      height: 140,
                      child: Center(
                        child: Text('Aucun signalement sur cette période',
                            style: CType.body(size: 12, color: p.inkSoft)),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 140,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceBetween,
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    interval: 1,
                                    getTitlesWidget: (v, _) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= data.length) return const SizedBox.shrink();
                                      if (i % 2 != 0 && i != data.length - 1) return const SizedBox.shrink();
                                      final mm = data[i].month.split('-').last;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(mm,
                                            style: CType.eyebrow(
                                                size: 8, tracking: 0.18,
                                                color: p.inkSoft, w: FontWeight.w400)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                for (int i = 0; i < data.length; i++)
                                  BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: data[i].total.toDouble(),
                                        width: 8,
                                        borderRadius: BorderRadius.zero,
                                        rodStackItems: [
                                          BarChartRodStackItem(0,
                                              data[i].erosion.toDouble(),
                                              CColors.tealDark),
                                          BarChartRodStackItem(
                                              data[i].erosion.toDouble(),
                                              (data[i].erosion + data[i].pollution).toDouble(),
                                              CColors.amberInk),
                                          BarChartRodStackItem(
                                              (data[i].erosion + data[i].pollution).toDouble(),
                                              data[i].total.toDouble(),
                                              CColors.grey),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _LegendItem(color: CColors.tealDark, label: 'Érosion'),
                            SizedBox(width: 14),
                            _LegendItem(color: CColors.amberInk, label: 'Pollution'),
                            SizedBox(width: 14),
                            _LegendItem(color: CColors.grey, label: 'Autre'),
                          ],
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 5),
        Text(label, style: CType.eyebrow(size: 9, tracking: 0.22, color: palette(context).inkSoft, w: FontWeight.w400)),
      ],
    );
  }
}

class _KpiCell extends StatelessWidget {
  final String label;
  final String value;
  final Color tint;

  const _KpiCell({
    required this.label,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label, size: 9, tracking: 0.28),
          const SizedBox(height: 8),
          Text(value, style: CType.serifDisplay(size: 22, color: tint)),
        ],
      ),
    );
  }
}

// ── Signalements tab ──────────────────────────────────────────────────────────

class _SignalementsTab extends StatefulWidget {
  final String beachId;
  const _SignalementsTab({required this.beachId});

  @override
  State<_SignalementsTab> createState() => _SignalementsTabState();
}

class _SignalementsTabState extends State<_SignalementsTab> {
  late Future<List<Signalement>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getReports(beachId: widget.beachId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Signalement>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Center(
            child: Text(
              'Aucun signalement pour cette plage.',
              style: CType.body(size: 13, color: palette(context).inkSoft),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 60),
          itemCount: list.length,
          itemBuilder: (_, i) => _SignalementRow(s: list[i], first: i == 0),
        );
      },
    );
  }
}

class _SignalementRow extends StatelessWidget {
  final Signalement s;
  final bool first;

  const _SignalementRow({required this.s, this.first = false});

  @override
  Widget build(BuildContext context) {
    final risk = s.status == 'resolved' ? BeachRisk.stable : BeachRisk.modere;
    final statusLabel = switch (s.status) {
      'resolved' => 'Résolu',
      'verified' => 'Vérifié',
      _ => 'En cours',
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: first ? CColors.tealLine : CColors.tealLineSoft,
            width: 1,
          ),
          bottom: const BorderSide(color: CColors.tealLineSoft, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 70,
            child: s.thumbUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: s.thumbUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: CColors.tealBg),
                    errorWidget: (_, _, _) =>
                        const ColoredBox(color: CColors.tealBg),
                  )
                : Container(
                    color: CColors.tealBg,
                    alignment: Alignment.center,
                    child: const Icon(
                      LucideIcons.camera,
                      size: 20,
                      color: CColors.teal,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.when, size: 9, tracking: 0.24),
                const SizedBox(height: 4),
                Text(s.type.label, style: CType.serifDisplay(size: 17)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
            decoration: BoxDecoration(
              color: CColors.riskBg(risk),
              border: Border.all(
                color: CColors.riskDot(risk).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Eyebrow(
              statusLabel,
              size: 9,
              tracking: 0.22,
              color: CColors.riskInk(risk),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Infos tab ─────────────────────────────────────────────────────────────────

class _InfosTab extends StatelessWidget {
  final Beach beach;
  const _InfosTab({required this.beach});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final rows = [
      [s.infoRegion, beach.city],
      [s.infoLength, s.infoLengthValue],
      [s.infoType, s.infoTypeValue],
      [s.infoPublicAccess, s.infoAccessValue],
      [s.infoLastSurvey, beach.lastUpdate],
      [s.infoSources, 'Sentinel-2 · Terrain'],
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 60),
      children: [
        Container(
          decoration: BoxDecoration(
            color: palette(context).surface,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  child: Row(
                    children: [
                      Eyebrow(
                        rows[i][0],
                        size: 9,
                        tracking: 0.28,
                        color: CColors.grey,
                      ),
                      const Spacer(),
                      Text(rows[i][1], style: CType.serifDisplay(size: 14)),
                    ],
                  ),
                ),
                if (i < rows.length - 1)
                  const HairLine(color: CColors.tealLineSoft),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MarineCard extends StatefulWidget {
  final double lat;
  final double lng;
  const _MarineCard({required this.lat, required this.lng});

  @override
  State<_MarineCard> createState() => _MarineCardState();
}

class _MarineCardState extends State<_MarineCard> {
  late Future<MarineData?> _future;

  @override
  void initState() {
    super.initState();
    _future = WeatherService.fetchMarine(lat: widget.lat, lng: widget.lng);
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return FutureBuilder<MarineData?>(
      future: _future,
      builder: (_, snap) {
        final data = snap.data;
        final loading = snap.connectionState == ConnectionState.waiting;
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: loading
              ? const SizedBox(
                  height: 70,
                  child: Center(
                    child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: CColors.teal),
                    ),
                  ),
                )
              : data == null
                  ? SizedBox(
                      height: 70,
                      child: Center(
                        child: Text('Données maritimes indisponibles',
                            style: CType.body(size: 12, color: p.inkSoft)),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(child: _MarineStat(
                          label: 'VAGUES',
                          value: data.waveHeight != null
                              ? '${data.waveHeight!.toStringAsFixed(1)} m'
                              : '—',
                        )),
                        const HairLine(vertical: true, extent: 56, color: CColors.tealLineSoft),
                        Expanded(child: _MarineStat(
                          label: 'PÉRIODE',
                          value: data.wavePeriod != null
                              ? '${data.wavePeriod!.toStringAsFixed(1)} s'
                              : '—',
                        )),
                        const HairLine(vertical: true, extent: 56, color: CColors.tealLineSoft),
                        Expanded(child: _MarineStat(
                          label: 'TEMP. MER',
                          value: data.seaSurfTemp != null
                              ? '${data.seaSurfTemp!.toStringAsFixed(1)}°'
                              : '—',
                        )),
                      ],
                    ),
        );
      },
    );
  }
}

class _MarineStat extends StatelessWidget {
  final String label;
  final String value;
  const _MarineStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label, size: 9, tracking: 0.24),
        const SizedBox(height: 8),
        Text(value, style: CType.serifDisplay(size: 22, color: p.ink)),
      ],
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String beachId;
  const _FollowButton({required this.beachId});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _followed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await ApiService.getFollowedBeaches();
    if (!mounted) return;
    setState(() => _followed = ids.contains(widget.beachId));
  }

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    final wasFollowed = _followed;
    setState(() => _followed = !wasFollowed);
    final ok = wasFollowed
        ? await ApiService.unfollowBeach(widget.beachId)
        : await ApiService.followBeach(widget.beachId);
    if (!mounted) return;
    if (!ok) setState(() => _followed = wasFollowed);
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconBtn(
      icon: Icon(_followed ? LucideIcons.heart : LucideIcons.heart,
          color: _followed ? Colors.red.shade300 : null),
      onTap: _toggle,
      light: true,
    );
  }
}

// ── AI risk-forecast card ────────────────────────────────────────────────────

class _AiForecastCard extends StatefulWidget {
  final String beachId;
  const _AiForecastCard({required this.beachId});

  @override
  State<_AiForecastCard> createState() => _AiForecastCardState();
}

class _AiForecastCardState extends State<_AiForecastCard> {
  AiForecast? _forecast;
  bool _loading = true;
  bool _failed  = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _failed = false; });
    final f = await ApiService.getBeachForecast(widget.beachId);
    if (!mounted) return;
    setState(() {
      _forecast = f;
      _loading = false;
      _failed = f == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = palette(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: CColors.tealLine),
      ),
      child: _loading
          ? Row(
              children: [
                const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: CColors.tealDark)),
                const SizedBox(width: 12),
                Text("L'IA analyse les signalements récents…",
                    style: CType.body(size: 12, color: p.inkSoft)),
              ],
            )
          : _failed
              ? Row(
                  children: [
                    const Icon(LucideIcons.wifiOff, size: 16, color: CColors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Prévision indisponible pour le moment.',
                          style: CType.body(size: 12, color: p.inkSoft)),
                    ),
                    GestureDetector(
                      onTap: _load,
                      child: Text('Réessayer',
                          style: CType.body(size: 12, color: CColors.tealDark)),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.sparkles, size: 14, color: CColors.tealDark),
                        const SizedBox(width: 8),
                        Eyebrow(
                          'PRÉVISION · CONFIANCE ${_forecast!.confidence.toUpperCase()}',
                          size: 9, tracking: 0.22, color: CColors.tealDark,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          color: _riskBg(_forecast!.risk),
                          child: Text(
                            _riskLabel(_forecast!.risk),
                            style: CType.eyebrow(
                              size: 9, tracking: 0.22,
                              color: _riskInk(_forecast!.risk),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_forecast!.summary,
                        style: CType.body(size: 13, color: p.ink)),
                  ],
                ),
    );
  }

  Color _riskBg(String r) => switch (r) {
        'eleve'  => const Color(0xFFFCE7E0),
        'modere' => const Color(0xFFFCEFD3),
        _        => const Color(0xFFE6F4EF),
      };

  Color _riskInk(String r) => switch (r) {
        'eleve'  => const Color(0xFFA8331E),
        'modere' => const Color(0xFF8B5A12),
        _        => const Color(0xFF1F6F5A),
      };

  String _riskLabel(String r) => switch (r) {
        'eleve'  => 'RISQUE ÉLEVÉ',
        'modere' => 'RISQUE MODÉRÉ',
        _        => 'STABLE',
      };
}
