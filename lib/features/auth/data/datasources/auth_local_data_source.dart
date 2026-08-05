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
      final String? access = await _secure.read(key: StorageKeys.accessToken);
      final String? refresh = await _secure.read(key: StorageKeys.refreshToken);
      final String? userJson = _prefs.getString(StorageKeys.userJson);
      if (access == null || refresh == null || userJson == null) {
        return null;
      }
      final UserSessionModel user = UserSessionModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      return AuthResponseModel(
        accessToken: access,
        refreshToken: refresh,
        user: user,
      );
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> clear() async {
    await _secure.delete(key: StorageKeys.accessToken);
    await _secure.delete(key: StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.userJson);
    await _prefs.remove(StorageKeys.selectedCompany);
  }

  @override
  Future<void> saveSelectedCompany(CompanyModel company) async {
    await _prefs.setString(
      StorageKeys.selectedCompany,
      jsonEncode(company.toJson()),
    );
    final String? userJson = _prefs.getString(StorageKeys.userJson);
    if (userJson == null) return;
    final UserSessionModel user = UserSessionModel.fromJson(
      jsonDecode(userJson) as Map<String, dynamic>,
    );
    final UserSessionModel updated = UserSessionModel(
      personnelNumber: user.personnelNumber,
      workerRecId: user.workerRecId,
      name: user.name,
      companies: user.companies,
      selectedCompany: company,
    );
    await _prefs.setString(StorageKeys.userJson, jsonEncode(updated.toJson()));
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
