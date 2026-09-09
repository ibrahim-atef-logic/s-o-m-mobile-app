import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:logger/logger.dart';

import '../utils/scan_code.dart';
import 'duplicate_scan_guard.dart';
import 'hardware_scan_event.dart';
import 'hardware_scanner_service.dart';

/// Honeywell Data Collection SDK wrapper. Starts only while [scans] has listeners.
class HoneywellHardwareScannerService implements HardwareScannerService {
  HoneywellHardwareScannerService({
    HoneywellScanner? scanner,
    DuplicateScanGuard? duplicateGuard,
    Logger? logger,
  }) : _scanner = scanner ?? HoneywellScanner(),
       _guard = duplicateGuard ?? DuplicateScanGuard(),
       _log = logger ?? Logger(printer: PrettyPrinter(methodCount: 0)) {
    _controller = StreamController<HardwareScanEvent>.broadcast(
      onListen: _onListen,
      onCancel: _onCancel,
    );
    _scanner.setScannerDecodeCallback(_onDecoded);
    _scanner.setScannerErrorCallback(_onError);
    _log.d('HardwareScannerService: Initialized');
  }

  final HoneywellScanner _scanner;
  final DuplicateScanGuard _guard;
  final Logger _log;
  late final StreamController<HardwareScanEvent> _controller;

  int _listeners = 0;
  bool _started = false;
  bool? _supported;

  static const Map<String, dynamic> kProperties = <String, dynamic>{
    'DEC_EAN13_ENABLED': true,
    'DEC_EAN8_ENABLED': true,
    'DEC_UPCA_ENABLE': true,
    'DEC_UPCE0_ENABLED': true,
    'DEC_UPCE1_ENABLED': true,
    'DEC_C128_ENABLED': true,
    'DEC_C39_ENABLED': true,
    'DEC_DATAMATRIX_ENABLED': true,
    'DEC_PDF417_ENABLED': true,
    'DEC_CODABAR_ENABLED': true,
    'DEC_I25_ENABLED': true,
    'DEC_AZTEC_ENABLED': true,
    'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    'DEC_EAN8_CHECK_DIGIT_TRANSMIT': true,
    'DEC_UPCA_CHECK_DIGIT_TRANSMIT': true,
    'DEC_UPCE_CHECK_DIGIT_TRANSMIT': true,
    'DEC_UPCE0_CHECK_DIGIT_TRANSMIT': true,
    'DEC_UPCE1_CHECK_DIGIT_TRANSMIT': true,
    'DEC_CODABAR_START_STOP_TRANSMIT': true,
    'NTF_GOOD_READ_ENABLED': false,
    'NTF_BAD_READ_ENABLED': false,
    'NTF_VIBRATE_ENABLED': false,
  };

  @override
  Stream<HardwareScanEvent> get scans => _controller.stream;

  @override
  Future<bool> get isSupported async {
    if (_supported != null) {
      return _supported!;
    }
    if (kIsWeb || !Platform.isAndroid) {
      _supported = false;
      return false;
    }
    try {
      _supported = await _scanner.isSupported();
    } catch (e) {
      _log.w('HardwareScannerService: isSupported error: $e');
      _supported = false;
    }
    _log.d('HardwareScannerService: isSupported=$_supported');
    return _supported!;
  }

  Future<void> _onListen() async {
    _listeners += 1;
    _log.d('HardwareScannerService: Listener attached ($_listeners)');
    if (_listeners != 1) {
      return;
    }
    if (!await isSupported) {
      return;
    }
    try {
      final bool ok = await _scanner.startScanner();
      _started = ok;
      _log.d('HardwareScannerService: startScanner() => $ok');
      if (ok) {
        await _scanner.setProperties(kProperties);
        _log.d('HardwareScannerService: Scanner properties configured');
      }
    } catch (e) {
      _log.e('HardwareScannerService: Native scanner error: $e');
    }
  }

  Future<void> _onCancel() async {
    _listeners = _listeners > 0 ? _listeners - 1 : 0;
    _log.d('HardwareScannerService: Listener detached ($_listeners)');
    if (_listeners > 0 || !_started) {
      return;
    }
    try {
      await _scanner.pauseScanner();
      _started = false;
      _log.d('HardwareScannerService: Scanner paused');
    } catch (e) {
      _log.e('HardwareScannerService: Native scanner error: $e');
    }
  }

  void _onDecoded(ScannedData? data) {
    final String value = ScanCode.stripControls(data?.code ?? '');
    if (ScanCode.isBlank(value)) {
      return;
    }
    if (_guard.isDuplicate(value)) {
      _log.d('HardwareScannerService: Duplicate ignored value="$value"');
      return;
    }
    final String? symbology = data?.codeId ?? data?.codeType ?? data?.aimId;
    _log.d(
      'HardwareScannerService: Decoded value="$value" codeId="$symbology"',
    );
    if (!_controller.isClosed) {
      _controller.add(
        HardwareScanEvent(
          value: value,
          symbology: symbology,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _onError(Exception error) {
    _log.e('HardwareScannerService: Native scanner error: $error');
  }

  @override
  Future<void> disposeScanner() async {
    try {
      await _scanner.disposeScanner();
    } catch (e) {
      _log.e('HardwareScannerService: dispose error: $e');
    }
    await _controller.close();
  }
}
