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
      barcode: json['barcode'] as String? ?? '',
      itemNumber: json['itemNumber'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productDescription: json['productDescription'] as String? ?? '',
      unitId: json['unitId'] as String? ?? '',
      dataArea: json['dataArea'] as String? ?? '',
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
