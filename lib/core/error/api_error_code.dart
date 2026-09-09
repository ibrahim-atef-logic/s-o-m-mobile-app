import 'failures.dart';

/// Backend error codes the create-order flow reacts to.
abstract final class ApiErrorCode {
  static const String validation = 'VALIDATION_ERROR';
  static const String warehouseRequired = 'WAREHOUSE_REQUIRED';
  static const String forbiddenCompany = 'FORBIDDEN_COMPANY';
  static const String lineAlreadyExists = 'LINE_ALREADY_EXISTS';
  static const String itemNotFound = 'ITEM_NOT_FOUND';
  static const String barcodeNotFound = 'BARCODE_NOT_FOUND';
  static const String noPrice = 'NO_PRICE';
  static const String noStock = 'NO_STOCK';
  static const String qtyExceedsStock = 'QTY_EXCEEDS_STOCK';
  static const String lineNotFound = 'LINE_NOT_FOUND';
  static const String orderNotEditable = 'ORDER_NOT_EDITABLE';
  static const String soNotOpen = 'SO_NOT_OPEN';
  static const String maxLines = 'MAX_LINES';
  static const String dynamicsPrefix = 'DYNAMICS_';
  static const String dynamicsUnavailable = 'DYNAMICS_UNAVAILABLE';
  static const String dynamicsError = 'DYNAMICS_ERROR';
  static const String dynamicsThrottled = 'DYNAMICS_THROTTLED';
}

/// Reads the `CODE` the error interceptor prefixed onto a failure message.
///
/// Why: the envelope is `{ "error": { "code", "message" } }` and the
/// interceptor flattens it to `CODE: message` before it reaches the domain.
extension FailureApiCode on Failure {
  String? get apiCode {
    final int separator = message.indexOf(':');
    final String head =
        (separator == -1 ? message : message.substring(0, separator))
            .trim()
            .toUpperCase();
    if (head.isEmpty || head.contains(' ')) {
      return null;
    }
    return head;
  }

  bool get isWarehouseRequired => apiCode == ApiErrorCode.warehouseRequired;

  bool get isValidationCode => apiCode == ApiErrorCode.validation;

  bool get isForbiddenCompany => apiCode == ApiErrorCode.forbiddenCompany;

  bool get isLineAlreadyExists => apiCode == ApiErrorCode.lineAlreadyExists;

  bool get isItemNotFound =>
      apiCode == ApiErrorCode.itemNotFound ||
      apiCode == ApiErrorCode.barcodeNotFound;

  bool get isLineNotFound => apiCode == ApiErrorCode.lineNotFound;

  bool get isOrderNotEditable => apiCode == ApiErrorCode.orderNotEditable;

  bool get isNoPrice => apiCode == ApiErrorCode.noPrice;

  bool get isNoStock => apiCode == ApiErrorCode.noStock;

  bool get isQtyExceedsStock => apiCode == ApiErrorCode.qtyExceedsStock;

  bool get isSoNotOpen => apiCode == ApiErrorCode.soNotOpen;

  bool get isMaxLines => apiCode == ApiErrorCode.maxLines;

  /// DELETE locked order, or full/quick against a non-open SO.
  bool get isOrderLockedForEdit => isOrderNotEditable || isSoNotOpen;

  bool get isDynamicsError => apiCode == ApiErrorCode.dynamicsError;

  /// True only for outage / throttle — not every DYNAMICS_* code.
  bool get isDynamicsOutage =>
      apiCode == ApiErrorCode.dynamicsUnavailable ||
      apiCode == ApiErrorCode.dynamicsThrottled;

  /// D365 Infolog unit conversion failure (retry with حبة / empty).
  bool get isUnitConversionError {
    if (!isDynamicsError) {
      return false;
    }
    return message.toLowerCase().contains('conversion between');
  }
}
