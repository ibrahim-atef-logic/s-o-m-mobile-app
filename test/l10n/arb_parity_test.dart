import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Arabic ARB key sets are identical', () {
    final File enFile = File('lib/l10n/app_en.arb');
    final File arFile = File('lib/l10n/app_ar.arb');
    expect(enFile.existsSync(), isTrue);
    expect(arFile.existsSync(), isTrue);

    final Map<String, dynamic> en =
        jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
    final Map<String, dynamic> ar =
        jsonDecode(arFile.readAsStringSync()) as Map<String, dynamic>;

    final Set<String> enKeys = en.keys
        .where((String k) => !k.startsWith('@'))
        .toSet();
    final Set<String> arKeys = ar.keys
        .where((String k) => !k.startsWith('@'))
        .toSet();

    expect(
      enKeys.difference(arKeys),
      isEmpty,
      reason: 'Keys in EN missing from AR: ${enKeys.difference(arKeys)}',
    );
    expect(
      arKeys.difference(enKeys),
      isEmpty,
      reason: 'Keys in AR missing from EN: ${arKeys.difference(enKeys)}',
    );
  });
}
