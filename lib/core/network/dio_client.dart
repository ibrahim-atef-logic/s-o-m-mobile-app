import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

Dio createDio({
  required Future<String?> Function() tokenReader,
  required Future<bool> Function() onRefresh,
  required void Function() onRefreshFailed,
}) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: <String, Object?>{'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    AuthInterceptor(
      tokenReader: tokenReader,
      onRefresh: onRefresh,
      onRefreshFailed: onRefreshFailed,
      dio: dio,
    ),
    ErrorInterceptor(),
    if (kDebugMode)
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
      ),
  ]);

  return dio;
}
