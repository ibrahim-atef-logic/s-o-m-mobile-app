import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/datasources/sales_orders_remote_data_source.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/models/created_order_model.dart';
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

    final List<SalesOrderHeaderModel> result = await sut.getMyOrders(
      company: 'mm',
    );

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

  test('createOrder posts company, customer, warehouse and currency', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 201,
        data: <String, dynamic>{
          'success': true,
          'data': Fixtures.sampleCreatedOrderJson,
        },
      ),
    );

    final CreatedOrderModel created = await sut.createOrder(
      company: 'mm',
      custAccount: 'MMS021',
      inventLocationId: Fixtures.warehouse,
      currencyCode: 'SAR',
    );

    expect(created.salesOrderNumber, Fixtures.createdSalesId);
    expect(created.orderTakerPersonnelNumber, Fixtures.personnelNumber);
    verify(
      () => dio.post<dynamic>(
        '/api/v1/sales-orders',
        data: <String, String>{
          'company': 'mm',
          'custAccount': 'MMS021',
          'inventLocationId': Fixtures.warehouse,
          'currencyCode': 'SAR',
        },
      ),
    ).called(1);
  });

  test('createOrder never sends the sales taker', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 201,
        data: <String, dynamic>{
          'success': true,
          'data': Fixtures.sampleCreatedOrderJson,
        },
      ),
    );

    await sut.createOrder(company: 'mm', custAccount: 'MMS021');

    final Map<String, dynamic> body =
        verify(
              () => dio.post<dynamic>(
                '/api/v1/sales-orders',
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(body.containsKey('workerRecId'), isFalse);
    expect(body.containsKey('personnelNumber'), isFalse);
    expect(body.containsKey('inventLocationId'), isFalse);
  });
}
