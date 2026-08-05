import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/barcode_item_model.dart';
import '../models/failed_line_model.dart';
import '../models/line_submit_result_model.dart';
import '../models/price_info_model.dart';
import '../models/warehouse_on_hand_model.dart';

abstract class CatalogRemoteDataSource {
  Future<BarcodeItemModel> lookupBarcode({
    required String code,
    required String company,
  });

  Future<PriceInfoModel> resolvePrice({
    required String itemNumber,
    required String company,
    required String custAccount,
    required String priceGroup,
  });

  Future<WarehouseOnHandModel> getOnHand({
    required String itemNumber,
    required String warehouse,
    required String company,
  });

  Future<LineSubmitResultModel> submitFullLine({
    required String salesId,
    required String company,
    required String itemNumber,
    required num quantity,
  });

  Future<LineSubmitResultModel> submitQuickBatch({
    required String salesId,
    required String company,
    required List<Map<String, Object>> lines,
  });

  Future<List<FailedLineModel>> getFailedLines({
    required String salesId,
    required String company,
    String? mode,
  });
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<BarcodeItemModel> lookupBarcode({
    required String code,
    required String company,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/barcodes/$code',
        queryParameters: <String, String>{'company': company},
      );
      return BarcodeItemModel.fromJson(_dataMap(response.data));
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<PriceInfoModel> resolvePrice({
    required String itemNumber,
    required String company,
    required String custAccount,
    required String priceGroup,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/pricing',
        queryParameters: <String, String>{
          'item': itemNumber,
          'company': company,
          'custAccount': custAccount,
          'priceGroup': priceGroup,
        },
      );
      return PriceInfoModel.fromJson(_dataMap(response.data));
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<WarehouseOnHandModel> getOnHand({
    required String itemNumber,
    required String warehouse,
    required String company,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/inventory',
        queryParameters: <String, String>{
          'item': itemNumber,
          'warehouse': warehouse,
          'company': company,
        },
      );
      return WarehouseOnHandModel.fromJson(_dataMap(response.data));
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<LineSubmitResultModel> submitFullLine({
    required String salesId,
    required String company,
    required String itemNumber,
    required num quantity,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/sales-orders/$salesId/lines/full',
        data: <String, Object>{
          'company': company,
          'itemNumber': itemNumber,
          'quantity': quantity,
        },
      );
      return LineSubmitResultModel.fromJson(_dataMap(response.data));
    } on DioException catch (e) {
      final LineSubmitResultModel? failed = _tryParseSubmit(e);
      if (failed != null) return failed;
      throw _map(e);
    }
  }

  @override
  Future<LineSubmitResultModel> submitQuickBatch({
    required String salesId,
    required String company,
    required List<Map<String, Object>> lines,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/sales-orders/$salesId/lines/quick',
        data: <String, Object>{'company': company, 'lines': lines},
      );
      return LineSubmitResultModel.fromJson(_dataMap(response.data));
    } on DioException catch (e) {
      final LineSubmitResultModel? failed = _tryParseSubmit(e);
      if (failed != null) return failed;
      throw _map(e);
    }
  }

  @override
  Future<List<FailedLineModel>> getFailedLines({
    required String salesId,
    required String company,
    String? mode,
  }) async {
    try {
      final Map<String, String> query = <String, String>{'company': company};
      if (mode != null && mode.isNotEmpty) {
        query['mode'] = mode;
      }
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/sales-orders/$salesId/failed-lines',
        queryParameters: query,
      );
      final Object? data = (response.data as Map<String, dynamic>)['data'];
      if (data is! List<dynamic>) return <FailedLineModel>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(FailedLineModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Map<String, dynamic> _dataMap(Object? body) =>
      (body as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  LineSubmitResultModel? _tryParseSubmit(DioException e) {
    if (e.response?.statusCode != 422) return null;
    final Object? raw = e.response?.data;
    if (raw is! Map<String, dynamic>) return null;
    final Object? data = raw['data'];
    if (data is! Map<String, dynamic>) return null;
    return LineSubmitResultModel.fromJson(data);
  }

  Exception _map(DioException e) {
    final Object? err = e.error;
    if (err is Exception) return err;
    return ServerException(e.message ?? 'Server error');
  }
}
