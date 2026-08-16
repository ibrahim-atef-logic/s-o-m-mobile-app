import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/exceptions.dart';
import 'package:logic_retail_mobile/features/warehouses/data/datasources/warehouse_remote_data_source.dart';
import 'package:logic_retail_mobile/features/warehouses/data/models/warehouse_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late WarehouseRemoteDataSourceImpl sut;

  setUp(() {
    dio = MockDio();
    sut = WarehouseRemoteDataSourceImpl(dio);
  });

  Response<dynamic> ok(Object data) => Response<dynamic>(
    requestOptions: RequestOptions(path: ''),
    statusCode: 200,
    data: <String, dynamic>{'success': true, 'data': data},
  );

  test('calls /api/v1/warehouses with the operating company', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => ok(Fixtures.sampleWarehousesJson));

    final List<WarehouseModel> result = await sut.fetchWarehouses(' mm ');

    expect(result, hasLength(2));
    verify(
      () => dio.get<dynamic>(
        '/api/v1/warehouses',
        queryParameters: <String, String>{'company': 'mm'},
      ),
    ).called(1);
  });

  test('returns an empty list when data is empty', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => ok(<Map<String, dynamic>>[]));

    expect(await sut.fetchWarehouses('PLTR'), isEmpty);
  });

  test('rethrows the mapped exception from the error interceptor', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/v1/warehouses'),
        error: const ServerException('FORBIDDEN_COMPANY', statusCode: 403),
      ),
    );

    expect(
      () => sut.fetchWarehouses('logic-trial'),
      throwsA(isA<ServerException>()),
    );
  });
}
