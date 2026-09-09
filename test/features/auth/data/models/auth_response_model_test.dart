import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('parses complete 1006 activation payload', () {
    final AuthResponseModel model = AuthResponseModel.fromJson(
      Fixtures.sampleLoginDataJson,
    );
    final user = model.user.toEntity();

    expect(model.accessToken, 'access-token-sample');
    expect(model.refreshToken, 'refresh-token-sample');
    expect(user.personnelNumber, '1006');
    expect(user.workerRecId, 5637227826);
    expect(user.userId, 'm.afif');
    expect(user.operatingCompany, 'mm');
    expect(user.resolvedDisplayCompanyName, 'تجزئة هايبر ماركت');
    expect(user.resolvedWarehouse, 'MMS000WH');
    expect(user.resolvedDisplayWarehouseName, 'MMS000WH');
    expect(user.defaultCustAccount, '10-10002');
    expect(user.retailChannelId, '912');
    expect(user.retailChannelName, 'سلة المواد الغذائية المخفضة');
    expect(user.displayBranchLabel, 'سلة المواد الغذائية المخفضة');
    expect(user.channelType, 4);
    expect(user.currency, 'SAR');
    expect(user.warehouseMissing, isFalse);
    expect(user.needsWarehouseSelection, isFalse);
  });

  test('parses incomplete 12344 payload without crashing', () {
    final AuthResponseModel model = AuthResponseModel.fromJson(
      Fixtures.sampleLoginDataIncompleteJson,
    );
    final user = model.user.toEntity();

    expect(user.personnelNumber, '12344');
    expect(user.operatingCompany, 'PLTR');
    expect(user.resolvedWarehouse, isNull);
    expect(user.defaultCustAccount, isNull);
    expect(user.retailChannelId, isNull);
    expect(user.retailChannelName, isNull);
    expect(user.displayBranchLabel, '—');
    expect(user.currency, isNull);
    expect(user.warehouseMissing, isTrue);
    expect(user.needsWarehouseSelection, isTrue);
  });

  test('parses case-insensitive keys and empty strings as missing', () {
    final AuthResponseModel model = AuthResponseModel.fromJson(
      <String, dynamic>{
        'AccessToken': 'a',
        'RefreshToken': 'r',
        'User': <String, dynamic>{
          'PersonnelNumber': '12344',
          'WorkerRecId': 9,
          'Name': 'مروان وهاس',
          'ActiveCompany': 'pltr',
          'ActiveWarehouse': '',
          'DefaultCustAccount': '',
          'RetailChannelId': '912',
          'RetailChannelName': 'سلة المواد الغذائية المخفضة',
          'Companies': <Map<String, dynamic>>[
            <String, dynamic>{'Code': 'pltr', 'Name': 'pltr', 'GroupId': null},
          ],
        },
      },
    );
    final user = model.user.toEntity();
    expect(model.accessToken, 'a');
    expect(user.operatingCompany, 'pltr');
    expect(user.resolvedWarehouse, isNull);
    expect(user.warehouseMissing, isTrue);
    expect(user.retailChannelId, '912');
    expect(user.retailChannelName, 'سلة المواد الغذائية المخفضة');
    expect(user.displayBranchLabel, 'سلة المواد الغذائية المخفضة');
  });

  test('displayBranchLabel falls back to id then warehouse', () {
    final UserSessionEntity byId = UserSessionModel.fromJson(<String, dynamic>{
      'personnelNumber': '1',
      'workerRecId': 1,
      'name': 'x',
      'retailChannelId': '912',
      'activeWarehouse': 'MMS000WH',
    }).toEntity();
    expect(byId.displayBranchLabel, '912');

    final UserSessionEntity byWh = UserSessionModel.fromJson(<String, dynamic>{
      'personnelNumber': '1',
      'workerRecId': 1,
      'name': 'x',
      'activeWarehouse': 'MMS000WH',
    }).toEntity();
    expect(byWh.displayBranchLabel, 'MMS000WH');
  });

  test('toJson round-trips retailChannelName in the session cache', () {
    final UserSessionModel original = UserSessionModel.fromJson(
      Fixtures.sampleActivationUser1006,
    );
    final UserSessionModel restored = UserSessionModel.fromJson(
      original.toJson(),
    );
    expect(restored.retailChannelName, original.retailChannelName);
    expect(
      restored.toEntity().displayBranchLabel,
      'سلة المواد الغذائية المخفضة',
    );
  });

  test('personnelNumber is always String (JSON number or D365 aliases)', () {
    final UserSessionModel fromNumber = UserSessionModel.fromJson(
      <String, dynamic>{'personnelNumber': 1006, 'workerRecId': 1, 'name': 'x'},
    );
    expect(fromNumber.personnelNumber, '1006');
    expect(fromNumber.personnelNumber, isA<String>());

    final UserSessionModel fromD365 = UserSessionModel.fromJson(
      <String, dynamic>{
        '_personnelNumber': 'm.afif',
        'workerRecId': 1,
        'name': 'x',
      },
    );
    expect(fromD365.personnelNumber, 'm.afif');

    final UserSessionModel fromPascal = UserSessionModel.fromJson(
      <String, dynamic>{
        'PersonnelNumber': '1006',
        'workerRecId': 1,
        'name': 'x',
      },
    );
    expect(fromPascal.personnelNumber, '1006');
  });
}
