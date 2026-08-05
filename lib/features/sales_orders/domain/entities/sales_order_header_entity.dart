import 'package:equatable/equatable.dart';

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
    createdDateTime,
  ];
}
