import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user.dart';
import 'favorite_service.dart';

/// Mengurus login, daftar, dan logout lewat API (/api/auth).
/// Token dan data user disimpan di HP agar tetap login walau aplikasi ditutup.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const Duration _timeout = Duration(seconds: 20);

  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;
  bool get isLoggedIn => _token != null && _user != null;

  /// Membaca sesi login yang tersimpan (dipanggil di main.dart).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    _user = userJson == null ? null : User.fromJson(jsonDecode(userJson));
    notifyListeners();
  }

  // POST /api/auth/login
  Future<void> login(String email, String password) async {
    final data = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _saveSession(data);
  }

  // POST /api/auth/register
  Future<void> register(String name, String email, String password) async {
    final data = await _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    await _saveSession(data);
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    FavoriteService.instance.clear(); // favorit milik akun ini dikosongkan
    notifyListeners();
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body,
  ) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Server error (kode ${response.statusCode})');
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    // Pesan error dari API, misalnya "Email atau password salah"
    throw Exception(
      data['error'] ?? 'Terjadi kesalahan (${response.statusCode})',
    );
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    _token = data['token'] as String;
    _user = User.fromJson(data['user'] as Map<String, dynamic>);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
    notifyListeners();
    // Ambil favorit milik akun yang baru login dari API
    await FavoriteService.instance.load();
  }
}
