import '../../../../core/utils/json_string.dart';
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
      itemNumber: JsonString.trim(json['itemNumber']),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unitId: JsonString.trim(json['unitId']),
      customerAccountNumber: JsonString.trim(json['customerAccountNumber']),
      priceCustomerGroupCode: JsonString.trim(json['priceCustomerGroupCode']),
      dataArea: JsonString.trim(json['dataArea']),
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
