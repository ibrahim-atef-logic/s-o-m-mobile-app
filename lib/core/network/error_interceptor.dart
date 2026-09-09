import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logFullError(err);
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
        final String? apiMessage = error['message'] is String
            ? error['message'] as String
            : null;
        final String? apiCode = error['code'] is String
            ? error['code'] as String
            : null;
        if (apiMessage != null && apiMessage.isNotEmpty) {
          message = apiCode != null && apiCode.isNotEmpty
              ? '$apiCode: $apiMessage'
              : apiMessage;
        }
      }
    }

    final bool accountDisabled = message.toUpperCase().contains(
      'ACCOUNT_DISABLED',
    );
    if (code == 401 || (code == 403 && accountDisabled)) {
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

  /// Prints the untruncated failure so long D365 infologs stay readable.
  ///
  /// The snackbar clips them and the pretty logger wraps them in a box, so this
  /// is the copy that can be pasted into a bug report.
  void _logFullError(DioException err) {
    if (!kDebugMode) {
      return;
    }
    final RequestOptions request = err.requestOptions;
    final Object? data = err.response?.data;
    debugPrint(
      'API ERROR ${request.method} ${request.uri}\n'
      '  status: ${err.response?.statusCode} (${err.type.name})\n'
      '  request: ${request.data}\n'
      '  response: ${data ?? err.message}',
    );
  }
}
