import '../models/auth_response_model.dart';
import '../models/company_model.dart';

/// Holds the signed-in session for the lifetime of the process.
///
/// Why: tokens are never written to disk, so killing the app always forces a
/// fresh login instead of silently restoring a stale session.
abstract class AuthSessionStore {
  AuthResponseModel? get session;

  String? get accessToken;

  String? get refreshToken;

  void save(AuthResponseModel session);

  void saveAccessToken(String token);

  void saveSelectedCompany(CompanyModel company);

  void clear();
}

class InMemoryAuthSessionStore implements AuthSessionStore {
  AuthResponseModel? _session;

  @override
  AuthResponseModel? get session => _session;

  @override
  String? get accessToken => _session?.accessToken;

  @override
  String? get refreshToken => _session?.refreshToken;

  @override
  void save(AuthResponseModel session) {
    _session = session;
  }

  @override
  void saveAccessToken(String token) {
    final AuthResponseModel? current = _session;
    if (current == null) {
      return;
    }
    _session = current.copyWith(accessToken: token);
  }

  @override
  void saveSelectedCompany(CompanyModel company) {
    final AuthResponseModel? current = _session;
    if (current == null) {
      return;
    }
    final Map<String, dynamic> userJson = current.user.toJson();
    userJson['selectedCompany'] = company.toJson();
    _session = current.copyWith(user: UserSessionModel.fromJson(userJson));
  }

  @override
  void clear() {
    _session = null;
  }
}
