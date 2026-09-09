import '../../../core/utils/scan_code.dart';

/// Local qty rules for Full Add before calling Dynamics.
abstract final class FullAddQtyRules {
  /// Rounds a Dynamics on-hand quantity to the nearest whole unit.
  static int roundNearest(num value) => value.round();

  /// Returns null when qty is valid against [availableSalesQuantity].
  ///
  /// Empty = blank/whitespace after stripping `\r\n\t` only (spaces inside
  /// digits are kept so `"1 0"` stays invalid).
  static String? validate({
    required String quantityText,
    required num availableSalesQuantity,
  }) {
    final String stripped = ScanCode.stripControls(quantityText);
    if (stripped.trim().isEmpty) {
      return 'qtyInvalid';
    }
    final int? qty = int.tryParse(stripped.trim());
    if (qty == null || qty < 1) {
      return 'qtyInvalid';
    }
    if (qty > roundNearest(availableSalesQuantity)) {
      return 'qtyExceeds';
    }
    return null;
  }

  static bool exceedsAvailable({
    required int quantity,
    required num availableSalesQuantity,
  }) => quantity > roundNearest(availableSalesQuantity);
}
