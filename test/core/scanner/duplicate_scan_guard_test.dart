import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/scanner/duplicate_scan_guard.dart';

void main() {
  test('ignores the same value inside the debounce window', () {
    final DuplicateScanGuard guard = DuplicateScanGuard(
      window: const Duration(milliseconds: 400),
    );
    final DateTime t0 = DateTime(2026, 1, 1, 12);
    expect(guard.isDuplicate('123', t0), isFalse);
    expect(
      guard.isDuplicate('123', t0.add(const Duration(milliseconds: 200))),
      isTrue,
    );
  });

  test('allows the same value after the window', () {
    final DuplicateScanGuard guard = DuplicateScanGuard(
      window: const Duration(milliseconds: 400),
    );
    final DateTime t0 = DateTime(2026, 1, 1, 12);
    expect(guard.isDuplicate('123', t0), isFalse);
    expect(
      guard.isDuplicate('123', t0.add(const Duration(milliseconds: 401))),
      isFalse,
    );
  });
}
