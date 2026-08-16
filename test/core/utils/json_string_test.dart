import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/utils/json_string.dart';

void main() {
  group('JsonString.trim', () {
    test('trims padded strings', () {
      expect(JsonString.trim('  BG410.003  '), 'BG410.003');
    });

    test('returns empty string for null', () {
      expect(JsonString.trim(null), '');
    });

    test('stringifies JSON numbers so personnelNumber stays a string', () {
      expect(JsonString.trim(1006), '1006');
      expect(JsonString.trim(1006), isA<String>());
    });
  });

  group('JsonString.trimOrNull', () {
    test('returns null for null input', () {
      expect(JsonString.trimOrNull(null), isNull);
    });

    test('returns null for blank string', () {
      expect(JsonString.trimOrNull('   '), isNull);
    });

    test('trims non-empty values', () {
      expect(JsonString.trimOrNull('  PCS  '), 'PCS');
    });

    test('stringifies non-string values then trims', () {
      expect(JsonString.trimOrNull(42), '42');
    });
  });
}
