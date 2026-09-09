import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/customer_page_model.dart';

/// Server-side customer search with skip/top pagination.
abstract class CustomerRemoteDataSource {
  Future<CustomerPageModel> searchCustomers({
    required String company,
    String? search,
    int top,
    int skip,
  });
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  CustomerRemoteDataSourceImpl(this._dio);

  static const int maxTop = 100;
  static const int defaultTop = 30;

  final Dio _dio;

  @override
  Future<CustomerPageModel> searchCustomers({
    required String company,
    String? search,
    int top = defaultTop,
    int skip = 0,
  }) async {
    final String term = search?.trim() ?? '';
    final int safeTop = top.clamp(1, maxTop);
    final int safeSkip = skip < 0 ? 0 : skip;
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/customers',
        queryParameters: <String, Object>{
          'company': company.trim(),
          if (term.isNotEmpty) 'search': term,
          'top': safeTop,
          'skip': safeSkip,
        },
      );
      final Object? body = response.data;
      if (body is! Map<String, dynamic>) {
        return CustomerPageModel.fromData(
          null,
          requestedTop: safeTop,
          requestedSkip: safeSkip,
        );
      }
      return CustomerPageModel.fromData(
        body['data'],
        requestedTop: safeTop,
        requestedSkip: safeSkip,
      );
    } on DioException catch (e) {
      final Object? error = e.error;
      if (error is Exception) {
        throw error;
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
