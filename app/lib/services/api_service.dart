import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/area.dart';
import '../models/kos.dart';
import '../models/kontrakan.dart';
import 'auth_service.dart';

/// Semua komunikasi ke API (Express + Supabase) ada di sini.
class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  static Future<dynamic> _get(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal memuat data (kode ${response.statusCode})');
  }

  // GET /api/areas
  static Future<List<Area>> getAreas() async {
    final List data = await _get('/areas');
    return data.map((json) => Area.fromJson(json)).toList();
  }

  // GET /api/kos?sort=termurah|termahal|terdekat
  static Future<List<Kos>> getKos({String sort = 'termurah'}) async {
    final List data = await _get('/kos?sort=$sort');
    return data.map((json) => Kos.fromJson(json)).toList();
  }

  // GET /api/kos/:id
  static Future<Kos> getKosById(String id) async {
    final data = await _get('/kos/$id');
    return Kos.fromJson(data);
  }

  // GET /api/kontrakan?sort=termurah|termahal|terdekat
  static Future<List<Kontrakan>> getKontrakan({
    String sort = 'termurah',
  }) async {
    final List data = await _get('/kontrakan?sort=$sort');
    return data.map((json) => Kontrakan.fromJson(json)).toList();
  }

  // GET /api/kontrakan/:id
  static Future<Kontrakan> getKontrakanById(String id) async {
    final data = await _get('/kontrakan/$id');
    return Kontrakan.fromJson(data);
  }

  // ===================== CRUD (wajib login) =====================

  // Kirim POST / PUT / DELETE dengan token login
  static Future<dynamic> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AuthService.instance.token}',
    };
    final encoded = body == null ? null : jsonEncode(body);

    final http.Response response;
    if (method == 'POST') {
      response = await http
          .post(uri, headers: headers, body: encoded)
          .timeout(_timeout);
    } else if (method == 'PUT') {
      response = await http
          .put(uri, headers: headers, body: encoded)
          .timeout(_timeout);
    } else {
      response = await http.delete(uri, headers: headers).timeout(_timeout);
    }

    final data = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    final message = data is Map ? data['error'] : null;
    throw Exception(message ?? 'Gagal menyimpan (kode ${response.statusCode})');
  }

  // POST /api/kos
  static Future<void> createKos(Map<String, dynamic> data) =>
      _send('POST', '/kos', data);

  // PUT /api/kos/:id
  static Future<void> updateKos(String id, Map<String, dynamic> data) =>
      _send('PUT', '/kos/$id', data);

  // DELETE /api/kos/:id
  static Future<void> deleteKos(String id) => _send('DELETE', '/kos/$id');

  // POST /api/kontrakan
  static Future<void> createKontrakan(Map<String, dynamic> data) =>
      _send('POST', '/kontrakan', data);

  // PUT /api/kontrakan/:id
  static Future<void> updateKontrakan(String id, Map<String, dynamic> data) =>
      _send('PUT', '/kontrakan/$id', data);

  // DELETE /api/kontrakan/:id
  static Future<void> deleteKontrakan(String id) =>
      _send('DELETE', '/kontrakan/$id');
}
