import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
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
  Future<List<SalesOrderLineModel>> getOrderLines({
    required String salesId,
    required String company,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/sales-orders/$salesId/lines',
        queryParameters: <String, String>{'company': company},
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final List<dynamic> data = body['data'] as List<dynamic>;
      return data
          .map(
            (dynamic e) =>
                SalesOrderLineModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
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

  bool _has(String? value) => value != null && value.trim().isNotEmpty;

  Exception _map(DioException e) {
    final Object? err = e.error;
    if (err is Exception) return err;
    return ServerException(e.message ?? 'Server error');
  }
}
