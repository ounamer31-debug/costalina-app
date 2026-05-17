import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// Local queue for reports that couldn't be submitted (offline / network error).
/// Stored as a JSON list under [_key] in SharedPreferences. We flush
/// opportunistically: each successful network call triggers a drain attempt,
/// and a connectivity listener flushes when the device comes back online.
class ReportQueue {
  static const _key = 'pending_reports_v1';
  static bool _flushing = false;
  static StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Wire a connectivity listener that flushes whenever the device regains a
  /// network. Call once from main().
  static void startConnectivityListener() {
    _sub?.cancel();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) =>
          r != ConnectivityResult.none && r != ConnectivityResult.bluetooth);
      if (online) flush();
    });
  }

  /// Persist a report payload locally for later submission.
  static Future<void> enqueue(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode(payload));
    await prefs.setStringList(_key, raw);
  }

  /// Returns the current number of queued reports (cheap, no network).
  static Future<int> pendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).length;
  }

  /// Attempt to send every queued report. Items that fail (e.g. still offline)
  /// stay in the queue for next time. Re-entrancy-safe via [_flushing].
  static Future<int> flush() async {
    if (_flushing) return 0;
    _flushing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? <String>[];
      if (raw.isEmpty) return 0;

      final remaining = <String>[];
      var sent = 0;
      for (final item in raw) {
        try {
          final payload = jsonDecode(item) as Map<String, dynamic>;
          await ApiService.createReport(payload);
          sent++;
        } catch (_) {
          remaining.add(item); // keep for next attempt
        }
      }
      await prefs.setStringList(_key, remaining);
      return sent;
    } finally {
      _flushing = false;
    }
  }
}