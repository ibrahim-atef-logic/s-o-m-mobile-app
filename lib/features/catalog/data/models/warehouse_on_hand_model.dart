import '../../domain/entities/warehouse_on_hand_entity.dart';

class WarehouseOnHandModel {
  const WarehouseOnHandModel({
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

  factory WarehouseOnHandModel.fromJson(Map<String, dynamic> json) {
    return WarehouseOnHandModel(
      itemNumber: json['itemNumber'] as String? ?? '',
      warehouseId: json['warehouseId'] as String? ?? '',
      availableSalesQuantity:
          (json['availableSalesQuantity'] as num?)?.toDouble() ?? 0,
      availableOnHandQuantity:
          (json['availableOnHandQuantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
    );
  }

  WarehouseOnHandEntity toEntity() => WarehouseOnHandEntity(
    itemNumber: itemNumber,
    warehouseId: warehouseId,
    availableSalesQuantity: availableSalesQuantity,
    availableOnHandQuantity: availableOnHandQuantity,
    unit: unit,
    productName: productName,
  );
}
