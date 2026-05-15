import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const _base = 'http://localhost:3000/api/auth';
const _storage = FlutterSecureStorage();

class AuthUser {
  final String name;
  final String email;
  const AuthUser({required this.name, required this.email});
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
        _current = AuthUser(name: j['name'] as String, email: j['email'] as String);
        return true;
      }
    } catch (_) {}
    await _storage.delete(key: 'jwt');
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
      _current = AuthUser(
        name:  j['name']  as String,
        email: j['email'] as String,
      );
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

enum AuthResult {
  ok,
  invalidCredential,
  emailInUse,
  weakPassword,
  networkError,
  unknown,
}

extension AuthResultX on AuthResult {
  bool get success => this == AuthResult.ok;

  String message(String lang) {
    final fr = lang == 'fr';
    switch (this) {
      case AuthResult.ok:                return '';
      case AuthResult.invalidCredential: return fr ? 'Email ou mot de passe incorrect' : 'Incorrect email or password';
      case AuthResult.emailInUse:        return fr ? 'Adresse email déjà utilisée' : 'Email already in use';
      case AuthResult.weakPassword:      return fr ? 'Mot de passe trop court (6 caractères min.)' : 'Password too short (min. 6 chars)';
      case AuthResult.networkError:      return fr ? 'Impossible de joindre le serveur' : 'Cannot reach server';
      case AuthResult.unknown:           return fr ? 'Une erreur est survenue' : 'An error occurred';
    }
  }
}