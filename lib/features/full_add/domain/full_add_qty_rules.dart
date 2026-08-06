/// Local qty rules for Full Add before calling Dynamics.
abstract final class FullAddQtyRules {
  /// Returns null when qty is valid against [availableSalesQuantity].
  static String? validate({
    required String quantityText,
    required num availableSalesQuantity,
  }) {
    final int? qty = int.tryParse(quantityText.trim());
    if (qty == null || qty < 1) {
      return 'qtyInvalid';
    }
    if (qty > availableSalesQuantity) {
      return 'qtyExceeds';
    }
    return null;
  }

  static bool exceedsAvailable({
    required int quantity,
    required num availableSalesQuantity,
  }) =>
      quantity > availableSalesQuantity;
}
