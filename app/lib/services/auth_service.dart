import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user.dart';
import 'favorite_service.dart';

/// Error dari API auth. [needsVerification] = akun belum verifikasi OTP.
class AuthException implements Exception {
  final String message;
  final bool needsVerification;

  AuthException(this.message, {this.needsVerification = false});

  @override
  String toString() => message;
}

/// Mengurus login, daftar, OTP, lupa password, dan logout lewat API (/api/auth).
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
    if (_token != null)
      _refreshUser(); // tidak ditunggu agar aplikasi cepat terbuka
  }

  // GET /api/auth/me -> perbarui data user (misalnya role) dari server
  Future<void> _refreshUser() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/auth/me'),
            headers: {'Authorization': 'Bearer $_token'},
          )
          .timeout(_timeout);
      if (response.statusCode != 200) return;
      _user = User.fromJson(jsonDecode(response.body));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (_) {
      // Tidak ada internet: pakai data yang tersimpan
    }
  }

  // POST /api/auth/login
  Future<void> login(String email, String password) async {
    final data = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _saveSession(data);
  }

  // POST /api/auth/register -> akun dibuat, kode OTP dikirim ke email
  // role: "pencari" atau "pemilik"
  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    await _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  // POST /api/auth/verify-otp -> kode benar = langsung login
  Future<void> verifyOtp(String email, String code) async {
    final data = await _post('/auth/verify-otp', {
      'email': email,
      'code': code,
    });
    await _saveSession(data);
  }

  // POST /api/auth/resend-otp  (purpose: "register" atau "reset")
  Future<void> resendOtp(String email, String purpose) async {
    await _post('/auth/resend-otp', {'email': email, 'purpose': purpose});
  }

  // POST /api/auth/forgot-password -> kode OTP reset dikirim ke email
  Future<void> forgotPassword(String email) async {
    await _post('/auth/forgot-password', {'email': email});
  }

  // POST /api/auth/reset-password
  Future<void> resetPassword(String email, String code, String password) async {
    await _post('/auth/reset-password', {
      'email': email,
      'code': code,
      'password': password,
    });
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
      throw AuthException('Server error (kode ${response.statusCode})');
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    // Pesan error dari API, misalnya "Email atau password salah"
    throw AuthException(
      data['error'] ?? 'Terjadi kesalahan (${response.statusCode})',
      needsVerification: data['needsVerification'] == true,
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
