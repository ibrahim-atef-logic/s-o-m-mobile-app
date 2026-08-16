import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';
import '../models/company_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthResponseModel session);
  Future<AuthResponseModel?> readSession();
  Future<void> clear();
  Future<void> saveSelectedCompany(CompanyModel company);
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveAccessToken(String token);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  }) : _secure = secureStorage,
       _prefs = prefs;

  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  @override
  Future<void> saveSession(AuthResponseModel session) async {
    try {
      await _secure.write(
        key: StorageKeys.accessToken,
        value: session.accessToken,
      );
      await _secure.write(
        key: StorageKeys.refreshToken,
        value: session.refreshToken,
      );
      await _secure.write(
        key: StorageKeys.authSessionJson,
        value: jsonEncode(session.toJson()),
      );
      await _prefs.setString(
        StorageKeys.userJson,
        jsonEncode(session.user.toJson()),
      );
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<AuthResponseModel?> readSession() async {
    try {
      final String? blob = await _secure.read(key: StorageKeys.authSessionJson);
      if (blob != null && blob.isNotEmpty) {
        return AuthResponseModel.fromJson(
          jsonDecode(blob) as Map<String, dynamic>,
        );
      }
      return _readLegacySession();
    } catch (_) {
      throw const CacheException();
    }
  }

  Future<AuthResponseModel?> _readLegacySession() async {
    final String? access = await _secure.read(key: StorageKeys.accessToken);
    final String? refresh = await _secure.read(key: StorageKeys.refreshToken);
    final String? userJson = _prefs.getString(StorageKeys.userJson);
    if (access == null || refresh == null || userJson == null) {
      return null;
    }
    return AuthResponseModel(
      accessToken: access,
      refreshToken: refresh,
      user: UserSessionModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<void> clear() async {
    await _secure.delete(key: StorageKeys.accessToken);
    await _secure.delete(key: StorageKeys.refreshToken);
    await _secure.delete(key: StorageKeys.authSessionJson);
    await _prefs.remove(StorageKeys.userJson);
    await _prefs.remove(StorageKeys.selectedCompany);
  }

  @override
  Future<void> saveSelectedCompany(CompanyModel company) async {
    await _prefs.setString(
      StorageKeys.selectedCompany,
      jsonEncode(company.toJson()),
    );
    final AuthResponseModel? session = await readSession();
    if (session == null) {
      return;
    }
    final Map<String, dynamic> userJson = session.user.toJson();
    userJson['selectedCompany'] = company.toJson();
    await saveSession(
      session.copyWith(user: UserSessionModel.fromJson(userJson)),
    );
  }

  @override
  Future<String?> readAccessToken() =>
      _secure.read(key: StorageKeys.accessToken);

  @override
  Future<String?> readRefreshToken() =>
      _secure.read(key: StorageKeys.refreshToken);

  @override
  Future<void> saveAccessToken(String token) =>
      _secure.write(key: StorageKeys.accessToken, value: token);
}
