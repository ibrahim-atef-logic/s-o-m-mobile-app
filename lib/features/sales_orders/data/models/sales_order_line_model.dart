import '../../../../core/utils/json_map.dart';
import '../../domain/entities/sales_order_line_entity.dart';

class SalesOrderLineModel {
  const SalesOrderLineModel({
    required this.recordId,
    required this.salesId,
    required this.itemId,
    required this.productName,
    required this.salesQty,
    required this.salesUnit,
    required this.lineNum,
    required this.dataArea,
    this.unitPrice,
    this.netAmount,
  });

  final int recordId;
  final String salesId;
  final String itemId;
  final String productName;
  final num salesQty;
  final String salesUnit;
  final num lineNum;
  final String dataArea;
  final num? unitPrice;
  final num? netAmount;

  factory SalesOrderLineModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderLineModel(
      recordId: JsonMap.integer(json, 'recordId'),
      salesId: JsonMap.string(json, 'salesId'),
      itemId: JsonMap.stringAny(json, <String>['itemId', 'itemNumber']),
      productName: JsonMap.string(json, 'productName'),
      salesQty: _asNum(JsonMap.value(json, 'salesQty')) ?? 0,
      salesUnit: JsonMap.string(json, 'salesUnit'),
      lineNum: _asNum(JsonMap.value(json, 'lineNum')) ?? 0,
      dataArea: JsonMap.stringAny(json, <String>['dataArea', 'company']),
      unitPrice: _asNum(JsonMap.value(json, 'unitPrice')),
      netAmount: _asNum(JsonMap.value(json, 'netAmount')),
    );
  }

  static num? _asNum(Object? raw) {
    if (raw is num) {
      return raw;
    }
    if (raw is String) {
      return num.tryParse(raw.trim());
    }
    return null;
  }

  SalesOrderLineEntity toEntity() => SalesOrderLineEntity(
    recordId: recordId,
    salesId: salesId,
    itemId: itemId,
    productName: productName,
    salesQty: salesQty,
    salesUnit: salesUnit,
    lineNum: lineNum,
    dataArea: dataArea,
    unitPrice: unitPrice,
    netAmount: netAmount,
  );
}
