/// Native Honeywell decode payload (not camera).
class HardwareScanEvent {
  const HardwareScanEvent({
    required this.value,
    required this.timestamp,
    this.symbology,
    this.source = 'honeywell_scanner',
  });

  final String value;
  final String source;
  final String? symbology;
  final DateTime timestamp;
}
