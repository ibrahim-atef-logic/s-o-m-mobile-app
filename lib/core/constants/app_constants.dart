/// App-wide API and storage keys.
abstract final class AppConstants {
  /// Live Sales Order API. Override with `--dart-define=API_BASE_URL=...`.
  /// Do not use localhost, hr-admin, or hrapp — those are other products.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://salesorderapp.logictec.online',
  );

  /// Normalized base (no trailing slash) for path joining.
  static String get apiBaseUrlNormalized {
    final String url = apiBaseUrl.trim();
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String localeCode = 'locale_code';
  static const String selectedCompany = 'selected_company';
  static const String userJson = 'user_json';
}
