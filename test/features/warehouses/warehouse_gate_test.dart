import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/auth/data/models/user_session_model.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';

import '../../helpers/fixtures.dart';

/// Decides whether the warehouse picker must block the app after login.
void main() {
  UserSessionEntity session(Map<String, dynamic> json) =>
      UserSessionModel.fromJson(json).toEntity();

  test('1006 has a warehouse, so the picker is skipped', () {
    final UserSessionEntity user = session(Fixtures.sampleActivationUser1006);

    expect(user.operatingCompany, 'mm');
    expect(user.resolvedWarehouse, Fixtures.warehouse);
    expect(user.needsWarehouseSelection, isFalse);
    expect(user.warehouseMissing, isFalse);
  });

  test('12344 has no warehouse, so the picker must open', () {
    final UserSessionEntity user = session(Fixtures.sampleActivationUser12344);

    expect(user.operatingCompany, 'PLTR');
    expect(user.resolvedWarehouse, isNull);
    expect(user.warehouseMissing, isTrue);
  });

  test('empty warehouse strings count as missing even without the flag', () {
    final UserSessionEntity user = session(<String, dynamic>{
      'personnelNumber': '12344',
      'name': 'مروان وهاس',
      'activeCompany': 'PLTR',
      'activeWarehouse': '   ',
      'inventLocation': null,
    });

    expect(user.warehouseMissing, isTrue);
  });

  test('server flag wins while it is still set', () {
    final UserSessionEntity user = session(<String, dynamic>{
      'personnelNumber': '1006',
      'activeCompany': 'mm',
      'activeWarehouse': 'MMS000WH',
      'needsWarehouseSelection': true,
    });

    expect(user.warehouseMissing, isTrue);
  });

  test('picking a warehouse clears the gate', () {
    final UserSessionEntity picked = session(Fixtures.sampleActivationUser12344)
        .copyWith(
          activeWarehouse: 'MMS021ST',
          inventLocation: 'MMS021ST',
          inventLocationDataAreaId: 'PLTR',
          needsWarehouseSelection: false,
        );

    expect(picked.resolvedWarehouse, 'MMS021ST');
    expect(picked.warehouseMissing, isFalse);
  });
}
