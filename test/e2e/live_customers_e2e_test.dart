@Tags(<String>['e2e'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import 'live_api_helpers.dart';

/// Live, read-only checks for `GET /api/v1/customers` used by the order flow.
///
/// No order is created here: writes hit real D365 data.
void main() {
  late LiveApiClient client;
  late bool endpointDeployed;

  setUpAll(() async {
    client = LiveApiClient();
    final Response<dynamic> probe = await client.dio.get<dynamic>(
      '/api/v1/customers',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
    );
    endpointDeployed = probe.statusCode != 404;
    await client.loginOnce();
  });

  bool skipWhenMissing() {
    if (endpointDeployed) {
      return false;
    }
    markTestSkipped('GET /api/v1/customers is not deployed on the live API');
    return true;
  }

  Future<Response<dynamic>> customers({
    String? company = Fixtures.legalEntity,
    String? search,
    int? top,
    int? skip,
  }) {
    return client.dio.get<dynamic>(
      '/api/v1/customers',
      queryParameters: <String, Object>{
        'company': ?company,
        'search': ?search,
        'top': ?top,
        'skip': ?skip,
      },
      options: Options(headers: client.authHeader()),
    );
  }

  List<Map<String, dynamic>> rowsOf(Response<dynamic> res) {
    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    final Object? data = body['data'];
    if (data is List<dynamic>) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final Object? items = data['items'] ?? data['Items'];
      if (items is List<dynamic>) {
        return items.whereType<Map<String, dynamic>>().toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  int? totalCountOf(Response<dynamic> res) {
    final Object? data = (res.data as Map<String, dynamic>)['data'];
    if (data is Map<String, dynamic>) {
      final Object? total = data['totalCount'];
      if (total is int) {
        return total;
      }
    }
    return null;
  }

  test(
    'E2E-C1 browsing returns at most top rows with the fields we map',
    () async {
      if (skipWhenMissing()) return;

      final Response<dynamic> res = await customers(top: 5);
      expect(res.statusCode, 200);
      final List<Map<String, dynamic>> rows = rowsOf(res);
      expect(rows, isNotEmpty);
      expect(rows.length, lessThanOrEqualTo(5));
      for (final Map<String, dynamic> row in rows) {
        expect('${row['dataAreaId']}', Fixtures.legalEntity);
        expect('${row['customerAccount']}'.trim(), isNotEmpty);
      }
    },
  );

  test('E2E-C2 top is clamped to the backend maximum of 200', () async {
    if (skipWhenMissing()) return;

    final Response<dynamic> res = await customers(top: 9999);
    expect(res.statusCode, 200);
    expect(rowsOf(res).length, lessThanOrEqualTo(200));
  });

  test('E2E-C3 a complete account number finds that customer', () async {
    if (skipWhenMissing()) return;

    final Response<dynamic> res = await customers(search: Fixtures.custAccount);
    expect(res.statusCode, 200);
    final List<Map<String, dynamic>> rows = rowsOf(res);
    expect(rows, isNotEmpty);
    expect(
      rows.any(
        (Map<String, dynamic> r) =>
            '${r['customerAccount']}'.trim() == Fixtures.custAccount,
      ),
      isTrue,
    );
  });

  test('E2E-C4 Arabic name search returns matches with totalCount', () async {
    if (skipWhenMissing()) return;

    final Response<dynamic> res = await customers(search: 'الشرقية');
    expect(res.statusCode, 200);
    final List<Map<String, dynamic>> rows = rowsOf(res);
    expect(rows, isNotEmpty);
    expect(
      rows.any(
        (Map<String, dynamic> r) => '${r['name']}'.contains('الشرقية'),
      ),
      isTrue,
    );
    expect(totalCountOf(res), isNotNull);
    expect(totalCountOf(res)!, greaterThanOrEqualTo(rows.length));
  });

  test('E2E-C5 the login registry key is rejected as a company', () async {
    if (skipWhenMissing()) return;

    final Response<dynamic> res = await customers(
      company: Fixtures.loginCompany,
    );
    expect(res.statusCode, 403);
    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    expect(
      '${(body['error'] as Map<String, dynamic>)['code']}',
      'FORBIDDEN_COMPANY',
    );
  });

  test('E2E-C6 customers without a token => 401', () async {
    if (skipWhenMissing()) return;

    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/customers',
      queryParameters: <String, String>{'company': Fixtures.legalEntity},
    );
    expect(res.statusCode, 401);
  });
}
