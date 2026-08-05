import '../../domain/entities/line_item_result_entity.dart';

class LineItemResultModel {
  const LineItemResultModel({
    required this.id,
    required this.quantity,
    required this.status,
    this.barcode,
    this.itemNumber,
    this.commentAr,
    this.commentEn,
    this.price,
    this.unitId,
    this.availableQty,
  });

  final String id;
  final String? barcode;
  final String? itemNumber;
  final num quantity;
  final String status;
  final String? commentAr;
  final String? commentEn;
  final double? price;
  final String? unitId;
  final double? availableQty;

  factory LineItemResultModel.fromJson(Map<String, dynamic> json) {
    return LineItemResultModel(
      id: json['id'] as String? ?? '',
      barcode: json['barcode'] as String?,
      itemNumber: json['itemNumber'] as String?,
      quantity: json['quantity'] as num? ?? 0,
      status: json['status'] as String? ?? '',
      commentAr: json['commentAr'] as String?,
      commentEn: json['commentEn'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      unitId: json['unitId'] as String?,
      availableQty: (json['availableQty'] as num?)?.toDouble(),
    );
  }

  LineItemResultEntity toEntity() => LineItemResultEntity(
    id: id,
    barcode: barcode,
    itemNumber: itemNumber,
    quantity: quantity,
    status: status,
    commentAr: commentAr,
    commentEn: commentEn,
    price: price,
    unitId: unitId,
    availableQty: availableQty,
  );
}
