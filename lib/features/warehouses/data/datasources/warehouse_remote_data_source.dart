import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/warehouse_model.dart';

abstract class WarehouseRemoteDataSource {
  /// `company` must be the operating DataArea (`user.activeCompany`),
  /// never the login environment registry key.
  Future<List<WarehouseModel>> fetchWarehouses(String company);
}

class WarehouseRemoteDataSourceImpl implements WarehouseRemoteDataSource {
  WarehouseRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<WarehouseModel>> fetchWarehouses(String company) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/warehouses',
        queryParameters: <String, String>{'company': company.trim()},
      );
      final Object? body = response.data;
      if (body is! Map<String, dynamic>) {
        return <WarehouseModel>[];
      }
      final Object? data = body['data'];
      if (data is! List<dynamic>) {
        return <WarehouseModel>[];
      }
      return <WarehouseModel>[
        for (final Object? row in data)
          if (row is Map)
            WarehouseModel.fromJson(Map<String, dynamic>.from(row)),
      ];
    } on DioException catch (e) {
      final Object? error = e.error;
      if (error is Exception) {
        throw error;
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
