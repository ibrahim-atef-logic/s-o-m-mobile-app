import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/full_add/domain/full_add_display_unit.dart';

void main() {
  test('prefers inventory unit over lookup unitId', () {
    expect(
      FullAddDisplayUnit.resolve(inventoryUnit: 'حبة', lookupUnitId: 'PCS'),
      'حبة',
    );
  });

  test('falls back to lookup unitId when inventory unit blank', () {
    expect(
      FullAddDisplayUnit.resolve(inventoryUnit: '', lookupUnitId: 'PCS'),
      'PCS',
    );
    expect(
      FullAddDisplayUnit.resolve(inventoryUnit: '  ', lookupUnitId: 'PCS'),
      'PCS',
    );
  });

  test('returns null when both units empty', () {
    expect(
      FullAddDisplayUnit.resolve(inventoryUnit: '', lookupUnitId: ''),
      isNull,
    );
  });

  test('formats available qty with a single space before unit', () {
    expect(
      FullAddDisplayUnit.formatAvailable(
        formattedQuantity: '10,000',
        unit: 'PCS',
      ),
      '10,000 PCS',
    );
    expect(
      FullAddDisplayUnit.formatAvailable(
        formattedQuantity: '0',
        unit: 'حبة',
      ),
      '0 حبة',
    );
    expect(
      FullAddDisplayUnit.formatAvailable(formattedQuantity: '5', unit: null),
      '5',
    );
  });
}
