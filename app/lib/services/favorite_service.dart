import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

/// Favorit disimpan di database lewat API (/api/favorites),
/// jadi setiap akun punya daftar favoritnya sendiri.
/// Format kunci di aplikasi: `kos:id` atau `kontrakan:id`.
class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  static const Duration _timeout = Duration(seconds: 20);
  Set<String> _keys = {};

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService.instance.token}',
  };

  bool isFavorite(String type, String id) => _keys.contains('$type:$id');

  // GET /api/favorites
  Future<void> load() async {
    if (!AuthService.instance.isLoggedIn) {
      clear();
      return;
    }
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/favorites'), headers: _headers)
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _keys = data
            .map((item) => '${item['item_type']}:${item['item_id']}')
            .toSet();
        notifyListeners();
      }
    } catch (_) {
      // Gagal (misalnya tidak ada internet): biarkan daftar yang ada
    }
  }

  /// Dipanggil saat logout.
  void clear() {
    _keys = {};
    notifyListeners();
  }

  // POST /api/favorites  atau  DELETE /api/favorites/:type/:id
  Future<void> toggle(String type, String id) async {
    final key = '$type:$id';
    final wasFavorite = _keys.contains(key);

    // Ubah tampilan dulu agar terasa cepat
    wasFavorite ? _keys.remove(key) : _keys.add(key);
    notifyListeners();

    try {
      final http.Response response;
      if (wasFavorite) {
        response = await http
            .delete(
              Uri.parse('${ApiConfig.baseUrl}/favorites/$type/$id'),
              headers: _headers,
            )
            .timeout(_timeout);
      } else {
        response = await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/favorites'),
              headers: _headers,
              body: jsonEncode({'item_type': type, 'item_id': id}),
            )
            .timeout(_timeout);
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gagal menyimpan favorit');
      }
    } catch (_) {
      // Gagal ke server: kembalikan seperti semula
      wasFavorite ? _keys.add(key) : _keys.remove(key);
      notifyListeners();
    }
  }
}