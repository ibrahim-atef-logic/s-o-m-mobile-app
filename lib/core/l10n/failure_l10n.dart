import '../../l10n/app_localizations.dart';
import '../error/api_error_code.dart';
import '../error/failures.dart';

/// Maps sealed [Failure] types to localized user-facing strings.
extension FailureL10n on Failure {
  /// Short category title (network / auth / server…).
  String localizedTitle(AppLocalizations l10n) {
    if (isDynamicsOutage) {
      return l10n.errorDynamicsUnavailable;
    }
    return switch (this) {
      NetworkFailure() => l10n.errorNetwork,
      AuthFailure(:final String message) => _authTitle(l10n, message),
      ValidationFailure(:final String message) => _validationTitle(
        l10n,
        message,
      ),
      CacheFailure() => l10n.errorCache,
      ServerFailure(:final String message) => _serverTitle(l10n, message),
    };
  }

  /// Preferred snackbar / banner text — API or validation detail when useful.
  String localizedMessage(AppLocalizations l10n) {
    final String title = localizedTitle(l10n);
    final String raw = message.trim();
    if (raw.isEmpty || _isGenericPlaceholder(raw)) {
      return title;
    }
    if (_isCustomerStopped(raw)) {
      return l10n.errorCustomerStopped;
    }
    if (isLineAlreadyExists || _isLineAlreadyExists(raw)) {
      return l10n.errorLineAlreadyExists;
    }
    if (apiCode == ApiErrorCode.barcodeNotFound) {
      return l10n.errorBarcodeNotFoundTryItem;
    }
    if (isItemNotFound) {
      return l10n.errorItemNotFound;
    }
    if (isForbiddenCompany) {
      return l10n.errorForbiddenCompany;
    }
    if (isSoNotOpen) {
      return l10n.errorSoNotOpen;
    }
    if (isOrderNotEditable) {
      return _detailAfterCode(raw);
    }
    if (isMaxLines) {
      return l10n.errorMaxQuickLines;
    }
    if (isNoStock) {
      return l10n.errorNoStock;
    }
    if (isQtyExceedsStock) {
      return l10n.errorQtyExceeds;
    }
    if (isNoPrice || _isNoPrice(raw)) {
      return l10n.errorNoPrice;
    }
    if (isUnitConversionError) {
      return l10n.errorUnitConversion;
    }
    if (_isPasswordChangeFailure(raw)) {
      return l10n.errorPasswordChangeFailed;
    }
    return switch (this) {
      NetworkFailure() => title,
      CacheFailure() => title,
      AuthFailure() || ValidationFailure() || ServerFailure() => raw,
    };
  }

  /// Title + detail for snackbars when the API message adds context.
  String snackBarMessage(AppLocalizations l10n) {
    final String title = localizedTitle(l10n);
    final String body = localizedMessage(l10n);
    if (body == title) {
      return title;
    }
    return '$title\n$body';
  }

  String? get technicalDetails {
    if (message.isEmpty || _isGenericPlaceholder(message)) return null;
    return message;
  }

  static String _detailAfterCode(String raw) {
    final int separator = raw.indexOf(':');
    if (separator == -1) {
      return raw.trim();
    }
    final String detail = raw.substring(separator + 1).trim();
    return detail.isEmpty ? raw.trim() : detail;
  }

  static String _authTitle(AppLocalizations l10n, String message) {
    final String lower = message.toLowerCase();
    if (lower.contains('account_disabled')) {
      return l10n.errorAccountDisabled;
    }
    if (lower.contains('auth_company_unknown') ||
        lower.contains('not registered') ||
        (lower.contains('company') &&
            (lower.contains('not exist') ||
                lower.contains('unknown') ||
                lower.contains('not found')))) {
      return l10n.errorAuthCompanyUnknown;
    }
    if (lower.contains('personnel') ||
        lower.contains('password') ||
        lower.contains('auth_failed')) {
      return l10n.errorAuthCredentials;
    }
    return l10n.errorAuth;
  }

  static bool _isGenericPlaceholder(String raw) {
    const Set<String> placeholders = <String>{
      'Server error',
      'Network error',
      'Cache error',
      'Validation error',
      'Authentication failed',
      'WAREHOUSE_NOT_ASSIGNED',
    };
    return placeholders.contains(raw);
  }

  static String _validationTitle(AppLocalizations l10n, String message) {
    final String lower = message.toLowerCase();
    if (lower.contains('warehouse_not_assigned') ||
        lower.contains('warehouse are required')) {
      return l10n.errorWarehouseNotAssigned;
    }
    return l10n.errorValidation;
  }

  /// D365 blocks orders for a stopped customer with an infolog like
  /// "Customer <acct> is stopped for All". Detect it so the user sees a clear
  /// reason instead of the raw table-write dump.
  static bool _isCustomerStopped(String message) {
    final String lower = message.toLowerCase();
    return lower.contains('is stopped for') ||
        (lower.contains('stopped') && lower.contains('customer'));
  }

  static bool _isLineAlreadyExists(String message) {
    final String lower = message.toLowerCase();
    return lower.contains('line_already_exists') ||
        lower.contains('already exists in the system') ||
        lower.contains('already on sales order') ||
        lower.contains('entered previously');
  }

  static bool _isNoPrice(String message) {
    final String lower = message.toLowerCase();
    return lower.contains('no_price') ||
        lower.contains('no price') ||
        lower.contains('price not found');
  }

  static bool _isPasswordChangeFailure(String message) {
    final String lower = message.toLowerCase();
    return lower.contains('password_change_failed') ||
        lower.contains('password change failed') ||
        (lower.contains('password') &&
            lower.contains('change') &&
            (lower.contains('fail') ||
                lower.contains('unable') ||
                lower.contains('could not') ||
                lower.contains('error')));
  }

  static String _serverTitle(AppLocalizations l10n, String message) {
    final String lower = message.toLowerCase();
    if (_isCustomerStopped(message)) {
      return l10n.errorCustomerStopped;
    }
    if (_isLineAlreadyExists(message)) {
      return l10n.errorLineAlreadyExists;
    }
    if (message.toUpperCase().contains('BARCODE_NOT_FOUND')) {
      return l10n.errorBarcodeNotFoundTryItem;
    }
    if (message.toUpperCase().contains('ITEM_NOT_FOUND')) {
      return l10n.errorItemNotFound;
    }
    if (message.toUpperCase().contains('FORBIDDEN_COMPANY')) {
      return l10n.errorForbiddenCompany;
    }
    if (message.toUpperCase().contains('SO_NOT_OPEN')) {
      return l10n.errorSoNotOpen;
    }
    if (message.toUpperCase().contains('ORDER_NOT_EDITABLE')) {
      return _detailAfterCode(message);
    }
    if (message.toUpperCase().contains('MAX_LINES')) {
      return l10n.errorMaxQuickLines;
    }
    if (message.toUpperCase().contains('NO_STOCK')) {
      return l10n.errorNoStock;
    }
    if (message.toUpperCase().contains('QTY_EXCEEDS_STOCK')) {
      return l10n.errorQtyExceeds;
    }
    if (_isNoPrice(message)) {
      return l10n.errorNoPrice;
    }
    if (_isPasswordChangeFailure(message) ||
        lower.contains('password_change_failed')) {
      return l10n.errorPasswordChangeFailed;
    }
    if (lower.contains('warehouse_not_assigned') ||
        lower.contains('warehouse are required')) {
      return l10n.errorWarehouseNotAssigned;
    }
    if (message.toUpperCase().contains('DYNAMICS_UNAVAILABLE') ||
        (lower.contains('503') && lower.contains('unavailable'))) {
      return l10n.errorDynamicsUnavailable;
    }
    if (message.toUpperCase().contains('DYNAMICS_ERROR')) {
      return l10n.errorPriceFetchFailed;
    }
    if (lower.contains('503') || lower.contains('unavailable')) {
      return l10n.errorDynamicsUnavailable;
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return l10n.errorTimeout;
    }
    if (lower.contains('session') ||
        lower.contains('401') ||
        lower.contains('unauthorized') ||
        lower.contains('expired')) {
      return l10n.errorSessionExpired;
    }
    if (lower.contains('forbidden') || lower.contains('not allowed')) {
      return l10n.errorValidation;
    }
    if (lower.contains('not found') ||
        lower.contains('no price') ||
        lower.contains('no stock') ||
        lower.contains('barcode')) {
      return message.trim().isEmpty ? l10n.errorServer : message.trim();
    }
    return l10n.errorServer;
  }
}
