import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/price_info_model.dart';
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
        '/api/v1/barcodes/${Uri.encodeComponent(Fixtures.barcode)}',
        queryParameters: <String, String>{'company': 'mm'},
      ),
    ).called(1);
  });

  test('lookupItem builds items path and company query', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => ok(Fixtures.sampleBarcodeJson));

    final item = await sut.lookupItem(itemNumber: 'BG410.003', company: 'mm');
    expect(item.itemNumber, Fixtures.itemNumber);

    verify(
      () => dio.get<dynamic>(
        '/api/v1/items/${Uri.encodeComponent('BG410.003')}',
        queryParameters: <String, String>{'company': 'mm'},
      ),
    ).called(1);
  });

  test('lookupItem encodes internal spaces in the path', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => ok(Fixtures.sampleBarcodeJson));

    await sut.lookupItem(itemNumber: 'BG 410.003', company: 'mm');

    verify(
      () => dio.get<dynamic>(
        '/api/v1/items/${Uri.encodeComponent('BG 410.003')}',
        queryParameters: <String, String>{'company': 'mm'},
      ),
    ).called(1);
  });

  test('resolvePrice posts item-price body with optional channel', () async {
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => ok(Fixtures.samplePriceJson));

    final PriceInfoModel priced = await sut.resolvePrice(
      itemNumber: Fixtures.itemNumber,
      company: 'mm',
      salesUnitId: 'pcs',
      warehouseId: Fixtures.warehouse,
      channelRecId: 5637152827,
    );

    expect(priced.price, 12.5);
    expect(priced.currency, 'SAR');
    expect(priced.found, isTrue);

    verify(
      () => dio.post<dynamic>(
        '/api/v1/item-price',
        data: <String, Object>{
          'company': 'mm',
          'itemId': Fixtures.itemNumber,
          'salesUnitId': 'pcs',
          'warehouseId': Fixtures.warehouse,
          'channelRecId': 5637152827,
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

  test('submitFullLine posts body with ifExists add', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
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
          'ifExists': 'add',
        },
      ),
    ).called(1);
  });

  test('submitQuickBatch posts company and lines', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
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
