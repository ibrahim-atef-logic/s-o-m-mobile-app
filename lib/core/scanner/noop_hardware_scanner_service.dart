import 'hardware_scan_event.dart';
import 'hardware_scanner_service.dart';

/// Used in tests and when the Honeywell SDK is unavailable.
class NoopHardwareScannerService implements HardwareScannerService {
  @override
  Stream<HardwareScanEvent> get scans => const Stream<HardwareScanEvent>.empty();

  @override
  Future<bool> get isSupported async => false;

  @override
  Future<void> disposeScanner() async {}
}
