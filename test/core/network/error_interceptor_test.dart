import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/exceptions.dart';
import 'package:logic_retail_mobile/core/network/error_interceptor.dart';

class _FixedAdapter implements HttpClientAdapter {
  _FixedAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      _handler(options);
}

Dio _dioWith(HttpClientAdapter adapter) {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.interceptors.add(ErrorInterceptor());
  dio.httpClientAdapter = adapter;
  return dio;
}

ResponseBody _jsonBody(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

void main() {
  test('maps 401 response to AuthException', () async {
    final Dio dio = _dioWith(
      _FixedAdapter(
        (_) async => _jsonBody(401, <String, dynamic>{
          'success': false,
          'error': <String, dynamic>{
            'code': 'UNAUTHORIZED',
            'message': 'Missing token',
          },
        }),
      ),
    );

    try {
      await dio.get<dynamic>('/api/v1/sales-orders');
      fail('expected DioException');
    } on DioException catch (e) {
      expect(e.error, isA<AuthException>());
      expect((e.error! as AuthException).message, 'UNAUTHORIZED: Missing token');
    }
  });

  test('maps connection timeout to NetworkException', () async {
    final Dio dio = _dioWith(
      _FixedAdapter(
        (RequestOptions options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      ),
    );

    try {
      await dio.get<dynamic>('/health');
      fail('expected DioException');
    } on DioException catch (e) {
      expect(e.error, isA<NetworkException>());
    }
  });

  test('maps envelope error code into ServerException message', () async {
    final Dio dio = _dioWith(
      _FixedAdapter(
        (_) async => _jsonBody(400, <String, dynamic>{
          'success': false,
          'error': <String, dynamic>{
            'code': 'NO_PRICE',
            'message': 'Price not found',
          },
        }),
      ),
    );

    try {
      await dio.get<dynamic>('/api/v1/pricing');
      fail('expected DioException');
    } on DioException catch (e) {
      expect(e.error, isA<ServerException>());
      expect(
        (e.error! as ServerException).message,
        'NO_PRICE: Price not found',
      );
    }
  });
}
