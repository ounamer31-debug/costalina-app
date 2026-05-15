import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../data/mock_beaches.dart';
import '../l10n/app_strings.dart';
import '../models/beach.dart';
import '../models/signalement.dart';
import '../services/api_service.dart';
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
                      placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
                      errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x731A2E2C), Color(0x261A2E2C), Color(0xEB1A2E2C)],
                          stops: [0.0, 0.40, 1.0],
                        ),
                      ),
                    ),
                    const CornerOrnaments(),
                    Positioned(
                      top: 0, left: 0, right: 0,
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
                              Eyebrow(s.detailLabel,
                                  color: const Color(0xD9FFFFFF), size: 10, tracking: 0.32),
                              const Spacer(),
                              LangPickerBtn(color: const Color(0xD9FFFFFF)),
                              IconBtn(
                                icon: const Icon(LucideIcons.share2),
                                onTap: () {},
                                light: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22, right: 22, bottom: 22,
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
                              RiskTag(beach.risk, light: true, size: RiskTagSize.sm),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
            labelStyle: CType.eyebrow(size: 10, tracking: 0.22, color: CColors.tealDark),
            unselectedLabelStyle: CType.eyebrow(size: 10, tracking: 0.22, color: CColors.grey),
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

  @override double get maxExtent => 48;
  @override double get minExtent => 48;
  @override bool shouldRebuild(covariant _TabDelegate _) => true;
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
          trailing: GhostLink(label: s.viewMore, onTap: () {}),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ComparePhoto(url: beach.photoUrl, label: 'Mai 2023')),
            const SizedBox(width: 8),
            Expanded(child: _ComparePhoto(url: beach.photoUrl, label: 'Mai 2024', desat: true)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          decoration: BoxDecoration(
            color: CColors.white,
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
                      style: CType.serifDisplay(size: 38, color: CColors.riskInk(beach.risk)),
                    ),
                    const SizedBox(height: 6),
                    Text(s.over12months,
                        style: CType.serifDisplay(size: 13, color: CColors.inkSoft, italic: true)),
                  ],
                ),
              ),
              const HairLine(vertical: true, extent: 70, color: CColors.tealLineSoft),
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
                          size: 12, color: CColors.riskInk(beach.risk), italic: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SectionHead(
          kicker: s.communityKicker,
          title: s.communityTitle,
          italic: s.communityItalic,
          trailing: GhostLink(label: s.viewAll, onTap: () {}),
        ),
        if (mockSignalements.isNotEmpty)
          _SignalementRow(s: mockSignalements.first, first: true),
      ],
    );
  }
}

class _ComparePhoto extends StatelessWidget {
  final String url;
  final String label;
  final bool desat;

  const _ComparePhoto({required this.url, required this.label, this.desat = false});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            color: desat ? const Color(0xFF808080) : null,
            colorBlendMode: desat ? BlendMode.saturation : null,
            placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
            errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
              color: const Color(0xEBF5F0E8),
              child: Eyebrow(label, size: 9, tracking: 0.28, color: CColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Évolution tab ─────────────────────────────────────────────────────────────

class _EvolutionTab extends StatelessWidget {
  final Beach beach;
  const _EvolutionTab({required this.beach});

  static const _spots = [
    FlSpot(0, 0), FlSpot(1, -0.3), FlSpot(2, -0.6), FlSpot(3, -1.1),
    FlSpot(4, -1.5), FlSpot(5, -2.0), FlSpot(6, -2.4), FlSpot(7, -2.6),
    FlSpot(8, -2.9), FlSpot(9, -3.0), FlSpot(10, -3.1), FlSpot(11, -3.2),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 60),
      children: [
        SectionHead(kicker: s.evolutionKicker, title: s.evolutionTitle, italic: s.evolutionItalic),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
          decoration: BoxDecoration(
            color: CColors.white,
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
            color: CColors.white,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _KpiCell(
                        label: s.kpiTotal,
                        value: '${beach.erosionMeters.toStringAsFixed(1)} m',
                        tint: CColors.redInk)),
                    const HairLine(vertical: true, color: CColors.tealLineSoft),
                    Expanded(child: _KpiCell(label: s.kpiSpeed, value: '0,27 m/mois', tint: CColors.amberInk)),
                  ],
                ),
              ),
              const HairLine(color: CColors.tealLineSoft),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _KpiCell(label: s.kpiWorstMonth, value: 'Sept. 2025', tint: CColors.ink)),
                    const HairLine(vertical: true, color: CColors.tealLineSoft),
                    Expanded(child: _KpiCell(label: s.kpiConfidence, value: '92 %', tint: CColors.greenInk)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCell extends StatelessWidget {
  final String label;
  final String value;
  final Color tint;

  const _KpiCell({required this.label, required this.value, required this.tint});

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
              style: CType.body(size: 13, color: CColors.inkSoft),
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
          top: BorderSide(color: first ? CColors.tealLine : CColors.tealLineSoft, width: 1),
          bottom: const BorderSide(color: CColors.tealLineSoft, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 70,
            child: CachedNetworkImage(
              imageUrl: s.thumbUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: CColors.tealBg),
              errorWidget: (_, _, _) => const ColoredBox(color: CColors.tealBg),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.when, size: 9, tracking: 0.24),
                const SizedBox(height: 4),
                Text(s.type, style: CType.serifDisplay(size: 17)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
            decoration: BoxDecoration(
              color: CColors.riskBg(risk),
              border: Border.all(color: CColors.riskDot(risk).withValues(alpha: 0.4), width: 1),
            ),
            child: Eyebrow(statusLabel, size: 9, tracking: 0.22, color: CColors.riskInk(risk)),
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
      [s.infoRegion,      beach.city],
      [s.infoLength,      s.infoLengthValue],
      [s.infoType,        s.infoTypeValue],
      [s.infoPublicAccess, s.infoAccessValue],
      [s.infoLastSurvey,  beach.lastUpdate],
      [s.infoSources,     'Sentinel-2 · Terrain'],
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 60),
      children: [
        Container(
          decoration: BoxDecoration(
            color: CColors.white,
            border: Border.all(color: CColors.tealLine, width: 1),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  child: Row(
                    children: [
                      Eyebrow(rows[i][0], size: 9, tracking: 0.28, color: CColors.grey),
                      const Spacer(),
                      Text(rows[i][1], style: CType.serifDisplay(size: 14)),
                    ],
                  ),
                ),
                if (i < rows.length - 1) const HairLine(color: CColors.tealLineSoft),
              ],
            ],
          ),
        ),
      ],
    );
  }
}