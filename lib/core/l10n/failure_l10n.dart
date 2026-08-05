import '../../l10n/app_localizations.dart';
import '../error/failures.dart';

/// Maps sealed [Failure] types to localized user-facing strings.
extension FailureL10n on Failure {
  /// Short category title (network / auth / server…).
  String localizedTitle(AppLocalizations l10n) {
    return switch (this) {
      NetworkFailure() => l10n.errorNetwork,
      AuthFailure(:final String message) => _authTitle(l10n, message),
      ValidationFailure() => l10n.errorValidation,
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

  static String _authTitle(AppLocalizations l10n, String message) {
    final String lower = message.toLowerCase();
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
    };
    return placeholders.contains(raw);
  }

  static String _serverTitle(AppLocalizations l10n, String message) {
    final String lower = message.toLowerCase();
    if (lower.contains('503') ||
        lower.contains('unavailable') ||
        lower.contains('dynamics')) {
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
    if (lower.contains('not found') || lower.contains('no price') ||
        lower.contains('no stock') || lower.contains('barcode')) {
      return message.trim().isEmpty ? l10n.errorServer : message.trim();
    }
    return l10n.errorServer;
  }
}
