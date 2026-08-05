import 'package:equatable/equatable.dart';

class LineItemResultEntity extends Equatable {
  const LineItemResultEntity({
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

  bool get isFailed => status == 'failed';
  bool get isSynced => status == 'synced';

  @override
  List<Object?> get props => <Object?>[
    id,
    barcode,
    itemNumber,
    quantity,
    status,
    commentAr,
    commentEn,
    price,
    unitId,
    availableQty,
  ];
}
