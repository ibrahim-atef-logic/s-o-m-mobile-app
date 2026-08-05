import 'package:dio/dio.dart';

import '../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
        ),
      );
      return;
    }

    final int? code = err.response?.statusCode;
    final Object? data = err.response?.data;
    String message = 'Server error';
    if (data is Map<String, dynamic>) {
      final Object? error = data['error'];
      if (error is Map<String, dynamic>) {
        final String? apiMessage =
            error['message'] is String ? error['message'] as String : null;
        final String? apiCode =
            error['code'] is String ? error['code'] as String : null;
        if (apiMessage != null && apiMessage.isNotEmpty) {
          message = apiCode != null && apiCode.isNotEmpty
              ? '$apiCode: $apiMessage'
              : apiMessage;
        }
      }
    }

    if (code == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: AuthException(message),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ServerException(message, statusCode: code),
        response: err.response,
        type: err.type,
      ),
    );
  }
}
