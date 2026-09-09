@Tags(<String>['e2e'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import 'live_api_helpers.dart';

/// Live checks for item lookup, barcode 404, and DELETE line (404 only).
void main() {
  late LiveApiClient client;

  Future<void> login() async {
    Response<dynamic> res = await client.loginOnce();
    if (res.statusCode != 200) {
      res = await client.loginOnce(passwordOverride: '123');
    }
    expect(res.statusCode, 200, reason: 'login with 1234 or 123');
  }

  Map<String, dynamic> errorOf(Response<dynamic> res) {
    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    return body['error'] as Map<String, dynamic>;
  }

  setUpAll(() {
    client = LiveApiClient();
  });

  test('E2E-S1 item number lookup matches barcode BG410.003', () async {
    await login();
    final Response<dynamic> byItem = await client.dio.get<dynamic>(
      '/api/v1/items/${Fixtures.itemNumber}',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(byItem.statusCode, 200);
    final Map<String, dynamic> item =
        (byItem.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    expect('${item['itemNumber']}'.trim(), Fixtures.itemNumber);

    final Response<dynamic> byBarcode = await client.dio.get<dynamic>(
      '/api/v1/barcodes/${Fixtures.barcode}',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(byBarcode.statusCode, 200);
    final Map<String, dynamic> barcode =
        (byBarcode.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    expect('${barcode['itemNumber']}'.trim(), Fixtures.itemNumber);
  });

  test('E2E-S2 unknown barcode => BARCODE_NOT_FOUND', () async {
    await login();
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/barcodes/${Fixtures.unknownBarcode}',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 404);
    expect('${errorOf(res)['code']}', 'BARCODE_NOT_FOUND');
  });

  test('E2E-S3 unknown item => ITEM_NOT_FOUND', () async {
    await login();
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/items/NO-SUCH-ITEM',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 404);
    expect('${errorOf(res)['code']}', 'ITEM_NOT_FOUND');
  });

  test('E2E-S4 company=logic-trial => FORBIDDEN_COMPANY', () async {
    await login();
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/items/${Fixtures.itemNumber}',
      queryParameters: <String, String>{'company': Fixtures.loginCompany},
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 403);
    expect('${errorOf(res)['code']}', 'FORBIDDEN_COMPANY');
  });

  test('E2E-S5 DELETE missing RecId => LINE_NOT_FOUND', () async {
    await login();
    final Response<dynamic> res = await client.dio.delete<dynamic>(
      '/api/v1/sales-orders/${Fixtures.salesId}/lines/1',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
      options: Options(headers: client.authHeader()),
    );
    expect(res.statusCode, 404);
    expect('${errorOf(res)['code']}', 'LINE_NOT_FOUND');
  });
}
