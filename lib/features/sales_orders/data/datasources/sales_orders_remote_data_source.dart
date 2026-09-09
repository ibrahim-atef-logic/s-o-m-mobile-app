import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_map.dart';
import '../models/created_order_model.dart';
import '../models/sales_order_header_model.dart';
import '../models/sales_order_line_model.dart';

abstract class SalesOrdersRemoteDataSource {
  Future<List<SalesOrderHeaderModel>> getMyOrders({required String company});

  Future<SalesOrderHeaderModel> getOrder({
    required String salesId,
    required String company,
  });

  Future<List<SalesOrderLineModel>> getOrderLines({
    required String salesId,
    required String company,
    int top,
    int skip,
  });

  Future<void> deleteOrderLine({
    required String salesId,
    required String company,
    required int recordId,
  });

  Future<SalesOrderHeaderModel> refreshOrder({
    required String salesId,
    required String company,
  });

  /// The sales taker comes from the JWT, so it is never sent in the body.
  Future<CreatedOrderModel> createOrder({
    required String company,
    required String custAccount,
    String? inventLocationId,
    String? inventSiteId,
    String? currencyCode,
  });
}

class SalesOrdersRemoteDataSourceImpl implements SalesOrdersRemoteDataSource {
  SalesOrdersRemoteDataSourceImpl(this._dio);

  static const int maxLineTop = 200;
  static const int defaultLineTop = 200;

  final Dio _dio;

  @override
  Future<List<SalesOrderHeaderModel>> getMyOrders({
    required String company,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/sales-orders',
        queryParameters: <String, String>{'company': company},
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final List<dynamic> data = body['data'] as List<dynamic>;
      return data
          .map(
            (dynamic e) =>
                SalesOrderHeaderModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<SalesOrderHeaderModel> getOrder({
    required String salesId,
    required String company,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/sales-orders/$salesId',
        queryParameters: <String, String>{'company': company},
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return SalesOrderHeaderModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<SalesOrderHeaderModel> refreshOrder({
    required String salesId,
    required String company,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/sales-orders/$salesId/refresh',
        queryParameters: <String, String>{'company': company},
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return SalesOrderHeaderModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Fall back to GET if refresh alias is unavailable.
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        return getOrder(salesId: salesId, company: company);
      }
      throw _map(e);
    }
  }

  @override
  Future<List<SalesOrderLineModel>> getOrderLines({
    required String salesId,
    required String company,
    int top = defaultLineTop,
    int skip = 0,
  }) async {
    final int safeTop = top.clamp(1, maxLineTop);
    final int safeSkip = skip < 0 ? 0 : skip;
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/sales-orders/$salesId/lines',
        queryParameters: <String, Object>{
          'company': company,
          'top': safeTop,
          'skip': safeSkip,
        },
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return _parseLines(body['data']);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> deleteOrderLine({
    required String salesId,
    required String company,
    required int recordId,
  }) async {
    try {
      await _dio.delete<dynamic>(
        '/api/v1/sales-orders/$salesId/lines/$recordId',
        queryParameters: <String, String>{'company': company},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<CreatedOrderModel> createOrder({
    required String company,
    required String custAccount,
    String? inventLocationId,
    String? inventSiteId,
    String? currencyCode,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/sales-orders',
        data: <String, String>{
          'company': company.trim(),
          'custAccount': custAccount.trim(),
          if (_has(inventLocationId))
            'inventLocationId': inventLocationId!.trim(),
          if (_has(inventSiteId)) 'inventSiteId': inventSiteId!.trim(),
          if (_has(currencyCode)) 'currencyCode': currencyCode!.trim(),
        },
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      return CreatedOrderModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  List<SalesOrderLineModel> _parseLines(Object? data) {
    if (data is List<dynamic>) {
      return <SalesOrderLineModel>[
        for (final Object? row in data)
          if (row is Map)
            SalesOrderLineModel.fromJson(Map<String, dynamic>.from(row)),
      ];
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? items = JsonMap.value(map, 'items');
      if (items is List<dynamic>) {
        return _parseLines(items);
      }
    }
    return const <SalesOrderLineModel>[];
  }

  bool _has(String? value) => value != null && value.trim().isNotEmpty;

  Exception _map(DioException e) {
    final Object? err = e.error;
    if (err is Exception) {
      return err;
    }
    return ServerException(e.message ?? 'Server error');
  }
}
