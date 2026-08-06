/// Shared parsing helpers for Dynamics/OData string fields.
abstract final class JsonString {
  static String trim(Object? value) => (value as String? ?? '').trim();

  static String? trimOrNull(Object? value) {
    if (value == null) return null;
    final String s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}
