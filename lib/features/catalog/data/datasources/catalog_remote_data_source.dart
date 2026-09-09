import 'package:dio/dio.dart';

import '../models/barcode_item_model.dart';
import '../models/failed_line_model.dart';
import '../models/line_submit_result_model.dart';
import '../models/price_info_model.dart';
import '../models/warehouse_on_hand_model.dart';
import 'catalog_remote_parse.dart';

abstract class CatalogRemoteDataSource {
  Future<BarcodeItemModel> lookupBarcode({
    required String code,
    required String company,
  });

  Future<BarcodeItemModel> lookupItem({
    required String itemNumber,
    required String company,
  });

  Future<PriceInfoModel> resolvePrice({
    required String itemNumber,
    required String company,
    required String salesUnitId,
    String? warehouseId,
    int? channelRecId,
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
        '/api/v1/barcodes/${Uri.encodeComponent(code)}',
        queryParameters: <String, String>{'company': company},
      );
      return BarcodeItemModel.fromJson(
        CatalogRemoteParse.dataMap(response.data),
      );
    } on DioException catch (e) {
      throw CatalogRemoteParse.mapDio(e);
    }
  }

  @override
  Future<BarcodeItemModel> lookupItem({
    required String itemNumber,
    required String company,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        '/api/v1/items/${Uri.encodeComponent(itemNumber)}',
        queryParameters: <String, String>{'company': company},
      );
      return BarcodeItemModel.fromJson(
        CatalogRemoteParse.dataMap(response.data),
      );
    } on DioException catch (e) {
      throw CatalogRemoteParse.mapDio(e);
    }
  }

  @override
  Future<PriceInfoModel> resolvePrice({
    required String itemNumber,
    required String company,
    required String salesUnitId,
    String? warehouseId,
    int? channelRecId,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/api/v1/item-price',
        data: CatalogRemoteParse.itemPriceBody(
          company: company,
          itemId: itemNumber,
          salesUnitId: salesUnitId,
          warehouseId: warehouseId,
          channelRecId: channelRecId,
        ),
      );
      return PriceInfoModel.fromJson(CatalogRemoteParse.dataMap(response.data));
    } on DioException catch (e) {
      throw CatalogRemoteParse.mapDio(e);
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
      return WarehouseOnHandModel.fromJson(
        CatalogRemoteParse.dataMap(response.data),
      );
    } on DioException catch (e) {
      throw CatalogRemoteParse.mapDio(e);
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
          'ifExists': CatalogRemoteParse.ifExistsAdd,
        },
      );
      return LineSubmitResultModel.fromJson(
        CatalogRemoteParse.dataMap(response.data),
      );
    } on DioException catch (e) {
      final LineSubmitResultModel? failed = CatalogRemoteParse.tryParseSubmit(
        e,
      );
      if (failed != null) return failed;
      throw CatalogRemoteParse.mapDio(e);
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
      return LineSubmitResultModel.fromJson(
        CatalogRemoteParse.dataMap(response.data),
      );
    } on DioException catch (e) {
      final LineSubmitResultModel? failed = CatalogRemoteParse.tryParseSubmit(
        e,
      );
      if (failed != null) return failed;
      throw CatalogRemoteParse.mapDio(e);
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
      return CatalogRemoteParse.failedLines(response.data);
    } on DioException catch (e) {
      throw CatalogRemoteParse.mapDio(e);
    }
  }
}
