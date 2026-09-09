import 'dart:async';

import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../utils/scan_code.dart';
import 'hardware_scan_event.dart';
import 'hardware_scanner_service.dart';

/// Subscribes to Honeywell hardware scans while this subtree is mounted.
class HardwareScanListener extends StatefulWidget {
  const HardwareScanListener({
    required this.onScan,
    required this.child,
    super.key,
  });

  final ValueChanged<String> onScan;
  final Widget child;

  @override
  State<HardwareScanListener> createState() => _HardwareScanListenerState();
}

class _HardwareScanListenerState extends State<HardwareScanListener> {
  StreamSubscription<HardwareScanEvent>? _sub;

  @override
  void initState() {
    super.initState();
    if (!sl.isRegistered<HardwareScannerService>()) {
      return;
    }
    _sub = sl<HardwareScannerService>().scans.listen((HardwareScanEvent scan) {
      if (!mounted) {
        return;
      }
      final String value = ScanCode.stripControls(scan.value);
      if (ScanCode.isBlank(value)) {
        return;
      }
      widget.onScan(value);
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
