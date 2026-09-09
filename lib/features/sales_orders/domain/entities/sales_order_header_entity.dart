import 'package:equatable/equatable.dart';

export 'sales_order_header_display.dart';

class SalesOrderHeaderEntity extends Equatable {
  const SalesOrderHeaderEntity({
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

  /// D365 customer display (SalesName) — prefer in summary over custAccount.
  final String? custDisplayName;

  /// Warehouse name from D365 lookup — prefer over inventLocationId in UI.
  final String? inventLocationName;

  /// Optional Arabic label from API (e.g. طلب معلق).
  final String? salesStatusLabel;

  /// Optional Arabic label from API (e.g. بدون مستند).
  final String? documentStatusLabel;
  final String? createdDateTime;
  final int? lineCount;
  final num? orderTotal;

  SalesOrderHeaderEntity copyWith({
    String? salesId,
    String? custAccount,
    String? salesName,
    String? dataArea,
    String? priceGroupId,
    String? inventLocationId,
    String? inventSiteId,
    String? salesStatus,
    String? documentStatus,
    String? custDisplayName,
    String? inventLocationName,
    String? salesStatusLabel,
    String? documentStatusLabel,
    String? createdDateTime,
    int? lineCount,
    num? orderTotal,
  }) {
    return SalesOrderHeaderEntity(
      salesId: salesId ?? this.salesId,
      custAccount: custAccount ?? this.custAccount,
      salesName: salesName ?? this.salesName,
      dataArea: dataArea ?? this.dataArea,
      priceGroupId: priceGroupId ?? this.priceGroupId,
      inventLocationId: inventLocationId ?? this.inventLocationId,
      inventSiteId: inventSiteId ?? this.inventSiteId,
      salesStatus: salesStatus ?? this.salesStatus,
      documentStatus: documentStatus ?? this.documentStatus,
      custDisplayName: custDisplayName ?? this.custDisplayName,
      inventLocationName: inventLocationName ?? this.inventLocationName,
      salesStatusLabel: salesStatusLabel ?? this.salesStatusLabel,
      documentStatusLabel: documentStatusLabel ?? this.documentStatusLabel,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      lineCount: lineCount ?? this.lineCount,
      orderTotal: orderTotal ?? this.orderTotal,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    salesId,
    custAccount,
    salesName,
    dataArea,
    priceGroupId,
    inventLocationId,
    inventSiteId,
    salesStatus,
    documentStatus,
    custDisplayName,
    inventLocationName,
    salesStatusLabel,
    documentStatusLabel,
    createdDateTime,
    lineCount,
    orderTotal,
  ];
}
