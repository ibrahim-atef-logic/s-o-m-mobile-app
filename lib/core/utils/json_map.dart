import 'json_string.dart';

/// Case-insensitive JSON field access for D365/API payloads.
abstract final class JsonMap {
  static Object? value(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) {
      return json[key];
    }
    final String lower = key.toLowerCase();
    for (final MapEntry<String, dynamic> entry in json.entries) {
      if (entry.key.toLowerCase() == lower) {
        return entry.value;
      }
    }
    return null;
  }

  static String string(Map<String, dynamic> json, String key) =>
      JsonString.trim(value(json, key));

  static String stringAny(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final String parsed = string(json, key);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return '';
  }

  static String? stringOrNull(Map<String, dynamic> json, String key) =>
      JsonString.trimOrNull(value(json, key));

  static int integer(
    Map<String, dynamic> json,
    String key, {
    int fallback = 0,
  }) {
    return integerOrNull(json, key) ?? fallback;
  }

  static int? integerOrNull(Map<String, dynamic> json, String key) {
    final Object? raw = value(json, key);
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim());
    }
    return null;
  }

  static bool flag(
    Map<String, dynamic> json,
    String key, {
    bool fallback = false,
  }) {
    final Object? raw = value(json, key);
    if (raw is bool) {
      return raw;
    }
    if (raw is num) {
      return raw != 0;
    }
    if (raw is String) {
      final String v = raw.trim().toLowerCase();
      if (v == 'true' || v == 'yes' || v == '1') {
        return true;
      }
      if (v == 'false' || v == 'no' || v == '0') {
        return false;
      }
    }
    return fallback;
  }

  static bool? flagOrNull(Map<String, dynamic> json, String key) {
    if (value(json, key) == null) {
      return null;
    }
    return flag(json, key);
  }
}
