import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/full_add/domain/entities/full_cart_item_entity.dart';

void main() {
  test('addingQuantity sums qty for a second scan of the same item', () {
    const FullCartItemEntity existing = FullCartItemEntity(
      barcode: '6281001000002',
      itemNumber: '2000',
      productName: 'Keyboard',
      quantity: 2,
      price: 10,
      unitId: 'ea',
    );
    const FullCartItemEntity scanned = FullCartItemEntity(
      barcode: '6281001000002',
      itemNumber: '2000',
      productName: 'Keyboard',
      quantity: 3,
      price: 10,
      unitId: 'ea',
    );

    expect(existing.addingQuantity(scanned).quantity, 5);
  });
}
