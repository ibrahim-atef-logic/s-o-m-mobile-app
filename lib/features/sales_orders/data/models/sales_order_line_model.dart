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
  });

  final int recordId;
  final String salesId;
  final String itemId;
  final String productName;
  final num salesQty;
  final String salesUnit;
  final num lineNum;
  final String dataArea;

  factory SalesOrderLineModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderLineModel(
      recordId: (json['recordId'] as num).toInt(),
      salesId: json['salesId'] as String,
      itemId: json['itemId'] as String,
      productName: json['productName'] as String? ?? '',
      salesQty: json['salesQty'] as num? ?? 0,
      salesUnit: json['salesUnit'] as String? ?? '',
      lineNum: json['lineNum'] as num? ?? 0,
      dataArea: json['dataArea'] as String? ?? '',
    );
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
  );
}
