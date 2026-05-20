import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/beach.dart';
import '../models/alerte.dart';
import '../models/reward.dart';
import '../models/signalement.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'cache_service.dart';

class ApiService {
  static const _base = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:3000/api',
  );

  // ── Beaches ───────────────────────────────────────────────────────────────

  static Future<List<Beach>> getBeaches() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/beaches'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) throw Exception('Failed to load beaches');
      await CacheService.saveBeaches(res.body);
      final list = jsonDecode(res.body) as List;
      return list.map((j) => _beachFromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      final cached = await CacheService.loadBeaches();
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        return list.map((j) => _beachFromJson(j as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
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
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
      final res = await http
          .get(Uri.parse('$_base/alerts'), headers: headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) throw Exception('Failed to load alerts');
      await CacheService.saveAlerts(res.body);
      final list = jsonDecode(res.body) as List;
      return list.map((j) => _alertFromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      final cached = await CacheService.loadAlerts();
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        return list.map((j) => _alertFromJson(j as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/users/leaderboard?limit=20'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body) as List;
      return list.map((j) {
        final m = j as Map<String, dynamic>;
        return LeaderboardEntry(
          id:        m['_id']       as String? ?? '',
          name:      m['name']      as String? ?? 'Anonyme',
          avatarUrl: m['avatarUrl'] as String? ?? '',
          points:    (m['points']   as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

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

  static Future<List<Signalement>> getMyReports({int page = 1}) async {
    final token = await AuthService.getToken();
    if (token == null) return const [];
    final res = await http.get(
      Uri.parse('$_base/reports/me?page=$page&limit=20'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return const [];
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

  static Future<List<TimelineBucket>> getBeachTimeline(String beachId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/reports/timeline?beachId=$beachId'),
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body) as List;
      return list.map((j) {
        final m = j as Map<String, dynamic>;
        return TimelineBucket(
          month:     m['month']     as String,
          total:     (m['total']     as num?)?.toInt() ?? 0,
          erosion:   (m['erosion']   as num?)?.toInt() ?? 0,
          pollution: (m['pollution'] as num?)?.toInt() ?? 0,
          other:     (m['other']     as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Rewards ───────────────────────────────────────────────────────────────

  static Future<List<Reward>> getRewards() async {
    try {
      final res = await http.get(Uri.parse('$_base/rewards'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body) as List;
      return list.map((j) => Reward.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<RedeemResult> redeemReward(String rewardId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return const RedeemResult(error: 'not_authenticated');
      final res = await http.post(
        Uri.parse('$_base/rewards/$rewardId/redeem'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) {
        return RedeemResult(
          redemption:      Redemption.fromJson(body['redemption'] as Map<String, dynamic>),
          remainingPoints: (body['remainingPoints'] as num?)?.toInt() ?? 0,
        );
      }
      return RedeemResult(error: body['error'] as String? ?? 'unknown');
    } catch (e) {
      return RedeemResult(error: e.toString());
    }
  }

  static Future<List<Redemption>> getMyRedemptions() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return const [];
      final res = await http.get(
        Uri.parse('$_base/rewards/redemptions/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body) as List;
      return list.map((j) => Redemption.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  // ── Followed beaches ──────────────────────────────────────────────────────

  static Future<Set<String>> getFollowedBeaches() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return <String>{};
      final res = await http.get(
        Uri.parse('$_base/users/me/follows'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return <String>{};
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return (j['followedBeaches'] as List? ?? const []).cast<String>().toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<bool> followBeach(String beachId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$_base/users/me/follows/$beachId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> unfollowBeach(String beachId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    try {
      final res = await http.delete(
        Uri.parse('$_base/users/me/follows/$beachId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Alert read state ──────────────────────────────────────────────────────

  static Future<void> markAlertRead(String alertId) async {
    final token = await AuthService.getToken();
    if (token == null) return;
    try {
      await http.patch(
        Uri.parse('$_base/alerts/$alertId/read'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  static Future<void> markAllAlertsRead() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    try {
      await http.post(
        Uri.parse('$_base/alerts/read-all'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 6));
    } catch (_) {}
  }

  static Future<UserStats> getMyStats() async {
    final token = await AuthService.getToken();
    if (token == null) return const UserStats();
    final res = await http.get(
      Uri.parse('$_base/reports/stats/me'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return const UserStats();
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return UserStats(
      total:    (j['total']    as num?)?.toInt() ?? 0,
      pending:  (j['pending']  as num?)?.toInt() ?? 0,
      verified: (j['verified'] as num?)?.toInt() ?? 0,
      resolved: (j['resolved'] as num?)?.toInt() ?? 0,
    );
  }

  // ── AI ────────────────────────────────────────────────────────────────────

  static Future<AiPhotoSuggestion?> analyzePhoto(String photoUrl) async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    try {
      final res = await http.post(
        Uri.parse('$_base/ai/analyze-photo'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'photoUrl': photoUrl}),
      ).timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return AiPhotoSuggestion(
        type:         j['type']         as String? ?? 'other',
        severity:     (j['severity']    as num?)?.toInt() ?? 3,
        description:  j['description']  as String? ?? '',
        confidence:   j['confidence']   as String? ?? 'medium',
        usable:       j['usable']       as bool?   ?? true,
        qualityIssue: j['qualityIssue'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String?> aiChat(List<Map<String, String>> messages, {String lang = 'fr'}) async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    try {
      final res = await http.post(
        Uri.parse('$_base/ai/chat'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'messages': messages, 'lang': lang}),
      ).timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return j['reply'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> improveMessage(String text, {String lang = 'fr'}) async {
    final token = await AuthService.getToken();
    if (token == null) return null;
    try {
      final res = await http.post(
        Uri.parse('$_base/ai/improve-message'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'text': text, 'lang': lang}),
      ).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return j['text'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<AiDigest?> getWeeklyDigest() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/ai/weekly-digest'),
      ).timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return AiDigest(
        text:  j['text'] as String? ?? '',
        total: ((j['stats'] as Map?)?['total'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<AiForecast?> getBeachForecast(String beachId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/ai/forecast/$beachId'),
      ).timeout(const Duration(seconds: 25));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return AiForecast(
        risk:       j['risk']       as String? ?? 'stable',
        confidence: j['confidence'] as String? ?? 'low',
        summary:    j['summary']    as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  static Beach _beachFromJson(Map<String, dynamic> j) => Beach(
    id:            j['id']            as String,
    name:          j['name']          as String,
    city:          j['city']          as String,
    photoUrl:      j['photoUrl']      as String? ?? '',
    photos:        (j['photos'] as List?)?.cast<String>() ?? const [],
    risk:          _parseRisk(j['risk'] as String? ?? 'stable'),
    lastUpdate:    j['lastUpdate']    as String? ?? '',
    erosionMeters: (j['erosionMeters'] as num?)?.toDouble() ?? 0,
    lat:           (j['lat']          as num).toDouble(),
    lng:           (j['lng']          as num).toDouble(),
  );

  static Alerte _alertFromJson(Map<String, dynamic> j) => Alerte(
    id:        (j['_id'] ?? j['id'] ?? '').toString(),
    beachId:   j['beachId']   as String,
    beachName: j['beachName'] as String,
    message:   j['message']   as String,
    time:      _timeAgo(j['createdAt'] as String?),
    risk:      _parseRisk(j['risk'] as String? ?? 'stable'),
    read:      j['read']      as bool? ?? false,
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

class RedeemResult {
  final Redemption? redemption;
  final int remainingPoints;
  final String? error;
  bool get success => redemption != null;
  const RedeemResult({this.redemption, this.remainingPoints = 0, this.error});
}

class TimelineBucket {
  final String month; // YYYY-MM
  final int total;
  final int erosion;
  final int pollution;
  final int other;
  const TimelineBucket({
    required this.month,
    required this.total,
    required this.erosion,
    required this.pollution,
    required this.other,
  });
}

class UserStats {
  final int total;
  final int pending;
  final int verified;
  final int resolved;
  const UserStats({this.total = 0, this.pending = 0, this.verified = 0, this.resolved = 0});
}

class LeaderboardEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final int points;
  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.points,
  });
}

class AiPhotoSuggestion {
  final String type;
  final int severity;
  final String description;
  final String confidence;
  final bool usable;
  final String qualityIssue;
  const AiPhotoSuggestion({
    required this.type,
    required this.severity,
    required this.description,
    required this.confidence,
    this.usable = true,
    this.qualityIssue = '',
  });
}

class AiDigest {
  final String text;
  final int total;
  const AiDigest({required this.text, required this.total});
}

class AiForecast {
  final String risk;       // 'stable' | 'modere' | 'eleve'
  final String confidence; // 'low' | 'medium' | 'high'
  final String summary;
  const AiForecast({
    required this.risk,
    required this.confidence,
    required this.summary,
  });
}