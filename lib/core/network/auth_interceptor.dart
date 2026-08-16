import 'dart:async';

import 'package:dio/dio.dart';

/// Attaches Bearer token and serializes refresh on 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenReader,
    required this.onRefresh,
    required this.onRefreshFailed,
    required this.dio,
  });

  final Future<String?> Function() tokenReader;
  final Future<bool> Function() onRefresh;
  final void Function() onRefreshFailed;
  final Dio dio;

  bool _refreshing = false;
  final List<Completer<void>> _queue = <Completer<void>>[];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await tokenReader();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    final String path = err.requestOptions.path;
    if (path.contains('/auth/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout')) {
      handler.next(err);
      return;
    }

    try {
      if (_refreshing) {
        final Completer<void> waiter = Completer<void>();
        _queue.add(waiter);
        await waiter.future;
      } else {
        _refreshing = true;
        final bool ok = await onRefresh();
        _refreshing = false;
        for (final Completer<void> c in _queue) {
          c.complete();
        }
        _queue.clear();
        if (!ok) {
          onRefreshFailed();
          handler.next(err);
          return;
        }
      }

      final RequestOptions req = err.requestOptions;
      final String? token = await tokenReader();
      if (token != null) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      final Response<dynamic> response = await dio.fetch(req);
      handler.resolve(response);
    } catch (_) {
      _refreshing = false;
      onRefreshFailed();
      handler.next(err);
    }
  }
}
