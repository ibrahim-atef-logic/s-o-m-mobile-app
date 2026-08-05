import 'package:equatable/equatable.dart';

class BarcodeItemEntity extends Equatable {
  const BarcodeItemEntity({
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

  @override
  List<Object?> get props => <Object?>[
    barcode,
    itemNumber,
    productName,
    productDescription,
    unitId,
    dataArea,
  ];
}
