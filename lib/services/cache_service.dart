import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _keyBeaches = 'cache_beaches';
  static const _keyAlerts  = 'cache_alerts';

  static Future<void> saveBeaches(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBeaches, json);
  }

  static Future<String?> loadBeaches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBeaches);
  }

  static Future<void> saveAlerts(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAlerts, json);
  }

  static Future<String?> loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAlerts);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBeaches);
    await prefs.remove(_keyAlerts);
  }
}