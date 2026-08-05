import 'package:equatable/equatable.dart';

class FullCartItemEntity extends Equatable {
  const FullCartItemEntity({
    required this.barcode,
    required this.itemNumber,
    required this.productName,
    required this.quantity,
    this.price,
    this.unitId,
  });

  final String barcode;
  final String itemNumber;
  final String productName;
  final num quantity;
  final double? price;
  final String? unitId;

  @override
  List<Object?> get props => <Object?>[
    barcode,
    itemNumber,
    productName,
    quantity,
    price,
    unitId,
  ];
}
