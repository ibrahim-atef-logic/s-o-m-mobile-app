import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Persists and restores the user-selected app locale.
class LocaleRepository {
  LocaleRepository(this._prefs);

  final SharedPreferences _prefs;

  static const Locale defaultLocale = Locale('ar');

  Locale read() {
    final String? code = _prefs.getString(StorageKeys.localeCode);
    if (code == null || code.isEmpty) {
      return defaultLocale;
    }
    return Locale(code);
  }

  Future<void> write(Locale locale) async {
    await _prefs.setString(StorageKeys.localeCode, locale.languageCode);
  }
}
