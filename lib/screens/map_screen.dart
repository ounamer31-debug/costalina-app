import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/mock_beaches.dart';
import '../l10n/app_strings.dart';
import '../models/beach.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/costalina_logo.dart';
import '../widgets/eyebrow.dart';
import '../widgets/lang_picker_btn.dart';
import '../widgets/hair_line.dart';
import '../widgets/icon_btn.dart';
import '../widgets/serif_title.dart';
import '../widgets/star_gauge.dart';
import 'beach_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _monastir = LatLng(35.7643, 10.8113);

  final MapController _map = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Beach? _selected;
  LatLng? _userPos;
  StreamSubscription<Position>? _posSub;
  bool _locating = false;
  List<Beach> _results = [];
  List<Beach> _beaches = mockBeaches;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _locateMe(center: false));
    _loadBeaches();
  }

  Future<void> _loadBeaches() async {
    try {
      final beaches = await ApiService.getBeaches();
      if (mounted) setState(() => _beaches = beaches);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _posSub?.cancel();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? []
          : _beaches
              .where((b) =>
                  b.name.toLowerCase().contains(q) ||
                  b.city.toLowerCase().contains(q))
              .toList();
    });
  }

  void _selectFromSearch(Beach beach) {
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() {
      _results = [];
      _selected = beach;
    });
    _map.move(LatLng(beach.lat, beach.lng), 14);
  }

  Future<void> _locateMe({bool center = true}) async {
    if (_locating) return;
    setState(() => _locating = true);
    final result = await LocationService.instance.getCurrent();
    if (!mounted) return;
    setState(() => _locating = false);

    switch (result.status) {
      case LocationStatus.ok:
        final p = result.position!;
        final ll = LatLng(p.latitude, p.longitude);
        setState(() => _userPos = ll);
        if (center) _map.move(ll, 14);
        _posSub ??= LocationService.instance.watch().listen((pos) {
          if (!mounted) return;
          setState(() => _userPos = LatLng(pos.latitude, pos.longitude));
        });
        break;
      case LocationStatus.serviceDisabled:
        _snack('Activez la localisation dans les réglages.');
        break;
      case LocationStatus.denied:
        _snack('Permission de localisation refusée.');
        break;
      case LocationStatus.error:
        _snack('Impossible d\'obtenir la position. Réessayez en extérieur.');
        break;
      case LocationStatus.deniedForever:
        _snack(
          'Permission bloquée. Activez-la dans Réglages > Costalina.',
          action: SnackBarAction(
            label: 'Ouvrir',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        );
        break;
    }
  }

  void _snack(String msg, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), action: action),
    );
  }

  Future<void> _navigateTo(Beach beach) async {
    final lat = beach.lat;
    final lng = beach.lng;
    final name = Uri.encodeComponent(beach.name);
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)');
    final mapsUri =
        Uri.parse('https://maps.google.com/?q=$lat,$lng&ll=$lat,$lng');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _results.isNotEmpty || _searchFocus.hasFocus;
    final p = palette(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          _MapHeader(
            searchCtrl: _searchCtrl,
            searchFocus: _searchFocus,
            onLocate: _locateMe,
          ),
          // ── Map + overlays ────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Satellite tiles
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _map,
                    options: const MapOptions(
                      initialCenter: _monastir,
                      initialZoom: 11,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.png?key=EGq2ye5EBn94rJEWBx5J',
                        userAgentPackageName: 'com.costalina.app',
                        tileProvider: CancellableNetworkTileProvider(),
                      ),
                      const SimpleAttributionWidget(
                        source: Text('© MapTiler © OpenStreetMap',
                            style: TextStyle(fontSize: 9)),
                      ),
                      MarkerLayer(
                        markers: [
                          for (final b in _beaches)
                            Marker(
                              point: LatLng(b.lat, b.lng),
                              width: 32,
                              height: 32,
                              child: GestureDetector(
                                onTap: () {
                                  _searchFocus.unfocus();
                                  setState(() {
                                    _selected = b;
                                    _results = [];
                                    _searchCtrl.clear();
                                  });
                                },
                                child: Center(
                                  child: _StarPin(
                                    risk: b.risk,
                                    active: _selected?.id == b.id,
                                  ),
                                ),
                              ),
                            ),
                          if (_userPos != null)
                            Marker(
                              point: _userPos!,
                              width: 24,
                              height: 24,
                              child: const _UserDot(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Search results overlay ───────────────────────────
                if (isSearching)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 320),
                      decoration: BoxDecoration(
                        color: CColors.sand,
                        border: const Border(
                          bottom: BorderSide(
                              color: CColors.tealLine, width: 1),
                        ),
                        boxShadow: CShadows.mapInfoCard,
                      ),
                      child: _results.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                              child: Text(
                                AppStrings.current.noBeachFound,
                                style: CType.body(
                                    size: 13, color: CColors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _results.length,
                              itemBuilder: (_, i) => _SearchResultRow(
                                beach: _results[i],
                                onTap: () => _selectFromSearch(_results[i]),
                              ),
                            ),
                    ),
                  ),

                // ── Info card ─────────────────────────────────────────
                if (_selected != null && !isSearching)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 200,
                    child: _MapInfoCard(
                      beach: _selected!,
                      onClose: () => setState(() => _selected = null),
                      onNavigate: () => _navigateTo(_selected!),
                    ),
                  ),

                // ── Locate FAB ────────────────────────────────────────
                if (!isSearching)
                  Positioned(
                    right: 16,
                    bottom: 164,
                    child: GestureDetector(
                      onTap: _locateMe,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: CColors.white,
                          border:
                              Border.all(color: CColors.tealLine, width: 1),
                          boxShadow: CShadows.mapInfoCard,
                        ),
                        child: _locating
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      CColors.teal),
                                ),
                              )
                            : const Icon(LucideIcons.locateFixed,
                                size: 18, color: CColors.tealDark),
                      ),
                    ),
                  ),

                // ── Legend strip — only when a beach is selected ─────
                if (_selected != null && !isSearching)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 110,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: CColors.white,
                        border:
                            Border.all(color: CColors.tealLine, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _LegendItem(risk: BeachRisk.stable, label: AppStrings.current.riskStableShort),
                          const HairLine(vertical: true, extent: 14, color: CColors.tealLineSoft),
                          _LegendItem(risk: BeachRisk.modere, label: AppStrings.current.riskModereShort),
                          const HairLine(vertical: true, extent: 14, color: CColors.tealLineSoft),
                          _LegendItem(risk: BeachRisk.eleve,  label: AppStrings.current.riskEleveShort),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map header ────────────────────────────────────────────────────────────────

class _MapHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final VoidCallback onLocate;

  const _MapHeader({
    required this.searchCtrl,
    required this.searchFocus,
    required this.onLocate,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(22, top + 14, 22, 18),
      decoration: BoxDecoration(
        color: palette(context).bg,
        border: const Border(
            bottom: BorderSide(color: CColors.tealLineSoft, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CostalinaLogo(size: 32),
              const Spacer(),
              Eyebrow(AppStrings.current.mapEyebrow, size: 11, tracking: 0.32),
              const Spacer(),
              const LangPickerBtn(),
              IconBtn(icon: const Icon(LucideIcons.sliders), onTap: () => _showMapFilter(context)),
            ],
          ),
          const SizedBox(height: 14),
          SerifTitle(AppStrings.current.mapTitle, italic: AppStrings.current.mapItalic, size: 26),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: CColors.white,
                    border:
                        Border.all(color: CColors.tealLine, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search,
                          size: 16, color: CColors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          focusNode: searchFocus,
                          style:
                              CType.body(size: 13, color: CColors.ink),
                          decoration: InputDecoration(
                            hintText: AppStrings.current.searchHint,
                            hintStyle: CType.body(
                                size: 13, color: CColors.grey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      // Clear button
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchCtrl,
                        builder: (_, val, _) => val.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                  searchFocus.unfocus();
                                },
                                child: const Icon(LucideIcons.x,
                                    size: 14, color: CColors.grey),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onLocate,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: CColors.white,
                    border:
                        Border.all(color: CColors.tealLine, width: 1),
                  ),
                  child: const Icon(LucideIcons.locateFixed,
                      size: 18, color: CColors.tealDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Map filter sheet ──────────────────────────────────────────────────────────

void _showMapFilter(BuildContext context) {
  final s = AppStrings.current;
  showModalBottomSheet(
    context: context,
    backgroundColor: CColors.sand,
    shape: const RoundedRectangleBorder(),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
          child: Row(
            children: [
              Text(s.mapFilterTitle, style: CType.serifDisplay(size: 22, color: CColors.ink)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
              ),
            ],
          ),
        ),
        const HairLine(color: CColors.tealLine),
        for (final risk in BeachRisk.values) ...[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: CColors.riskDot(risk),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(s.riskLabel(risk), style: CType.serifDisplay(size: 17)),
                  const Spacer(),
                  const Icon(LucideIcons.check, size: 16, color: CColors.tealDark),
                ],
              ),
            ),
          ),
          const HairLine(color: CColors.tealLineSoft),
        ],
        const SizedBox(height: 32),
      ],
    ),
  );
}

// ── Search result row ─────────────────────────────────────────────────────────

class _SearchResultRow extends StatelessWidget {
  final Beach beach;
  final VoidCallback onTap;

  const _SearchResultRow({required this.beach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HairLine(color: CColors.tealLineSoft),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Row(
              children: [
                ClipPath(
                  clipper: _StarClipper(),
                  child: SizedBox(
                    width: 8,
                    height: 8,
                    child: ColoredBox(
                        color: CColors.riskDot(beach.risk)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(beach.name,
                          style: CType.serifDisplay(size: 16)),
                      const SizedBox(height: 2),
                      Eyebrow(beach.city,
                          size: 9,
                          tracking: 0.24,
                          color: CColors.grey),
                    ],
                  ),
                ),
                Text('→',
                    style: CType.body(
                        size: 16,
                        color: CColors.tealDark,
                        w: FontWeight.w300)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star-shaped beach pin ─────────────────────────────────────────────────────

class _StarPin extends StatelessWidget {
  final BeachRisk risk;
  final bool active;

  const _StarPin({required this.risk, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = CColors.riskDot(risk);
    final starSize = active ? 14.0 : 9.0;
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (active)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1),
                shape: BoxShape.circle,
              ),
            ),
          ClipPath(
            clipper: _StarClipper(),
            child: SizedBox(
              width: starSize,
              height: starSize,
              child: ColoredBox(color: color),
            ),
          ),
        ],
      ),
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

// ── User location dot ─────────────────────────────────────────────────────────

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: CColors.teal.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: CColors.teal,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
          ),
        ),
      ],
    );
  }
}

// ── Map info card (with navigate button) ──────────────────────────────────────

class _MapInfoCard extends StatelessWidget {
  final Beach beach;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const _MapInfoCard({
    required this.beach,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: CColors.white,
        border: Border.all(color: CColors.tealLine, width: 1),
        boxShadow: CShadows.mapInfoCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(beach.city, size: 9, tracking: 0.28),
                    const SizedBox(height: 4),
                    Text(beach.name,
                        style: CType.serifDisplay(size: 18)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  onClose();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BeachDetailScreen(beach: beach)),
                  );
                },
                child: Text('→',
                    style: CType.body(
                        size: 18,
                        color: CColors.tealDark,
                        w: FontWeight.w300)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StarGauge.fromRisk(beach.risk, size: 7, gap: 3),
              const SizedBox(width: 8),
              Text(AppStrings.current.riskLabel(beach.risk),
                  style: CType.serifDisplay(
                      size: 12,
                      color: CColors.inkSoft,
                      italic: true)),
            ],
          ),
          const SizedBox(height: 10),
          const HairLine(color: CColors.tealLineSoft),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Eyebrow('${AppStrings.current.updatePrefix} ${beach.lastUpdate}',
                  size: 8, tracking: 0.24, color: CColors.grey),
              // Navigate button
              GestureDetector(
                onTap: onNavigate,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.navigation,
                        size: 12, color: CColors.tealDark),
                    const SizedBox(width: 6),
                    Text(AppStrings.current.navigate,
                        style: CType.eyebrow(
                            size: 9,
                            tracking: 0.22,
                            color: CColors.tealDark,
                            w: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Legend item ───────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final BeachRisk risk;
  final String label;

  const _LegendItem({required this.risk, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = CColors.riskDot(risk);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipPath(
          clipper: _StarClipper(),
          child: SizedBox(
            width: 8,
            height: 8,
            child: ColoredBox(color: color),
          ),
        ),
        const SizedBox(width: 7),
        Eyebrow(label, size: 9, tracking: 0.20, color: CColors.ink),
      ],
    );
  }
}