import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/exceptions.dart';
import 'package:logic_retail_mobile/features/customers/data/datasources/customer_remote_data_source.dart';
import 'package:logic_retail_mobile/features/customers/data/models/customer_model.dart';
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

  test('sends company, search and top', () async {
    stubGet(<String, dynamic>{
      'success': true,
      'data': Fixtures.sampleCustomersJson,
    });

    final List<CustomerModel> result = await sut.searchCustomers(
      company: 'mm',
      search: ' مير ',
      top: 50,
    );

    expect(result, hasLength(2));
    verify(
      () => dio.get<dynamic>(
        '/api/v1/customers',
        queryParameters: <String, Object>{
          'company': 'mm',
          'search': 'مير',
          'top': 50,
        },
      ),
    ).called(1);
  });

  test('omits an empty search and caps top at 200', () async {
    stubGet(<String, dynamic>{'success': true, 'data': <dynamic>[]});

    await sut.searchCustomers(company: 'mm', search: '   ', top: 999);

    verify(
      () => dio.get<dynamic>(
        '/api/v1/customers',
        queryParameters: <String, Object>{'company': 'mm', 'top': 200},
      ),
    ).called(1);
  });

  test('returns an empty list for an unexpected payload', () async {
    stubGet(<String, dynamic>{'success': true, 'data': 'nope'});

    expect(await sut.searchCustomers(company: 'mm'), isEmpty);
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
