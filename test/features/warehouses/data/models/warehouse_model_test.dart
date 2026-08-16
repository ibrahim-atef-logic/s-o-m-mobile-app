import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/warehouses/data/models/warehouse_model.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/entities/warehouse_entity.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('parses the Standard warehouse list payload', () {
    final List<WarehouseEntity> parsed = Fixtures.sampleWarehousesJson
        .map(WarehouseModel.fromJson)
        .map((WarehouseModel m) => m.toEntity())
        .toList();

    expect(parsed, hasLength(2));
    expect(parsed.first.inventLocationId, 'MMS021ST');
    expect(parsed.first.dataAreaId, 'mm');
    expect(parsed.first.inventLocationType, 'Standard');
    expect(parsed.last.displayName, 'Main warehouse');
    expect(parsed.last.displayDetails, '${Fixtures.warehouse} · MMS000');
  });

  test('falls back to the warehouse code when name is null or empty', () {
    final WarehouseModel nullName = WarehouseModel.fromJson(<String, dynamic>{
      'dataAreaId': 'mm',
      'inventLocationId': 'MMS000WH',
      'name': null,
    });
    final WarehouseModel emptyName = WarehouseModel.fromJson(<String, dynamic>{
      'dataAreaId': 'mm',
      'inventLocationId': 'MMS000WH',
      'name': '   ',
    });

    expect(nullName.name, 'MMS000WH');
    expect(emptyName.name, 'MMS000WH');
    expect(nullName.toEntity().displayName, 'MMS000WH');
  });

  test('reads D365-cased keys and hides the site when equal to the code', () {
    final WarehouseEntity parsed = WarehouseModel.fromJson(<String, dynamic>{
      'DataAreaId': 'PLTR',
      'InventLocationId': 'PL001',
      'Name': 'PL001',
      'InventSiteId': 'PL001',
      'InventLocationType': 'Standard',
    }).toEntity();

    expect(parsed.dataAreaId, 'PLTR');
    expect(parsed.inventLocationId, 'PL001');
    expect(parsed.displayDetails, 'PL001');
  });
}
