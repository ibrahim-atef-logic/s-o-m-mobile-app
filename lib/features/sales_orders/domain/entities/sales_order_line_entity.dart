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
  });

  final int recordId;
  final String salesId;
  final String itemId;
  final String productName;
  final num salesQty;
  final String salesUnit;
  final num lineNum;
  final String dataArea;

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
  ];
}
