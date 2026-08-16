/// Shared parsing helpers for Dynamics/OData string fields.
abstract final class JsonString {
  /// Always a string: JSON numbers like `1006` become `"1006"`.
  static String trim(Object? value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  static String? trimOrNull(Object? value) {
    if (value == null) return null;
    final String s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}
