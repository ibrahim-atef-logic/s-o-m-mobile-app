import 'failures.dart';

/// Backend error codes the create-order flow reacts to.
abstract final class ApiErrorCode {
  static const String validation = 'VALIDATION_ERROR';
  static const String warehouseRequired = 'WAREHOUSE_REQUIRED';
  static const String forbiddenCompany = 'FORBIDDEN_COMPANY';
  static const String dynamicsPrefix = 'DYNAMICS_';
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

  bool get isDynamicsOutage =>
      apiCode?.startsWith(ApiErrorCode.dynamicsPrefix) ?? false;
}
