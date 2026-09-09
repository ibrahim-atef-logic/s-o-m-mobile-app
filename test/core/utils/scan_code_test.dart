import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/utils/scan_code.dart';

void main() {
  test('stripControls removes CR LF tab only', () {
    expect(ScanCode.stripControls('6287007961754\r\n'), '6287007961754');
    expect(ScanCode.stripControls('BG 410.003'), 'BG 410.003');
    expect(ScanCode.stripControls('  BG410.003  '), '  BG410.003  ');
  });

  test('isBlank treats spaces-only as empty', () {
    expect(ScanCode.isBlank('   '), isTrue);
    expect(ScanCode.isBlank('\r\n'), isTrue);
    expect(ScanCode.isBlank('BG 410.003'), isFalse);
  });
}
