import 'package:equatable/equatable.dart';

class SalesOrderLineEntity extends Equatable {
  const SalesOrderLineEntity({
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

  /// D365 unit price. Null when API omitted the field.
  final num? unitPrice;

  /// D365 line net amount (after discounts). Prefer this over qty × unitPrice.
  final num? netAmount;

  @override
  List<Object?> get props => <Object?>[
    recordId,
    salesId,
    itemId,
    productName,
    salesQty,
    salesUnit,
    lineNum,
    dataArea,
    unitPrice,
    netAmount,
  ];
}
