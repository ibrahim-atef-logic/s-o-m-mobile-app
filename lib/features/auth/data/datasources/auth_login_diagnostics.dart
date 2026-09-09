import 'package:flutter/foundation.dart';

import '../models/user_session_model.dart';

/// Dev-only diagnostics for login user payloads (never logs secrets).
abstract final class AuthLoginDiagnostics {
  /// Logs user JSON keys when [retailChannelName] is missing so we can see
  /// whether the gateway still omits D365 `RetailChannelName`.
  static void logMissingChannelName(UserSessionModel user) {
    if (!kDebugMode) {
      return;
    }
    final String? name = user.retailChannelName?.trim();
    if (name != null && name.isNotEmpty) {
      return;
    }
    final Map<String, dynamic> json = user.toJson();
    final List<String> presentKeys = <String>[
      for (final MapEntry<String, dynamic> e in json.entries)
        if (e.value != null && '${e.value}'.trim().isNotEmpty) e.key,
    ]..sort();
    debugPrint(
      'AUTH login user keys (no retailChannelName yet): $presentKeys — '
      'backend should map D365 RetailChannelName → user.retailChannelName',
    );
  }
}
