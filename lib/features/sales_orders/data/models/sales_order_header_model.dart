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
    this.createdDateTime,
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
  final String? createdDateTime;

  factory SalesOrderHeaderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderHeaderModel(
      salesId: json['salesId'] as String,
      custAccount: json['custAccount'] as String? ?? '',
      salesName: json['salesName'] as String? ?? '',
      dataArea: json['dataArea'] as String? ?? '',
      priceGroupId: json['priceGroupId'] as String? ?? '',
      inventLocationId: json['inventLocationId'] as String? ?? '',
      inventSiteId: json['inventSiteId'] as String? ?? '',
      salesStatus: json['salesStatus'] as String? ?? '',
      documentStatus: json['documentStatus'] as String? ?? '',
      createdDateTime: json['createdDateTime'] as String?,
    );
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
    createdDateTime: createdDateTime,
  );
}
