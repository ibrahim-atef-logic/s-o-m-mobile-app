import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'fixtures.dart';

/// In-memory .NET API for the activation session cycle unit test.
class ActivationCycleAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final String path = options.path;
    final String method = options.method.toUpperCase();
    final Map<String, dynamic> body = _body(options.data);

    if (method == 'POST' && path.endsWith('/auth/login')) {
      return _login(body);
    }
    if (method == 'POST' && path.endsWith('/auth/refresh')) {
      return _ok(Fixtures.sampleLoginDataJson);
    }
    if (method == 'GET' && path.endsWith('/auth/me')) {
      return _ok(Fixtures.sampleActivationUser1006);
    }
    if (method == 'POST' && path.endsWith('/auth/change-password')) {
      return _ok(<String, dynamic>{
        'isSuccess': true,
        'message': 'Password changed',
        'activationRecId': 5637144576,
      });
    }
    if (method == 'POST' && path.endsWith('/auth/logout')) {
      return _ok(<String, dynamic>{});
    }
    if (method == 'GET' && path.contains('/warehouses')) {
      return _warehouses(options.queryParameters['company']);
    }
    if (method == 'GET' && path.contains('/customers')) {
      return _customers(options.queryParameters);
    }
    if (method == 'POST' && path.endsWith('/sales-orders')) {
      return _createOrder(body);
    }
    if (method == 'GET' && path.contains('/barcodes/')) {
      if (path.contains(Fixtures.unknownBarcode)) {
        return _err(404, 'BARCODE_NOT_FOUND', 'Barcode not found');
      }
      return _ok(Fixtures.sampleBarcodeJson);
    }
    if (method == 'GET' && path.contains('/pricing')) {
      return _ok(Fixtures.samplePriceJson);
    }
    if (method == 'GET' && path.contains('/inventory')) {
      return _ok(Fixtures.sampleInventoryJson);
    }
    if (method == 'POST' && path.contains('/lines/full')) {
      return _ok(<String, dynamic>{
        'success': true,
        'jobId': 'job-full',
        'item': Fixtures.sampleLineItemJson,
      });
    }
    if (method == 'POST' && path.contains('/lines/quick')) {
      return _ok(<String, dynamic>{
        'success': true,
        'jobId': 'job-quick',
        'items': <Map<String, dynamic>>[Fixtures.sampleLineItemJson],
      });
    }
    if (method == 'GET' && path.contains('/failed-lines')) {
      return _ok(<Map<String, dynamic>>[Fixtures.sampleFailedLineJson]);
    }
    if (method == 'GET' && path.contains('/lines')) {
      return _ok(<Map<String, dynamic>>[Fixtures.sampleOrderLineJson]);
    }
    if (method == 'GET' && path.contains('/sales-orders/')) {
      return _ok(Fixtures.sampleOrderHeaderJson);
    }
    if (method == 'GET' && path.contains('/sales-orders')) {
      return _ok(<Map<String, dynamic>>[Fixtures.sampleOrderHeaderJson]);
    }
    return _err(404, 'NOT_FOUND', path);
  }

  ResponseBody _login(Map<String, dynamic> body) {
    if (body['company'] != Fixtures.loginCompany) {
      return _err(400, 'AUTH_COMPANY_UNKNOWN', 'Environment not registered');
    }
    if (body['password'] != Fixtures.password) {
      return _err(401, 'AUTH_FAILED', 'Invalid personnel or password');
    }
    if (body['personnelNumber'] == '12344') {
      return _ok(Fixtures.sampleLoginDataIncompleteJson);
    }
    if (body['personnelNumber'] == Fixtures.personnelNumber) {
      return _ok(Fixtures.sampleLoginDataJson);
    }
    return _err(401, 'AUTH_FAILED', 'Invalid personnel or password');
  }

  ResponseBody _warehouses(Object? company) {
    final String code = (company ?? '').toString().trim();
    if (code.isEmpty) {
      return _err(400, 'VALIDATION_ERROR', 'company is required');
    }
    if (code == Fixtures.loginCompany) {
      return _err(403, 'FORBIDDEN_COMPANY', 'Company not allowed for token');
    }
    if (code.toLowerCase() == 'pltr') {
      return _ok(Fixtures.samplePltrWarehousesJson);
    }
    return _ok(Fixtures.sampleWarehousesJson);
  }

  ResponseBody _customers(Map<String, dynamic> query) {
    final String company = (query['company'] ?? '').toString().trim();
    if (company.isEmpty) {
      return _err(400, 'VALIDATION_ERROR', 'company is required');
    }
    if (company == Fixtures.loginCompany) {
      return _err(403, 'FORBIDDEN_COMPANY', 'Company not allowed for token');
    }
    final String search = (query['search'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return _ok(<Map<String, dynamic>>[
      for (final Map<String, dynamic> row in Fixtures.sampleCustomersJson)
        if (search.isEmpty ||
            '${row['customerAccount']}'.toLowerCase().contains(search) ||
            '${row['name']}'.toLowerCase().contains(search))
          row,
    ]);
  }

  ResponseBody _createOrder(Map<String, dynamic> body) {
    final String company = (body['company'] ?? '').toString().trim();
    final String customer = (body['custAccount'] ?? '').toString().trim();
    final String warehouse = (body['inventLocationId'] ?? '').toString().trim();
    if (company == Fixtures.loginCompany) {
      return _err(403, 'FORBIDDEN_COMPANY', 'Company not allowed for token');
    }
    if (customer.isEmpty) {
      return _err(400, 'VALIDATION_ERROR', 'custAccount is required');
    }
    if (warehouse.isEmpty) {
      return _err(400, 'WAREHOUSE_REQUIRED', 'No warehouse for this user');
    }
    return _ok(<String, dynamic>{
      ...Fixtures.sampleCreatedOrderJson,
      'dataAreaId': company,
      'custAccount': customer,
      'inventLocationId': warehouse,
    });
  }

  Map<String, dynamic> _body(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  ResponseBody _ok(Object data) {
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'success': true, 'data': data}),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  ResponseBody _err(int status, String code, String message) {
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{
        'success': false,
        'error': <String, String>{'code': code, 'message': message},
      }),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
