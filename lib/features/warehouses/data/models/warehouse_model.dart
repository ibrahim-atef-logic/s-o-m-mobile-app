import '../../../../core/utils/json_map.dart';
import '../../domain/entities/warehouse_entity.dart';

class WarehouseModel {
  const WarehouseModel({
    required this.dataAreaId,
    required this.inventLocationId,
    required this.name,
    this.inventSiteId,
    this.inventLocationType,
  });

  final String dataAreaId;
  final String inventLocationId;
  final String name;
  final String? inventSiteId;
  final String? inventLocationType;

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    final String code = JsonMap.stringAny(json, <String>[
      'inventLocationId',
      'InventLocationId',
      'warehouse',
      'warehouseId',
    ]);
    final String label = JsonMap.stringAny(json, <String>[
      'name',
      'Name',
      'warehouseName',
    ]);
    return WarehouseModel(
      dataAreaId: JsonMap.stringAny(json, <String>['dataAreaId', 'company']),
      inventLocationId: code,
      name: label.isEmpty ? code : label,
      inventSiteId: JsonMap.stringOrNull(json, 'inventSiteId'),
      inventLocationType: JsonMap.stringOrNull(json, 'inventLocationType'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'dataAreaId': dataAreaId,
    'inventLocationId': inventLocationId,
    'name': name,
    'inventSiteId': inventSiteId,
    'inventLocationType': inventLocationType,
  };

  WarehouseEntity toEntity() => WarehouseEntity(
    dataAreaId: dataAreaId,
    inventLocationId: inventLocationId,
    name: name,
    inventSiteId: inventSiteId,
    inventLocationType: inventLocationType,
  );
}
