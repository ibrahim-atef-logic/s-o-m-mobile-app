import '../utils/scan_code.dart';

/// Drops bounce / double-trigger of the same barcode within a short window.
class DuplicateScanGuard {
  DuplicateScanGuard({
    this.window = const Duration(milliseconds: 400),
  });

  final Duration window;

  String? _lastValue;
  DateTime? _lastAt;

  bool isDuplicate(String value, [DateTime? now]) {
    final DateTime stamped = now ?? DateTime.now();
    final String trimmed = ScanCode.stripControls(value);
    if (_lastValue == trimmed &&
        _lastAt != null &&
        stamped.difference(_lastAt!) < window) {
      return true;
    }
    _lastValue = trimmed;
    _lastAt = stamped;
    return false;
  }
}
