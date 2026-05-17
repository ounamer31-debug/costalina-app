import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherHour {
  final DateTime time;
  final double temp;
  final int code;
  const WeatherHour({required this.time, required this.temp, required this.code});
}

class WeatherDay {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int code;
  const WeatherDay({required this.date, required this.tempMax, required this.tempMin, required this.code});
}

class MarineData {
  final double? waveHeight;   // meters
  final double? wavePeriod;   // seconds
  final double? waveDir;      // degrees
  final double? seaSurfTemp;  // °C
  const MarineData({this.waveHeight, this.wavePeriod, this.waveDir, this.seaSurfTemp});
}

class WeatherData {
  final double currentTemp;
  final int currentCode;
  final int humidity;
  final double windSpeed;
  final double uvIndex;
  final String cityName;
  final List<WeatherDay> days;
  final List<WeatherHour> hours; // 24 h starting midnight today

  const WeatherData({
    required this.currentTemp,
    required this.currentCode,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.cityName,
    required this.days,
    required this.hours,
  });
}

class WeatherService {
  static const fallbackLat = 35.7643; // Monastir
  static const fallbackLng = 10.8113;

  static Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'Costalina/1.0 coastwatch'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = j['address'] as Map<String, dynamic>?;
        return addr?['city'] ??
            addr?['town'] ??
            addr?['village'] ??
            addr?['municipality'] ??
            addr?['county'] ??
            '';
      }
    } catch (_) {}
    return '';
  }

  static Future<WeatherData?> fetch({
    double lat = fallbackLat,
    double lng = fallbackLng,
    String cityName = 'Monastir',
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,weathercode,relative_humidity_2m,wind_speed_10m,uv_index'
        '&daily=temperature_2m_max,temperature_2m_min,weathercode'
        '&hourly=temperature_2m,weathercode'
        '&forecast_days=6'
        '&timezone=Africa%2FTunis',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;

      final cur = j['current'] as Map<String, dynamic>;
      final currentTemp = (cur['temperature_2m'] as num).toDouble();
      final currentCode = cur['weathercode'] as int;
      final humidity    = (cur['relative_humidity_2m'] as num).round();
      final windSpeed   = (cur['wind_speed_10m'] as num).toDouble();
      final uvIndex     = (cur['uv_index'] as num).toDouble();

      final daily    = j['daily'] as Map<String, dynamic>;
      final dates    = daily['time']               as List;
      final maxes    = daily['temperature_2m_max'] as List;
      final mins     = daily['temperature_2m_min'] as List;
      final dayCodes = daily['weathercode']        as List;

      final days = List.generate(
        dates.length,
        (i) => WeatherDay(
          date:    DateTime.parse(dates[i] as String),
          tempMax: (maxes[i] as num).toDouble(),
          tempMin: (mins[i]  as num).toDouble(),
          code:    dayCodes[i] as int,
        ),
      );

      final hourly    = j['hourly'] as Map<String, dynamic>;
      final hTimes    = hourly['time']              as List;
      final hTemps    = hourly['temperature_2m']    as List;
      final hCodes    = hourly['weathercode']       as List;

      final hours = List.generate(
        hTimes.length.clamp(0, 24),
        (i) => WeatherHour(
          time: DateTime.parse(hTimes[i] as String),
          temp: (hTemps[i] as num).toDouble(),
          code: hCodes[i] as int,
        ),
      );

      return WeatherData(
        currentTemp: currentTemp,
        currentCode: currentCode,
        humidity:    humidity,
        windSpeed:   windSpeed,
        uvIndex:     uvIndex,
        cityName:    cityName,
        days:        days,
        hours:       hours,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<MarineData?> fetchMarine({
    required double lat,
    required double lng,
  }) async {
    try {
      final uri = Uri.parse(
        'https://marine-api.open-meteo.com/v1/marine'
        '?latitude=$lat&longitude=$lng'
        '&current=wave_height,wave_direction,wave_period,sea_surface_temperature'
        '&timezone=Africa%2FTunis',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final cur = j['current'] as Map<String, dynamic>?;
      if (cur == null) return null;
      return MarineData(
        waveHeight:   (cur['wave_height']    as num?)?.toDouble(),
        wavePeriod:   (cur['wave_period']    as num?)?.toDouble(),
        waveDir:      (cur['wave_direction'] as num?)?.toDouble(),
        seaSurfTemp:  (cur['sea_surface_temperature'] as num?)?.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<({String name, double lat, double lng})>> searchCity(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final uri = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search'
        '?name=${Uri.encodeQueryComponent(query)}&count=5&format=json',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return [];
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final results = j['results'] as List? ?? [];
      return results.map((r) {
        final m = r as Map<String, dynamic>;
        final country = m['country_code'] as String? ?? '';
        final admin = m['admin1'] as String? ?? '';
        final display = admin.isNotEmpty ? '${m['name']}, $admin ($country)' : '${m['name']} ($country)';
        return (name: display, lat: (m['latitude'] as num).toDouble(), lng: (m['longitude'] as num).toDouble());
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static String emoji(int code) {
    if (code == 0)  return '☀️';
    if (code <= 3)  return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 55) return '🌦️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌧️';
    return '⛈️';
  }

  static String label(int code, String lang) {
    const labels = <int, Map<String, String>>{
      0:  {'fr':'Ciel dégagé',           'en':'Clear sky',        'ar':'سماء صافية',    'es':'Despejado',          'de':'Klarer Himmel',    'it':'Cielo sereno'},
      1:  {'fr':'Peu nuageux',           'en':'Mostly clear',     'ar':'قليل الغيوم',   'es':'Poco nublado',       'de':'Leicht bewölkt',   'it':'Poco nuvoloso'},
      2:  {'fr':'Partiellement nuageux', 'en':'Partly cloudy',    'ar':'غائم جزئياً',   'es':'Parcialmente nublado','de':'Teils bewölkt',   'it':'Parzialmente nuvoloso'},
      3:  {'fr':'Nuageux',               'en':'Overcast',         'ar':'غائم',           'es':'Nublado',            'de':'Bedeckt',          'it':'Nuvoloso'},
      45: {'fr':'Brouillard',            'en':'Fog',              'ar':'ضباب',           'es':'Niebla',             'de':'Nebel',            'it':'Nebbia'},
      51: {'fr':'Bruine légère',         'en':'Light drizzle',    'ar':'رذاذ خفيف',     'es':'Llovizna ligera',    'de':'Leichter Niesel',  'it':'Pioggerella'},
      61: {'fr':'Pluie légère',          'en':'Light rain',       'ar':'مطر خفيف',      'es':'Lluvia leve',        'de':'Leichter Regen',   'it':'Pioggia leggera'},
      63: {'fr':'Pluie modérée',         'en':'Moderate rain',    'ar':'مطر معتدل',     'es':'Lluvia moderada',    'de':'Mäßiger Regen',    'it':'Pioggia moderata'},
      65: {'fr':'Pluie forte',           'en':'Heavy rain',       'ar':'مطر غزير',      'es':'Lluvia intensa',     'de':'Starker Regen',    'it':'Pioggia forte'},
      80: {'fr':'Averses',               'en':'Rain showers',     'ar':'زخات مطر',      'es':'Chubascos',          'de':'Schauer',          'it':'Rovesci'},
      95: {'fr':'Orage',                 'en':'Thunderstorm',     'ar':'عاصفة رعدية',   'es':'Tormenta',           'de':'Gewitter',         'it':'Temporale'},
    };
    final sorted = labels.keys.toList()..sort();
    int best = sorted.first;
    for (final k in sorted) { if (k <= code) best = k; }
    return labels[best]?[lang] ?? labels[best]?['fr'] ?? '';
  }
}