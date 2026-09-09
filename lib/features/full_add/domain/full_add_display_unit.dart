/// Resolves the unit symbol shown beside available quantity / used for pricing.
abstract final class FullAddDisplayUnit {
  /// Prefer inventory unit; else barcode/item [lookupUnitId]; else null (hide).
  static String? resolve({
    required String? inventoryUnit,
    required String? lookupUnitId,
  }) {
    final String fromInventory = inventoryUnit?.trim() ?? '';
    if (fromInventory.isNotEmpty) {
      return fromInventory;
    }
    final String fromLookup = lookupUnitId?.trim() ?? '';
    if (fromLookup.isNotEmpty) {
      return fromLookup;
    }
    return null;
  }

  /// Formats available qty with an optional unit (single space, no invented unit).
  static String formatAvailable({
    required String formattedQuantity,
    required String? unit,
  }) {
    final String resolved = unit?.trim() ?? '';
    if (resolved.isEmpty) {
      return formattedQuantity;
    }
    return '$formattedQuantity $resolved';
  }
}
