import '../../domain/entities/price_info_entity.dart';

class PriceInfoModel {
  const PriceInfoModel({
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

  factory PriceInfoModel.fromJson(Map<String, dynamic> json) {
    return PriceInfoModel(
      itemNumber: json['itemNumber'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unitId: json['unitId'] as String? ?? '',
      customerAccountNumber: json['customerAccountNumber'] as String? ?? '',
      priceCustomerGroupCode: json['priceCustomerGroupCode'] as String? ?? '',
      dataArea: json['dataArea'] as String? ?? '',
    );
  }

  PriceInfoEntity toEntity() => PriceInfoEntity(
    itemNumber: itemNumber,
    price: price,
    unitId: unitId,
    customerAccountNumber: customerAccountNumber,
    priceCustomerGroupCode: priceCustomerGroupCode,
    dataArea: dataArea,
  );
}
