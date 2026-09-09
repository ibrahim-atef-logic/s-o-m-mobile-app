import 'package:equatable/equatable.dart';

class PriceInfoEntity extends Equatable {
  const PriceInfoEntity({
    required this.itemNumber,
    required this.price,
    required this.unitId,
    this.currency = '',
    this.found = true,
    this.customerAccountNumber = '',
    this.priceCustomerGroupCode = '',
    this.dataArea = '',
  });

  final String itemNumber;

  /// Channel [finalPrice] from POST /item-price. Never derived client-side.
  final double price;
  final String unitId;
  final String currency;
  final bool found;
  final String customerAccountNumber;
  final String priceCustomerGroupCode;
  final String dataArea;

  PriceInfoEntity withCurrencyFallback(String? fallback) {
    if (currency.trim().isNotEmpty) {
      return this;
    }
    final String next = fallback?.trim() ?? '';
    if (next.isEmpty) {
      return this;
    }
    return PriceInfoEntity(
      itemNumber: itemNumber,
      price: price,
      unitId: unitId,
      currency: next,
      found: found,
      customerAccountNumber: customerAccountNumber,
      priceCustomerGroupCode: priceCustomerGroupCode,
      dataArea: dataArea,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    itemNumber,
    price,
    unitId,
    currency,
    found,
    customerAccountNumber,
    priceCustomerGroupCode,
    dataArea,
  ];
}
