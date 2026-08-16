@Tags(<String>['e2e'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import 'live_api_helpers.dart';

/// Live checks for `GET /api/v1/warehouses` used by the warehouse picker.
void main() {
  late LiveApiClient client;
  late bool endpointDeployed;

  setUpAll(() async {
    client = LiveApiClient();
    // Unauthenticated probe: an existing route answers 401, a missing one 404.
    final Response<dynamic> probe = await client.dio.get<dynamic>(
      '/api/v1/warehouses',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
    );
    endpointDeployed = probe.statusCode != 404;
  });

  bool skipWhenMissing() {
    if (endpointDeployed) {
      return false;
    }
    markTestSkipped('GET /api/v1/warehouses is not deployed on the live API');
    return true;
  }

  Future<Response<dynamic>> warehouses(String? company) {
    final Map<String, String> query = <String, String>{};
    if (company != null) {
      query['company'] = company;
    }
    return client.dio.get<dynamic>(
      '/api/v1/warehouses',
      queryParameters: query,
      options: Options(headers: client.authHeader()),
    );
  }

  Future<Map<String, dynamic>> loginUser(String personnelNumber) async {
    final Response<dynamic> res = await client.loginOnce(
      personnelOverride: personnelNumber,
    );
    expect(res.statusCode, 200, reason: 'login $personnelNumber');
    final Map<String, dynamic> data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return data['user'] as Map<String, dynamic>;
  }

  test('E2E-W1 1006 has a warehouse and the list is Standard only', () async {
    if (skipWhenMissing()) return;
    final Map<String, dynamic> user = await loginUser(Fixtures.personnelNumber);
    expect('${user['activeWarehouse']}', Fixtures.warehouse);
    expect(user['needsWarehouseSelection'], isFalse);

    final Response<dynamic> res = await warehouses('${user['activeCompany']}');
    expect(res.statusCode, 200);
    final List<dynamic> data =
        (res.data as Map<String, dynamic>)['data'] as List<dynamic>;
    final List<Map<String, dynamic>> rows = data
        .whereType<Map<String, dynamic>>()
        .toList();
    expect(rows, isNotEmpty);
    for (final Map<String, dynamic> row in rows) {
      expect('${row['inventLocationType']}', 'Standard');
      expect('${row['inventLocationId']}'.trim(), isNotEmpty);
    }
    expect(
      rows.any(
        (Map<String, dynamic> r) =>
            '${r['inventLocationId']}'.trim() == Fixtures.warehouse,
      ),
      isTrue,
    );
  });

  test('E2E-W2 12344 needs the picker and its company list loads', () async {
    if (skipWhenMissing()) return;
    final Map<String, dynamic> user = await loginUser('12344');
    final String warehouse = '${user['activeWarehouse'] ?? ''}'.trim();
    expect(
      warehouse.isEmpty || user['needsWarehouseSelection'] == true,
      isTrue,
    );

    final Response<dynamic> res = await warehouses('${user['activeCompany']}');
    expect(res.statusCode, 200);
    expect((res.data as Map<String, dynamic>)['data'], isA<List<dynamic>>());
  });

  test(
    'E2E-W3 login registry key is rejected with FORBIDDEN_COMPANY',
    () async {
      if (skipWhenMissing()) return;
      await loginUser(Fixtures.personnelNumber);

      final Response<dynamic> res = await warehouses(Fixtures.loginCompany);
      expect(res.statusCode, 403);
      final Map<String, dynamic> body = res.data as Map<String, dynamic>;
      expect(body['success'], isFalse);
      expect(
        '${(body['error'] as Map<String, dynamic>)['code']}',
        'FORBIDDEN_COMPANY',
      );
    },
  );

  test('E2E-W4 missing company => VALIDATION_ERROR', () async {
    if (skipWhenMissing()) return;
    await loginUser(Fixtures.personnelNumber);

    final Response<dynamic> res = await warehouses(null);
    expect(res.statusCode, 400);
    // Model-binding failures still answer with ASP.NET ProblemDetails instead of
    // the `{ success, error }` envelope, so accept either shape for now.
    final Map<String, dynamic> body = res.data as Map<String, dynamic>;
    expect(
      body['success'] == false || body['errors'] != null,
      isTrue,
      reason: 'expected a validation payload, got $body',
    );
  });

  test('E2E-W5 warehouses without a token => 401', () async {
    if (skipWhenMissing()) return;
    final Response<dynamic> res = await client.dio.get<dynamic>(
      '/api/v1/warehouses',
      queryParameters: <String, String>{'company': LiveApiClient.legalEntity},
    );
    expect(res.statusCode, 401);
  });
}
