/// Preserves spaces in barcode / ItemId values sent to Dynamics.
abstract final class ScanCode {
  static final RegExp _controls = RegExp(r'[\r\n\t]');

  /// Removes scanner control characters only. Never collapses or trims spaces.
  static String stripControls(String raw) => raw.replaceAll(_controls, '');

  /// True when the value has no meaningful characters (spaces-only counts).
  static bool isBlank(String raw) => stripControls(raw).trim().isEmpty;
}
