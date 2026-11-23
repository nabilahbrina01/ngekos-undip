import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/area.dart';
import '../models/kos.dart';
import '../models/kontrakan.dart';

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
}
