import '../../../../core/utils/json_string.dart';
import '../../domain/entities/barcode_item_entity.dart';

class BarcodeItemModel {
  const BarcodeItemModel({
    required this.barcode,
    required this.itemNumber,
    required this.productName,
    required this.productDescription,
    required this.unitId,
    required this.dataArea,
  });

  final String barcode;
  final String itemNumber;
  final String productName;
  final String productDescription;
  final String unitId;
  final String dataArea;

  factory BarcodeItemModel.fromJson(Map<String, dynamic> json) {
    return BarcodeItemModel(
      barcode: JsonString.trim(json['barcode']),
      itemNumber: JsonString.trim(json['itemNumber']),
      productName: JsonString.trim(json['productName']),
      productDescription: JsonString.trim(json['productDescription']),
      unitId: JsonString.trim(json['unitId']),
      dataArea: JsonString.trim(json['dataArea']),
    );
  }

  BarcodeItemEntity toEntity() => BarcodeItemEntity(
    barcode: barcode,
    itemNumber: itemNumber,
    productName: productName,
    productDescription: productDescription,
    unitId: unitId,
    dataArea: dataArea,
  );
}
