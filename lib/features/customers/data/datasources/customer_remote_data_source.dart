import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/customer_model.dart';

/// Server-side customer search. `top` is capped at 200 by the backend.
abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> searchCustomers({
    required String company,
    String? search,
    int top,
  });
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  CustomerRemoteDataSourceImpl(this._dio);

  static const int maxTop = 200;

  final Dio _dio;

  @override
  Future<List<CustomerModel>> searchCustomers({
    required String company,
    String? search,
    int top = 50,
  }) async {
    final String term = search?.trim() ?? '';
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/customers',
        queryParameters: <String, Object>{
          'company': company.trim(),
          if (term.isNotEmpty) 'search': term,
          'top': top.clamp(1, maxTop),
        },
      );
      final Object? body = response.data;
      if (body is! Map<String, dynamic>) {
        return <CustomerModel>[];
      }
      final Object? data = body['data'];
      if (data is! List<dynamic>) {
        return <CustomerModel>[];
      }
      return <CustomerModel>[
        for (final Object? row in data)
          if (row is Map)
            CustomerModel.fromJson(Map<String, dynamic>.from(row)),
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
