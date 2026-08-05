import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String company,
    required String personnelNumber,
    required String password,
  });

  Future<AuthResponseModel> refresh(String refreshToken);

  Future<void> logout(String refreshToken);
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
          'company': company,
          'personnelNumber': personnelNumber,
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
  Future<AuthResponseModel> refresh(String refreshToken) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/auth/refresh',
        data: <String, String>{'refreshToken': refreshToken},
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      return AuthResponseModel(
        accessToken: data['accessToken'] as String,
        refreshToken: refreshToken,
        user: UserSessionModel.fromJson(data['user'] as Map<String, dynamic>),
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

  Exception _mapDio(DioException e) {
    final Object? err = e.error;
    if (err is Exception) return err;
    return ServerException(e.message ?? 'Server error');
  }
}
