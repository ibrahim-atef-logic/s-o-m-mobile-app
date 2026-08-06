import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/full_add/domain/full_add_qty_rules.dart';

void main() {
  group('FullAddQtyRules.validate', () {
    test('returns qtyInvalid for non-positive / non-int', () {
      expect(
        FullAddQtyRules.validate(quantityText: '0', availableSalesQuantity: 10),
        'qtyInvalid',
      );
      expect(
        FullAddQtyRules.validate(quantityText: 'abc', availableSalesQuantity: 10),
        'qtyInvalid',
      );
      expect(
        FullAddQtyRules.validate(quantityText: '', availableSalesQuantity: 10),
        'qtyInvalid',
      );
    });

    test('returns qtyExceeds when quantity above available', () {
      expect(
        FullAddQtyRules.validate(quantityText: '11', availableSalesQuantity: 10),
        'qtyExceeds',
      );
    });

    test('returns null when quantity is ok', () {
      expect(
        FullAddQtyRules.validate(quantityText: '5', availableSalesQuantity: 10),
        isNull,
      );
    });
  });

  test('exceedsAvailable is true for huge qty', () {
    expect(
      FullAddQtyRules.exceedsAvailable(quantity: 999999, availableSalesQuantity: 25),
      isTrue,
    );
    expect(
      FullAddQtyRules.exceedsAvailable(quantity: 10, availableSalesQuantity: 25),
      isFalse,
    );
  });
}
