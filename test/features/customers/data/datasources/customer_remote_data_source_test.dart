import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/exceptions.dart';
import 'package:logic_retail_mobile/features/customers/data/datasources/customer_remote_data_source.dart';
import 'package:logic_retail_mobile/features/customers/data/models/customer_page_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CustomerRemoteDataSourceImpl sut;

  setUp(() {
    dio = MockDio();
    sut = CustomerRemoteDataSourceImpl(dio);
  });

  void stubGet(Object? data, {int status = 200}) {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: status,
        data: data,
      ),
    );
  }

  test('sends company, search, top and skip for paginated envelope', () async {
    stubGet(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'items': Fixtures.sampleCustomersJson,
        'top': 30,
        'skip': 0,
        'count': 2,
        'hasMore': false,
      },
    });

    final CustomerPageModel result = await sut.searchCustomers(
      company: 'mm',
      search: ' مير ',
      top: 30,
      skip: 0,
    );

    expect(result.items, hasLength(2));
    expect(result.hasMore, isFalse);
    verify(
      () => dio.get<dynamic>(
        '/api/v1/customers',
        queryParameters: <String, Object>{
          'company': 'mm',
          'search': 'مير',
          'top': 30,
          'skip': 0,
        },
      ),
    ).called(1);
  });

  test('dual-parses legacy bare array and caps top at 100', () async {
    stubGet(<String, dynamic>{
      'success': true,
      'data': Fixtures.sampleCustomersJson,
    });

    final CustomerPageModel result = await sut.searchCustomers(
      company: 'mm',
      search: '   ',
      top: 999,
    );

    expect(result.items, hasLength(2));
    verify(
      () => dio.get<dynamic>(
        '/api/v1/customers',
        queryParameters: <String, Object>{
          'company': 'mm',
          'top': 100,
          'skip': 0,
        },
      ),
    ).called(1);
  });

  test('returns an empty page for an unexpected payload', () async {
    stubGet(<String, dynamic>{'success': true, 'data': 'nope'});

    final CustomerPageModel result = await sut.searchCustomers(company: 'mm');
    expect(result.items, isEmpty);
    expect(result.hasMore, isFalse);
  });

  test('rethrows the mapped exception from the interceptor', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        error: const ServerException('FORBIDDEN_COMPANY: not allowed'),
      ),
    );

    expect(
      () => sut.searchCustomers(company: 'logic-trial'),
      throwsA(isA<ServerException>()),
    );
  });
}
