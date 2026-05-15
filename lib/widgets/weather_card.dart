import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/app_strings.dart';
import '../main.dart' show localeNotifier;
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import 'eyebrow.dart';
import 'hair_line.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  WeatherData? _data;
  bool _loading = true;
  bool _gpsUsed = false;

  @override
  void initState() {
    super.initState();
    localeNotifier.addListener(_onLocale);
    _loadWithLocation();
  }

  void _onLocale() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocale);
    super.dispose();
  }

  Future<void> _loadWithLocation() async {
    if (!mounted) return;
    setState(() => _loading = true);

    double lat = WeatherService.fallbackLat;
    double lng = WeatherService.fallbackLng;
    String city = '';
    bool gpsOk = false;

    final result = await LocationService.instance.getCurrent();
    if (result.status == LocationStatus.ok && result.position != null) {
      lat = result.position!.latitude;
      lng = result.position!.longitude;
      gpsOk = true;
      city = await WeatherService.reverseGeocode(lat, lng);
    }

    if (city.isEmpty) city = AppStrings.current.weatherMonastir;

    final data = await WeatherService.fetch(lat: lat, lng: lng, cityName: city);
    if (!mounted) return;
    setState(() { _data = data; _loading = false; _gpsUsed = gpsOk; });
  }

  void _openDetail() {
    if (_data == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeatherDetailSheet(data: _data!, gpsUsed: _gpsUsed, onRefresh: _loadWithLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.current;
    final lang = localeNotifier.value.languageCode;

    if (_loading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(22, 28, 22, 0),
        height: 80,
        decoration: BoxDecoration(
          color: CColors.white,
          border: Border.all(color: CColors.tealLine, width: 1),
        ),
        child: const Center(
          child: SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: CColors.tealDark)),
        ),
      );
    }

    if (_data == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _openDetail,
      child: Container(
        margin: const EdgeInsets.fromLTRB(22, 28, 22, 0),
        decoration: BoxDecoration(
          color: CColors.white,
          border: Border.all(color: CColors.tealLine, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current conditions row
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Text(WeatherService.emoji(_data!.currentCode),
                      style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _gpsUsed ? LucideIcons.locateFixed : LucideIcons.mapPin,
                              size: 11, color: CColors.tealDark,
                            ),
                            const SizedBox(width: 5),
                            Eyebrow(_data!.cityName, size: 9, tracking: 0.26, color: CColors.tealDark),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_data!.currentTemp.round()}°C  ·  ${WeatherService.label(_data!.currentCode, lang)}',
                          style: CType.serifDisplay(size: 17),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, size: 14, color: CColors.grey),
                ],
              ),
            ),
            const HairLine(color: CColors.tealLineSoft),
            // Mini metrics strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  _MetricChip(icon: LucideIcons.droplets, value: '${_data!.humidity}%',  label: s.weatherHumidity),
                  const SizedBox(width: 16),
                  _MetricChip(icon: LucideIcons.wind,     value: '${_data!.windSpeed.round()} km/h', label: s.weatherWind),
                  const SizedBox(width: 16),
                  _MetricChip(icon: LucideIcons.sun,      value: _data!.uvIndex.toStringAsFixed(1), label: s.weatherUV),
                ],
              ),
            ),
            const HairLine(color: CColors.tealLineSoft),
            // 6-day forecast strip
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  for (var i = 0; i < _data!.days.length; i++) ...[
                    _DayCell(day: _data!.days[i], lang: lang, isToday: i == 0, s: s),
                    if (i < _data!.days.length - 1) const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Metric chip ───────────────────────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MetricChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: CColors.tealDark),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: CType.serifDisplay(size: 12)),
            Text(label, style: CType.eyebrow(size: 8, tracking: 0.16, color: CColors.grey)),
          ],
        ),
      ],
    );
  }
}

// ── Day cell ──────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final WeatherDay day;
  final String lang;
  final bool isToday;
  final AppStrings s;
  const _DayCell({required this.day, required this.lang, required this.isToday, required this.s});

  @override
  Widget build(BuildContext context) {
    final label = isToday ? s.weatherToday : s.weekdayShort(day.date.weekday);
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: isToday ? CColors.tealBg : Colors.transparent,
        border: isToday ? Border.all(color: CColors.tealLine, width: 1) : null,
      ),
      child: Column(
        children: [
          Eyebrow(label, size: 8, tracking: 0.2,
              color: isToday ? CColors.tealDark : CColors.inkSoft),
          const SizedBox(height: 6),
          Text(WeatherService.emoji(day.code), style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 6),
          Text('${day.tempMax.round()}°', style: CType.serifDisplay(size: 13)),
          const SizedBox(height: 2),
          Text('${day.tempMin.round()}°', style: CType.body(size: 11, color: CColors.inkSoft)),
        ],
      ),
    );
  }
}

// ── Full weather detail sheet ─────────────────────────────────────────────────

class _WeatherDetailSheet extends StatefulWidget {
  final WeatherData data;
  final bool gpsUsed;
  final VoidCallback onRefresh;
  const _WeatherDetailSheet({required this.data, required this.gpsUsed, required this.onRefresh});

  @override
  State<_WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class _WeatherDetailSheetState extends State<_WeatherDetailSheet> {
  late WeatherData _d;
  late bool _gpsUsed;
  bool _loadingCity = false;
  final _searchCtrl = TextEditingController();
  List<({String name, double lat, double lng})> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _d = widget.data;
    _gpsUsed = widget.gpsUsed;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String q) async {
    if (q.trim().length < 2) { setState(() => _suggestions = []); return; }
    final results = await WeatherService.searchCity(q);
    if (!mounted) return;
    setState(() => _suggestions = results);
  }

  Future<void> _selectCity(({String name, double lat, double lng}) city) async {
    setState(() { _loadingCity = true; _suggestions = []; });
    _searchCtrl.clear();
    FocusScope.of(context).unfocus();
    final data = await WeatherService.fetch(lat: city.lat, lng: city.lng, cityName: city.name);
    if (!mounted) return;
    setState(() { if (data != null) { _d = data; _gpsUsed = false; } _loadingCity = false; });
  }

  @override
  Widget build(BuildContext context) {
    final s    = AppStrings.current;
    final lang = localeNotifier.value.languageCode;
    final now  = DateTime.now();

    // Hours from current time onwards (next 12h)
    final futureHours = _d.hours
        .where((h) => h.time.isAfter(now.subtract(const Duration(minutes: 30))))
        .take(12)
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: CColors.sand,
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.only(bottom: 48),
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36, height: 3,
                decoration: BoxDecoration(
                  color: CColors.tealLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header: city + close
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: Row(
                children: [
                  Icon(
                    _gpsUsed ? LucideIcons.locateFixed : LucideIcons.mapPin,
                    size: 14, color: CColors.tealDark,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Eyebrow(_d.cityName, size: 10, tracking: 0.28, color: CColors.tealDark),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x, size: 18, color: CColors.grey),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: CColors.white,
                  border: Border.all(color: CColors.tealLine, width: 1),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(LucideIcons.search, size: 14, color: CColors.grey),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        style: CType.body(size: 13, color: CColors.ink),
                        decoration: InputDecoration(
                          hintText: s.weatherSearch,
                          hintStyle: CType.body(size: 13, color: CColors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_loadingCity)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: CColors.tealDark)),
                      )
                    else if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () { _searchCtrl.clear(); setState(() => _suggestions = []); },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(LucideIcons.x, size: 14, color: CColors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Suggestions
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                decoration: BoxDecoration(
                  color: CColors.white,
                  border: Border(
                    left: BorderSide(color: CColors.tealLine, width: 1),
                    right: BorderSide(color: CColors.tealLine, width: 1),
                    bottom: BorderSide(color: CColors.tealLine, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _suggestions.length; i++) ...[
                      if (i > 0) const HairLine(color: CColors.tealLineSoft),
                      GestureDetector(
                        onTap: () => _selectCity(_suggestions[i]),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.mapPin, size: 12, color: CColors.tealDark),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_suggestions[i].name,
                                  style: CType.body(size: 13, color: CColors.ink))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            // Big temp + condition
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(WeatherService.emoji(_d.currentCode),
                      style: const TextStyle(fontSize: 54)),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_d.currentTemp.round()}°C',
                          style: CType.serifDisplay(size: 48)),
                      Text(WeatherService.label(_d.currentCode, lang),
                          style: CType.body(size: 14, color: CColors.inkSoft)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onRefresh();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.refresh, size: 18, color: CColors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Metrics row
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: CColors.white,
                  border: Border.all(color: CColors.tealLine, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(child: _DetailMetric(
                        icon: LucideIcons.droplets,
                        value: '${_d.humidity}%',
                        label: s.weatherHumidity)),
                    const HairLine(vertical: true, extent: 60, color: CColors.tealLineSoft),
                    Expanded(child: _DetailMetric(
                        icon: LucideIcons.wind,
                        value: '${_d.windSpeed.round()} km/h',
                        label: s.weatherWind)),
                    const HairLine(vertical: true, extent: 60, color: CColors.tealLineSoft),
                    Expanded(child: _DetailMetric(
                        icon: LucideIcons.sun,
                        value: _d.uvIndex.toStringAsFixed(1),
                        label: s.weatherUV)),
                  ],
                ),
              ),
            ),
            // Hourly section
            if (futureHours.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
                child: Eyebrow(s.weatherHourly, size: 9, tracking: 0.26, color: CColors.inkSoft),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: CColors.white,
                  border: Border.all(color: CColors.tealLine, width: 1),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    children: futureHours.map((h) {
                      final isNow = (h.time.hour == now.hour);
                      return Container(
                        width: 54,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isNow ? CColors.tealBg : Colors.transparent,
                          border: isNow ? Border.all(color: CColors.tealLine, width: 1) : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${h.time.hour.toString().padLeft(2, '0')}h',
                              style: CType.eyebrow(size: 8, tracking: 0.16,
                                  color: isNow ? CColors.tealDark : CColors.inkSoft),
                            ),
                            const SizedBox(height: 6),
                            Text(WeatherService.emoji(h.code),
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('${h.temp.round()}°',
                                style: CType.serifDisplay(size: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            // Daily section
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
              child: Eyebrow(s.weatherForecast, size: 9, tracking: 0.26, color: CColors.inkSoft),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: CColors.white,
                border: Border.all(color: CColors.tealLine, width: 1),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _d.days.length; i++) ...[
                    if (i > 0) const HairLine(color: CColors.tealLineSoft),
                    _DayRow(
                      day: _d.days[i],
                      lang: lang,
                      isToday: i == 0,
                      label: i == 0 ? s.weatherToday : s.weekdayShort(_d.days[i].date.weekday),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _DetailMetric({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: CColors.tealDark),
          const SizedBox(height: 6),
          Text(value, style: CType.serifDisplay(size: 15)),
          const SizedBox(height: 3),
          Text(label, style: CType.eyebrow(size: 8, tracking: 0.16, color: CColors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final WeatherDay day;
  final String lang;
  final bool isToday;
  final String label;
  const _DayRow({required this.day, required this.lang, required this.isToday, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Eyebrow(label, size: 9, tracking: 0.2,
                color: isToday ? CColors.tealDark : CColors.inkSoft),
          ),
          Text(WeatherService.emoji(day.code), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(WeatherService.label(day.code, lang),
                style: CType.body(size: 13, color: CColors.inkSoft)),
          ),
          Text('${day.tempMin.round()}°',
              style: CType.body(size: 13, color: CColors.inkSoft)),
          const SizedBox(width: 8),
          Text('${day.tempMax.round()}°',
              style: CType.serifDisplay(size: 14)),
        ],
      ),
    );
  }
}