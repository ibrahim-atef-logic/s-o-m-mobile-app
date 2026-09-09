import 'hardware_scan_event.dart';

/// Hardware trigger barcode stream. No-op on phones / emulators.
abstract class HardwareScannerService {
  Stream<HardwareScanEvent> get scans;

  Future<bool> get isSupported;

  Future<void> disposeScanner();
}
