import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CatalogRemoteDataSourceImpl sut;

  setUp(() {
    dio = MockDio();
    sut = CatalogRemoteDataSourceImpl(dio);
  });

  Response<dynamic> ok(Object data) => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <String, dynamic>{'success': true, 'data': data},
      );

  test('lookupBarcode builds path and company query', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => ok(Fixtures.sampleBarcodeJson));

    final item = await sut.lookupBarcode(code: Fixtures.barcode, company: 'mm');
    expect(item.itemNumber, Fixtures.itemNumber);

    verify(
      () => dio.get<dynamic>(
        '/api/v1/barcodes/${Fixtures.barcode}',
        queryParameters: <String, String>{'company': 'mm'},
      ),
    ).called(1);
  });

  test('resolvePrice includes unitId when provided', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => ok(Fixtures.samplePriceJson));

    await sut.resolvePrice(
      itemNumber: Fixtures.itemNumber,
      company: 'mm',
      custAccount: Fixtures.custAccount,
      priceGroup: 'RETAIL',
      unitId: 'pcs',
    );

    verify(
      () => dio.get<dynamic>(
        '/api/v1/pricing',
        queryParameters: <String, String>{
          'item': Fixtures.itemNumber,
          'company': 'mm',
          'custAccount': Fixtures.custAccount,
          'priceGroup': 'RETAIL',
          'unitId': 'pcs',
        },
      ),
    ).called(1);
  });

  test('getOnHand builds inventory query', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => ok(Fixtures.sampleInventoryJson));

    final onHand = await sut.getOnHand(
      itemNumber: Fixtures.itemNumber,
      warehouse: Fixtures.warehouse,
      company: 'mm',
    );
    expect(onHand.availableSalesQuantity, 25);

    verify(
      () => dio.get<dynamic>(
        '/api/v1/inventory',
        queryParameters: <String, String>{
          'item': Fixtures.itemNumber,
          'warehouse': Fixtures.warehouse,
          'company': 'mm',
        },
      ),
    ).called(1);
  });

  test('submitFullLine posts body with company/item/qty', () async {
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => ok(<String, dynamic>{
        'success': true,
        'jobId': 'j1',
        'item': Fixtures.sampleLineItemJson,
      }),
    );

    await sut.submitFullLine(
      salesId: Fixtures.salesId,
      company: 'mm',
      itemNumber: Fixtures.itemNumber,
      quantity: 2,
    );

    verify(
      () => dio.post<dynamic>(
        '/api/v1/sales-orders/${Fixtures.salesId}/lines/full',
        data: <String, Object>{
          'company': 'mm',
          'itemNumber': Fixtures.itemNumber,
          'quantity': 2,
        },
      ),
    ).called(1);
  });

  test('submitQuickBatch posts company and lines', () async {
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => ok(<String, dynamic>{
        'success': true,
        'jobId': 'j2',
        'items': <Map<String, dynamic>>[Fixtures.sampleLineItemJson],
      }),
    );

    final List<Map<String, Object>> lines = <Map<String, Object>>[
      <String, Object>{'barcode': Fixtures.barcode, 'quantity': 1},
    ];

    await sut.submitQuickBatch(
      salesId: Fixtures.salesId,
      company: 'mm',
      lines: lines,
    );

    verify(
      () => dio.post<dynamic>(
        '/api/v1/sales-orders/${Fixtures.salesId}/lines/quick',
        data: <String, Object>{'company': 'mm', 'lines': lines},
      ),
    ).called(1);
  });
}
