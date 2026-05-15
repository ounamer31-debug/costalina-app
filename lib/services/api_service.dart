import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/beach.dart';
import '../models/alerte.dart';
import '../models/signalement.dart';
import '../models/user.dart';
import 'auth_service.dart';

class ApiService {
  static const _base = 'http://localhost:3000/api';

  // ── Beaches ───────────────────────────────────────────────────────────────

  static Future<List<Beach>> getBeaches() async {
    final res = await http
        .get(Uri.parse('$_base/beaches'))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) throw Exception('Failed to load beaches');
    final list = jsonDecode(res.body) as List;
    return list.map((j) => _beachFromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<Beach> getBeach(String id) async {
    final res = await http
        .get(Uri.parse('$_base/beaches/$id'))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) throw Exception('Beach not found');
    return _beachFromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Alerts ────────────────────────────────────────────────────────────────

  static Future<List<Alerte>> getAlerts() async {
    final res = await http
        .get(Uri.parse('$_base/alerts'))
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) throw Exception('Failed to load alerts');
    final list = jsonDecode(res.body) as List;
    return list.map((j) => _alertFromJson(j as Map<String, dynamic>)).toList();
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  static Future<List<AppUser>> getUsers() async {
    final token = await AuthService.getToken();
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};
    final res = await http.get(
      Uri.parse('$_base/users'),
      headers: headers,
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) throw Exception('Failed to load users');
    final list = jsonDecode(res.body) as List;
    return list.map((j) => AppUser.fromJson(j as Map<String, dynamic>)).toList();
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  static Future<List<Signalement>> getReports({String? beachId}) async {
    final uri = beachId != null
        ? Uri.parse('$_base/reports?beachId=$beachId')
        : Uri.parse('$_base/reports');
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) throw Exception('Failed to load reports');
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Signalement.fromJson(j as Map<String, dynamic>)).toList();
  }

  static Future<void> createReport(Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    await http.post(
      Uri.parse('$_base/reports'),
      headers: headers,
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 8));
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  static Beach _beachFromJson(Map<String, dynamic> j) => Beach(
    id:            j['id']            as String,
    name:          j['name']          as String,
    city:          j['city']          as String,
    photoUrl:      j['photoUrl']      as String? ?? '',
    risk:          _parseRisk(j['risk'] as String? ?? 'stable'),
    lastUpdate:    j['lastUpdate']    as String? ?? '',
    erosionMeters: (j['erosionMeters'] as num?)?.toDouble() ?? 0,
    lat:           (j['lat']          as num).toDouble(),
    lng:           (j['lng']          as num).toDouble(),
  );

  static Alerte _alertFromJson(Map<String, dynamic> j) => Alerte(
    beachId:   j['beachId']   as String,
    beachName: j['beachName'] as String,
    message:   j['message']   as String,
    time:      _timeAgo(j['createdAt'] as String?),
    risk:      _parseRisk(j['risk'] as String? ?? 'stable'),
  );

  static BeachRisk _parseRisk(String s) {
    switch (s) {
      case 'eleve':  return BeachRisk.eleve;
      case 'modere': return BeachRisk.modere;
      default:       return BeachRisk.stable;
    }
  }

  static String _timeAgo(String? iso) {
    if (iso == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inMinutes < 60)  return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours   < 24)  return 'Il y a ${diff.inHours} h';
    if (diff.inDays    == 1)  return 'Hier';
    return 'Il y a ${diff.inDays} j';
  }
}