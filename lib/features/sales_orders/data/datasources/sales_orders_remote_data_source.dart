import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
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

  Exception _map(DioException e) {
    final Object? err = e.error;
    if (err is Exception) return err;
    return ServerException(e.message ?? 'Server error');
  }
}
