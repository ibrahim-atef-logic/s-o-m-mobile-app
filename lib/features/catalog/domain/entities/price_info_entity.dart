import 'package:equatable/equatable.dart';

class PriceInfoEntity extends Equatable {
  const PriceInfoEntity({
    required this.itemNumber,
    required this.price,
    required this.unitId,
    required this.customerAccountNumber,
    required this.priceCustomerGroupCode,
    required this.dataArea,
  });

  final String itemNumber;
  final double price;
  final String unitId;
  final String customerAccountNumber;
  final String priceCustomerGroupCode;
  final String dataArea;

  @override
  List<Object?> get props => <Object?>[
    itemNumber,
    price,
    unitId,
    customerAccountNumber,
    priceCustomerGroupCode,
    dataArea,
  ];
}
