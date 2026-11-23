import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan daftar favorit di HP (shared_preferences).
/// Format kunci: "kos:<id>" atau "kontrakan:<id>".
class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  static const String _storageKey = 'favorites';
  Set<String> _keys = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _keys = (prefs.getStringList(_storageKey) ?? []).toSet();
    notifyListeners();
  }

  bool isFavorite(String type, String id) => _keys.contains('$type:$id');

  Future<void> toggle(String type, String id) async {
    final key = '$type:$id';
    if (_keys.contains(key)) {
      _keys.remove(key);
    } else {
      _keys.add(key);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _keys.toList());
  }
}