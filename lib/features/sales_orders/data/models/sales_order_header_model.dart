import '../../../../core/utils/json_map.dart';
import '../../domain/entities/sales_order_header_entity.dart';

class SalesOrderHeaderModel {
  const SalesOrderHeaderModel({
    required this.salesId,
    required this.custAccount,
    required this.salesName,
    required this.dataArea,
    required this.priceGroupId,
    required this.inventLocationId,
    required this.inventSiteId,
    required this.salesStatus,
    required this.documentStatus,
    this.custDisplayName,
    this.inventLocationName,
    this.salesStatusLabel,
    this.documentStatusLabel,
    this.createdDateTime,
    this.lineCount,
    this.orderTotal,
  });

  final String salesId;
  final String custAccount;
  final String salesName;
  final String dataArea;
  final String priceGroupId;
  final String inventLocationId;
  final String inventSiteId;
  final String salesStatus;
  final String documentStatus;
  final String? custDisplayName;
  final String? inventLocationName;
  final String? salesStatusLabel;
  final String? documentStatusLabel;
  final String? createdDateTime;
  final int? lineCount;
  final num? orderTotal;

  factory SalesOrderHeaderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderHeaderModel(
      salesId: JsonMap.string(json, 'salesId'),
      custAccount: JsonMap.string(json, 'custAccount'),
      salesName: JsonMap.string(json, 'salesName'),
      dataArea: JsonMap.string(json, 'dataArea'),
      priceGroupId: JsonMap.string(json, 'priceGroupId'),
      inventLocationId: JsonMap.string(json, 'inventLocationId'),
      inventSiteId: JsonMap.string(json, 'inventSiteId'),
      salesStatus: JsonMap.string(json, 'salesStatus'),
      documentStatus: JsonMap.string(json, 'documentStatus'),
      custDisplayName: JsonMap.stringOrNull(json, 'custDisplayName'),
      inventLocationName: JsonMap.stringOrNull(json, 'inventLocationName'),
      salesStatusLabel: JsonMap.stringOrNull(json, 'salesStatusLabel'),
      documentStatusLabel: JsonMap.stringOrNull(json, 'documentStatusLabel'),
      createdDateTime: JsonMap.stringOrNull(json, 'createdDateTime'),
      lineCount: JsonMap.integerOrNull(json, 'lineCount'),
      orderTotal: _asNum(JsonMap.value(json, 'orderTotal')),
    );
  }

  static num? _asNum(Object? value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  SalesOrderHeaderEntity toEntity() => SalesOrderHeaderEntity(
    salesId: salesId,
    custAccount: custAccount,
    salesName: salesName,
    dataArea: dataArea,
    priceGroupId: priceGroupId,
    inventLocationId: inventLocationId,
    inventSiteId: inventSiteId,
    salesStatus: salesStatus,
    documentStatus: documentStatus,
    custDisplayName: custDisplayName,
    inventLocationName: inventLocationName,
    salesStatusLabel: salesStatusLabel,
    documentStatusLabel: documentStatusLabel,
    createdDateTime: createdDateTime,
    lineCount: lineCount,
    orderTotal: orderTotal,
  );
}
