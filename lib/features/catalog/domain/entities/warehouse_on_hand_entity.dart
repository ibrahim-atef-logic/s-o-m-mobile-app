import 'package:equatable/equatable.dart';

class WarehouseOnHandEntity extends Equatable {
  const WarehouseOnHandEntity({
    required this.itemNumber,
    required this.warehouseId,
    required this.availableSalesQuantity,
    required this.availableOnHandQuantity,
    required this.unit,
    required this.productName,
  });

  final String itemNumber;
  final String warehouseId;
  final double availableSalesQuantity;
  final double availableOnHandQuantity;
  final String unit;
  final String productName;

  @override
  List<Object?> get props => <Object?>[
    itemNumber,
    warehouseId,
    availableSalesQuantity,
    availableOnHandQuantity,
    unit,
    productName,
  ];
}
