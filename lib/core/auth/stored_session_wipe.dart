import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Deletes any auth session written by an older build.
///
/// Why: sessions are memory-only now, but an upgrading device can still carry
/// tokens on disk from the previous version and must not stay signed in.
Future<void> wipeStoredSession({
  required FlutterSecureStorage secureStorage,
  required SharedPreferences prefs,
}) async {
  for (final String key in StorageKeys.sessionKeys) {
    await secureStorage.delete(key: key);
    await prefs.remove(key);
  }
}
