import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/datasources/sales_orders_remote_data_source.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/models/sales_order_header_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SalesOrdersRemoteDataSourceImpl sut;

  setUp(() {
    dio = MockDio();
    sut = SalesOrdersRemoteDataSourceImpl(dio);
  });

  test('getMyOrders uses company=mm query and parses list', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (Invocation inv) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <String, dynamic>{
          'success': true,
          'data': <Map<String, dynamic>>[Fixtures.sampleOrderHeaderJson],
        },
      ),
    );

    final List<SalesOrderHeaderModel> result =
        await sut.getMyOrders(company: 'mm');

    expect(result, hasLength(1));
    expect(result.first.salesId, Fixtures.salesId);

    verify(
      () => dio.get<dynamic>(
        '/api/v1/sales-orders',
        queryParameters: <String, String>{'company': 'mm'},
      ),
    ).called(1);
  });

  test('getOrder hits sales-orders/{id} with company query', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (Invocation inv) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <String, dynamic>{
          'success': true,
          'data': Fixtures.sampleOrderHeaderJson,
        },
      ),
    );

    final SalesOrderHeaderModel order = await sut.getOrder(
      salesId: Fixtures.salesId,
      company: 'mm',
    );

    expect(order.salesId, Fixtures.salesId);
    verify(
      () => dio.get<dynamic>(
        '/api/v1/sales-orders/${Fixtures.salesId}',
        queryParameters: <String, String>{'company': 'mm'},
      ),
    ).called(1);
  });
}
