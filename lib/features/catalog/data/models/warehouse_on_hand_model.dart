import '../../../../core/utils/json_string.dart';
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
      itemNumber: JsonString.trim(json['itemNumber']),
      warehouseId: JsonString.trim(json['warehouseId']),
      availableSalesQuantity:
          (json['availableSalesQuantity'] as num?)?.toDouble() ?? 0,
      availableOnHandQuantity:
          (json['availableOnHandQuantity'] as num?)?.toDouble() ?? 0,
      unit: JsonString.trim(json['unit']),
      productName: JsonString.trim(json['productName']),
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
