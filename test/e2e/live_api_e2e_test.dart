@Tags(<String>['e2e'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/full_add/domain/full_add_qty_rules.dart';

import '../helpers/fixtures.dart';
import 'live_api_helpers.dart';

void main() {
  late LiveApiClient client;
  Map<String, dynamic>? capturedHeader;

  setUpAll(() {
    client = LiveApiClient();
  });

  test('E2E-01 health ok=true dynamicsMode live', () async {
    final Response<dynamic> res = await client.dio.get<dynamic>('/health');
    expect(res.statusCode, 200);
    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    expect(body['ok'], isTrue);
    expect('${body['dynamicsMode']}'.toLowerCase(), contains('live'));
  });

  test(
    'E2E-02 login success caches activation user (activeCompany=mm)',
    () async {
      final Response<dynamic> res = await client.loginOnce();
      expect(res.statusCode, 200);
      final Map<String, dynamic> data =
          (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      expect(data['accessToken'], isA<String>());
      expect(data['refreshToken'], isA<String>());
      expect((data['accessToken'] as String).isNotEmpty, isTrue);
      final Map<String, dynamic> user = data['user'] as Map<String, dynamic>;
      expect('${user['personnelNumber']}', Fixtures.personnelNumber);
      expect('${user['activeCompany']}'.toLowerCase(), 'mm');
      expect('${user['activeWarehouse']}', Fixtures.warehouse);
      expect('${user['defaultCustAccount']}', '10-10002');
      expect('${user['retailChannelId']}', '912');
      // Present once the gateway maps D365 RetailChannelName.
      final Object? channelName = user['retailChannelName'];
      if (channelName != null && '$channelName'.trim().isNotEmpty) {
        expect('$channelName'.trim(), isNotEmpty);
      }
      expect('${user['currency']}', 'SAR');
    },
  );

  test('E2E-03 wrong password fails', () async {
    final Response<dynamic> res = await client.loginOnce(
      passwordOverride: 'wrong-pass',
    );
    expect(res.statusCode, isNot(200));
    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    expect(body['success'], isFalse);
  });

  test('E2E-04 me with bearer => 1006', () async {
    await client.loginOnce();
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/auth/me',
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 200);
    final Map<String, dynamic> data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    expect('${data['personnelNumber']}', Fixtures.personnelNumber);
  });

  test('E2E-05 sales-orders?company=mm includes MM-245265', () async {
    await client.loginOnce();
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/sales-orders',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 200);
    final List<dynamic> data =
        (res.data as Map<String, dynamic>)['data'] as List<dynamic>;
    final Map<String, dynamic>? header = data
        .whereType<Map<String, dynamic>>()
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (Map<String, dynamic>? o) => o?['salesId'] == Fixtures.salesId,
          orElse: () => null,
        );
    expect(header, isNotNull);
    capturedHeader = header;
  });

  test('E2E-06 get order + lines', () async {
    await client.loginOnce();
    final Response<dynamic> orderRes = await client.dio.get<dynamic>(
      '/api/v1/sales-orders/${Fixtures.salesId}',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(orderRes.statusCode, 200);

    final Response<dynamic> linesRes = await client.dio.get<dynamic>(
      '/api/v1/sales-orders/${Fixtures.salesId}/lines',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(linesRes.statusCode, 200);
    expect(
      (linesRes.data as Map<String, dynamic>)['data'],
      isA<List<dynamic>>(),
    );
  });

  test('E2E-07 barcode trim equals BG410.003', () async {
    await client.loginOnce();
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/barcodes/${Fixtures.barcode}',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 200);
    final Map<String, dynamic> data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    expect('${data['itemNumber']}'.trim(), Fixtures.itemNumber);
  });

  test('E2E-07b unknown barcode => BARCODE_NOT_FOUND', () async {
    await client.loginOnce();
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/barcodes/${Fixtures.unknownBarcode}',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 404);
    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    expect(body['success'], isFalse);
    final Map<String, dynamic> error = body['error'] as Map<String, dynamic>;
    expect('${error['code']}', 'BARCODE_NOT_FOUND');
  });

  test('E2E-08 item-price returns finalPrice for fixture', () async {
    await client.loginOnce();
    final Response<dynamic> barcodeRes = await client.dio.get<dynamic>(
      '/api/v1/barcodes/${Fixtures.barcode}',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    final Map<String, dynamic> barcode =
        (barcodeRes.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>;
    final String unitId = '${barcode['unitId'] ?? ''}'.trim();
    expect(unitId, isNotEmpty);

    final Response<dynamic> loginUser = await client.dio.get<dynamic>(
      '/api/v1/auth/me',
      options: Options(headers: client.authHeader()),
    );
    final Map<String, dynamic> user =
        (loginUser.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>;
    final Object? channelRecId = user['retailChannelTableRecId'];
    final String warehouse = '${user['activeWarehouse'] ?? Fixtures.warehouse}'
        .trim();

    final Response<dynamic> res = await client.dio.post<dynamic>(
      '/api/v1/item-price',
      data: <String, Object?>{
        'company': LiveApiClient.legalEntity,
        'itemId': Fixtures.itemNumber,
        'salesUnitId': unitId,
        if (warehouse.isNotEmpty) 'warehouseId': warehouse,
        if (channelRecId is num) 'channelRecId': channelRecId.toInt(),
      },
      options: Options(headers: client.authHeader()),
    );

    expect(res.statusCode, 200);
    final Map<String, dynamic> data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    expect('${data['itemId']}'.trim(), Fixtures.itemNumber);
    expect(data['found'], isTrue);
    expect(data['finalPrice'], isA<num>());
    expect('${data['currency']}'.trim(), isNotEmpty);
  });

  test('E2E-09 inventory available for MMS000WH', () async {
    await client.loginOnce();
    final Map<String, dynamic> header =
        capturedHeader ?? Fixtures.sampleOrderHeaderJson;
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/inventory',
      queryParameters: <String, String>{
        'item': Fixtures.itemNumber,
        'warehouse': '${header['inventLocationId']}',
        'company': LiveApiClient.legalEntity,
      },
      options: Options(headers: client.authHeader()),
    );

    expect(res.statusCode, 200);
    final Map<String, dynamic> data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    expect('${data['warehouseId']}'.trim(), Fixtures.warehouse);
    expect((data['availableSalesQuantity'] as num) > 0, isTrue);
    expect((data['availableOnHandQuantity'] as num) > 0, isTrue);
  });

  test('E2E-10 FullAddQtyRules exceedsAvailable huge qty', () {
    expect(
      FullAddQtyRules.exceedsAvailable(
        quantity: 999999,
        availableSalesQuantity: 24874,
      ),
      isTrue,
    );
  });

  test('E2E-11 quick POST skipped unless ENABLE_WRITE_E2E', () async {
    if (!LiveApiClient.enableWrite) {
      return;
    }
    await client.loginOnce();
    final Response<dynamic> res = await client.dio.post<dynamic>(
      '/api/v1/sales-orders/${Fixtures.salesId}/lines/quick',
      data: <String, Object>{
        'company': LiveApiClient.legalEntity,
        'lines': <Map<String, Object>>[
          <String, Object>{'barcode': Fixtures.barcode, 'quantity': 1},
        ],
      },
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, anyOf(200, 422));
  });

  test('E2E-12 sales-orders without token => 401', () async {
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/sales-orders',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
    );
    expect(res.statusCode, 401);
  });
}
