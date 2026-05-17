import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const _apiRoot = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:3000/api',
);
const _base = '$_apiRoot/auth';
const _storage = FlutterSecureStorage();

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int points;
  final String role;
  const AuthUser({
    this.id = '',
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.points = 0,
    this.role = 'user',
  });

  AuthUser copyWith({String? id, String? name, String? email, String? avatarUrl, int? points, String? role}) =>
      AuthUser(
        id:        id        ?? this.id,
        name:      name      ?? this.name,
        email:     email     ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        points:    points    ?? this.points,
        role:      role      ?? this.role,
      );

  static AuthUser fromJson(Map<String, dynamic> j) => AuthUser(
        id:        (j['_id'] ?? j['id'] ?? '').toString(),
        name:      j['name']      as String? ?? '',
        email:     j['email']     as String? ?? '',
        avatarUrl: j['avatarUrl'] as String? ?? '',
        points:    (j['points']   as num?)?.toInt() ?? 0,
        role:      j['role']      as String? ?? 'user',
      );
}

class AuthService {
  static AuthUser? _current;
  static AuthUser? get currentUser => _current;

  // ── Restore session on app start ─────────────────────────────────────────

  static Future<bool> restoreSession() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return false;
    try {
      final res = await http.get(
        Uri.parse('$_base/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        _current = AuthUser.fromJson(j);
        return true;
      }
    } catch (_) {}
    await _storage.delete(key: 'jwt');
    return false;
  }

  // ── Refresh /me (used after points change) ───────────────────────────────

  static Future<bool> refreshMe() async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return false;
    try {
      final res = await http.get(
        Uri.parse('$_base/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        _current = AuthUser.fromJson(j);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Register ─────────────────────────────────────────────────────────────

  static Future<AuthResult> register(String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));
      return _handle(res);
    } catch (_) {
      return AuthResult.networkError;
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  static Future<AuthResult> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));
      return _handle(res);
    } catch (_) {
      return AuthResult.networkError;
    }
  }

  // ── Update profile ────────────────────────────────────────────────────────

  static Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) return false;
    try {
      final body = <String, dynamic>{};
      if (name != null)      body['name']      = name;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final res = await http.put(
        Uri.parse('$_base/me'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        _current = AuthUser.fromJson(j);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── Forgot password — request OTP ────────────────────────────────────────

  static Future<ForgotResult> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return ForgotResult.ok;
      return ForgotResult.unknown;
    } catch (_) {
      return ForgotResult.networkError;
    }
  }

  // ── Reset password — verify OTP + new password ────────────────────────────

  static Future<ResetResult> resetPassword(String email, String otp, String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPassword}),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return ResetResult.ok;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final error = body['error'] as String? ?? '';
      if (error == 'invalid_otp')   return ResetResult.invalidOtp;
      if (error == 'otp_expired')   return ResetResult.otpExpired;
      if (error == 'weak_password') return ResetResult.weakPassword;
      return ResetResult.unknown;
    } catch (_) {
      return ResetResult.networkError;
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    _current = null;
    await _storage.delete(key: 'jwt');
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  static Future<String?> getToken() => _storage.read(key: 'jwt');

  // ── Internal ──────────────────────────────────────────────────────────────

  static Future<AuthResult> _handle(http.Response res) async {
    if (res.statusCode == 200 || res.statusCode == 201) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      await _storage.write(key: 'jwt', value: j['token'] as String);
      _current = AuthUser.fromJson(j);
      // Pull the canonical /me so we have the user id (login/register responses don't include _id)
      await refreshMe();
      return AuthResult.ok;
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final error = body['error'] as String? ?? '';
    if (error == 'email_in_use')        return AuthResult.emailInUse;
    if (error == 'invalid_credential')  return AuthResult.invalidCredential;
    if (res.statusCode == 400)          return AuthResult.weakPassword;
    return AuthResult.unknown;
  }
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum AuthResult { ok, invalidCredential, emailInUse, weakPassword, networkError, unknown }

extension AuthResultX on AuthResult {
  bool get success => this == AuthResult.ok;

  String message(String lang) {
    final fr = lang == 'fr';
    switch (this) {
      case AuthResult.ok:                return '';
      case AuthResult.invalidCredential: return fr ? 'Email ou mot de passe incorrect' : 'Incorrect email or password';
      case AuthResult.emailInUse:        return fr ? 'Adresse email déjà utilisée' : 'Email already in use';
      case AuthResult.weakPassword:      return fr ? 'Mot de passe trop faible (8 caractères, lettres et chiffres)' : 'Password too weak (8 chars, letters and digits)';
      case AuthResult.networkError:      return fr ? 'Impossible de joindre le serveur' : 'Cannot reach server';
      case AuthResult.unknown:           return fr ? 'Une erreur est survenue' : 'An error occurred';
    }
  }
}

enum ForgotResult { ok, networkError, unknown }
enum ResetResult  { ok, invalidOtp, otpExpired, weakPassword, networkError, unknown }

extension ResetResultX on ResetResult {
  String message(String lang) {
    final fr = lang == 'fr';
    switch (this) {
      case ResetResult.ok:           return '';
      case ResetResult.invalidOtp:   return fr ? 'Code incorrect' : 'Incorrect code';
      case ResetResult.otpExpired:   return fr ? 'Code expiré — demandez un nouveau' : 'Code expired — request a new one';
      case ResetResult.weakPassword: return fr ? 'Mot de passe trop faible (8 caractères, lettres et chiffres)' : 'Password too weak (8 chars, letters and digits)';
      case ResetResult.networkError: return fr ? 'Impossible de joindre le serveur' : 'Cannot reach server';
      case ResetResult.unknown:      return fr ? 'Une erreur est survenue' : 'An error occurred';
    }
  }
}