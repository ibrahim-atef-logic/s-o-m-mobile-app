import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_map.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String company,
    required String personnelNumber,
    required String password,
  });

  Future<UserSessionModel> me();

  Future<AuthResponseModel> refresh(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login({
    required String company,
    required String personnelNumber,
    required String password,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/auth/login',
        data: <String, String>{
          'company': company.trim(),
          'personnelNumber': personnelNumber.trim(),
          'password': password,
        },
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return AuthResponseModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<UserSessionModel> me() async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/auth/me',
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final Object? data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw const ServerException('Invalid /auth/me payload');
      }
      final Object? userRaw = JsonMap.value(data, 'user');
      return UserSessionModel.fromJson(
        userRaw is Map<String, dynamic> ? userRaw : data,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<AuthResponseModel> refresh(String refreshToken) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/auth/refresh',
        data: <String, String>{'refreshToken': refreshToken},
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final String newRefresh =
          JsonMap.stringOrNull(data, 'refreshToken') ?? refreshToken;
      return AuthResponseModel.fromJson(
        <String, dynamic>{
          ...data,
          'refreshToken': newRefresh,
        },
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/auth/logout',
        data: <String, String>{'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  @override
  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/auth/change-password',
        data: <String, String>{
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final Object? data = body['data'];
      if (data is Map<String, dynamic>) {
        return JsonMap.stringOrNull(data, 'message') ?? 'Password changed';
      }
      return 'Password changed';
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Exception _mapDio(DioException e) {
    final Object? err = e.error;
    if (err is Exception) return err;
    return ServerException(e.message ?? 'Server error');
  }
}
