import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'barom_api.dart';

/// Fetches the dynamic keyword map for a locale and caches it locally so the
/// app still renders offline / on cold start using the last known values.
class TranslationRepository {
  TranslationRepository({BaromApi? api}) : _api = api ?? BaromApi();

  final BaromApi _api;

  static String _cacheKey(String locale) => 'translations_$locale';

  /// Returns the cached map immediately (may be empty on first run).
  Future<Map<String, String>> cached(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(locale));
    if (raw == null || raw.isEmpty) return const {};
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return const {};
    }
  }

  /// Fetches the authoritative map from the API, updates the cache, and
  /// returns the result. Falls back to the cache on any network/API error.
  Future<Map<String, String>> fetch(String locale) async {
    final cache = await cached(locale);

    try {
      final response = await _api.dio.get<Map<String, dynamic>>(
        '/translation-export/$locale',
      );
      final data = response.data?['data'];
      if (data is Map) {
        final map = Map<String, String>.from(data);
        await _save(locale, map);
        return map;
      }
    } catch (_) {
      // Offline or backend unreachable — keep using the cached copy.
    }

    return cache;
  }

  Future<void> _save(String locale, Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(locale), jsonEncode(map));
  }
}