import 'package:equatable/equatable.dart';

import 'sales_order_header_entity.dart';

/// Result of `POST /api/v1/sales-orders`.
class CreatedOrderEntity extends Equatable {
  const CreatedOrderEntity({
    required this.salesOrderNumber,
    required this.dataAreaId,
    required this.custAccount,
    required this.inventLocationId,
    this.inventSiteId,
    this.currencyCode,
    this.orderTakerPersonnelNumber,
  });

  final String salesOrderNumber;
  final String dataAreaId;
  final String custAccount;
  final String inventLocationId;
  final String? inventSiteId;
  final String? currencyCode;
  final String? orderTakerPersonnelNumber;

  /// Minimal header so the order screens work before D365 is re-read.
  SalesOrderHeaderEntity toHeader({String salesName = ''}) {
    return SalesOrderHeaderEntity(
      salesId: salesOrderNumber,
      custAccount: custAccount,
      salesName: salesName,
      dataArea: dataAreaId,
      priceGroupId: '',
      inventLocationId: inventLocationId,
      inventSiteId: inventSiteId ?? '',
      salesStatus: '',
      documentStatus: '',
    );
  }

  @override
  List<Object?> get props => <Object?>[
    salesOrderNumber,
    dataAreaId,
    custAccount,
    inventLocationId,
    inventSiteId,
    currencyCode,
    orderTakerPersonnelNumber,
  ];
}
