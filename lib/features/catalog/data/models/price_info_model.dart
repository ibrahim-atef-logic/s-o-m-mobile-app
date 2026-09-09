import '../../../../core/utils/json_map.dart';
import '../../domain/entities/price_info_entity.dart';

class PriceInfoModel {
  const PriceInfoModel({
    required this.itemNumber,
    required this.price,
    required this.unitId,
    required this.found,
    this.currency = '',
    this.customerAccountNumber = '',
    this.priceCustomerGroupCode = '',
    this.dataArea = '',
  });

  final String itemNumber;
  final double price;
  final String unitId;
  final bool found;
  final String currency;
  final String customerAccountNumber;
  final String priceCustomerGroupCode;
  final String dataArea;

  factory PriceInfoModel.fromJson(Map<String, dynamic> json) {
    final double? finalPrice = _asDouble(JsonMap.value(json, 'finalPrice'));
    final Object? foundRaw = JsonMap.value(json, 'found');
    final bool foundFlag = foundRaw == null
        ? finalPrice != null
        : JsonMap.flag(json, 'found', fallback: true);
    return PriceInfoModel(
      itemNumber: JsonMap.stringAny(json, <String>['itemId', 'itemNumber']),
      price: finalPrice ?? 0,
      unitId: JsonMap.stringAny(json, <String>['salesUnit', 'unitId']),
      found: foundFlag && finalPrice != null,
      currency: JsonMap.string(json, 'currency'),
      customerAccountNumber: JsonMap.string(json, 'customerAccountNumber'),
      priceCustomerGroupCode: JsonMap.stringAny(json, <String>[
        'priceGroupId',
        'priceCustomerGroupCode',
      ]),
      dataArea: JsonMap.stringAny(json, <String>['dataArea', 'company']),
    );
  }

  static double? _asDouble(Object? raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw.trim());
    }
    return null;
  }

  PriceInfoEntity toEntity() => PriceInfoEntity(
    itemNumber: itemNumber,
    price: price,
    unitId: unitId,
    currency: currency,
    found: found,
    customerAccountNumber: customerAccountNumber,
    priceCustomerGroupCode: priceCustomerGroupCode,
    dataArea: dataArea,
  );
}
