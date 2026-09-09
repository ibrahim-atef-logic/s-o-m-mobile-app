import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/failed_line_model.dart';
import '../models/line_submit_result_model.dart';

/// Shared envelope helpers for [CatalogRemoteDataSourceImpl].
abstract final class CatalogRemoteParse {
  /// Second scan of the same item adds qty instead of 409 fail-fast.
  static const String ifExistsAdd = 'add';

  static Map<String, dynamic> dataMap(Object? body) =>
      (body as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  /// Old 422 nested job failures (NO_PRICE, NO_STOCK) still arrive this way.
  static LineSubmitResultModel? tryParseSubmit(DioException e) {
    if (e.response?.statusCode != 422) return null;
    final Object? raw = e.response?.data;
    if (raw is! Map<String, dynamic>) return null;
    final Object? data = raw['data'];
    if (data is! Map<String, dynamic>) return null;
    return LineSubmitResultModel.fromJson(data);
  }

  static Map<String, Object> itemPriceBody({
    required String company,
    required String itemId,
    required String salesUnitId,
    String? warehouseId,
    int? channelRecId,
  }) {
    final String trimmedItemId = itemId.trim();
    final String trimmedUnit = salesUnitId.trim();
    final Map<String, Object> body = <String, Object>{
      'company': company.trim(),
      'itemId': trimmedItemId,
      'salesUnitId': trimmedUnit,
    };
    final String warehouse = warehouseId?.trim() ?? '';
    if (warehouse.isNotEmpty) {
      body['warehouseId'] = warehouse;
    }
    if (channelRecId != null) {
      body['channelRecId'] = channelRecId;
    }
    assert(() {
      _logItemPriceIds(itemId: trimmedItemId, salesUnitId: trimmedUnit);
      return true;
    }());
    return body;
  }

  /// Debug-only: exact itemId / salesUnitId sent to POST /item-price.
  static void _logItemPriceIds({
    required String itemId,
    required String salesUnitId,
  }) {
    developer.log(
      'itemId="$itemId" len=${itemId.length} codes=${itemId.codeUnits} '
      'salesUnitId="$salesUnitId" len=${salesUnitId.length} '
      'codes=${salesUnitId.codeUnits}',
      name: 'item-price',
    );
  }

  static Exception mapDio(DioException e) {
    final Object? err = e.error;
    if (err is Exception) return err;
    return ServerException(e.message ?? 'Server error');
  }

  /// Unwraps `GET .../failed-lines` `data[]`.
  static List<FailedLineModel> failedLines(Object? body) {
    final Object? data = (body as Map<String, dynamic>)['data'];
    if (data is! List<dynamic>) return <FailedLineModel>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(FailedLineModel.fromJson)
        .toList();
  }
}
