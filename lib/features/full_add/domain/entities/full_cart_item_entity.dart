import 'package:equatable/equatable.dart';

class FullCartItemEntity extends Equatable {
  const FullCartItemEntity({
    required this.barcode,
    required this.itemNumber,
    required this.productName,
    required this.quantity,
    this.price,
    this.unitId,
    this.posted = true,
  });

  final String barcode;
  final String itemNumber;
  final String productName;
  final num quantity;
  final double? price;
  final String? unitId;

  /// True after Dynamics accepted the line (auto) or after manual batch submit.
  final bool posted;

  FullCartItemEntity addingQuantity(FullCartItemEntity other) {
    return FullCartItemEntity(
      barcode: barcode,
      itemNumber: itemNumber,
      productName: productName,
      quantity: quantity + other.quantity,
      price: other.price ?? price,
      unitId: other.unitId ?? unitId,
      posted: posted && other.posted,
    );
  }

  FullCartItemEntity copyWith({bool? posted}) {
    return FullCartItemEntity(
      barcode: barcode,
      itemNumber: itemNumber,
      productName: productName,
      quantity: quantity,
      price: price,
      unitId: unitId,
      posted: posted ?? this.posted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    barcode,
    itemNumber,
    productName,
    quantity,
    price,
    unitId,
    posted,
  ];
}
