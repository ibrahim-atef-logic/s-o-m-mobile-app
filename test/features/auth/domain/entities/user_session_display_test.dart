import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/auth/data/models/user_session_model.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('UserSessionDisplay profile labels', () {
    late UserSessionEntity user1006;

    setUp(() {
      user1006 = UserSessionModel.fromJson(
        Fixtures.sampleActivationUser1006,
      ).toEntity();
    });

    test('profileDisplayName prefers name over personnel number', () {
      expect(user1006.profileDisplayName, 'محمد عفيف');
    });

    test('profileDisplayName falls back to personnel number', () {
      final UserSessionEntity bare = UserSessionModel.fromJson(
        <String, dynamic>{
          'personnelNumber': '1006',
          'workerRecId': 1,
          'name': '',
        },
      ).toEntity();
      expect(bare.profileDisplayName, '1006');
    });

    test('resolvedDisplayCompanyName uses Arabic displayCompanyName', () {
      expect(user1006.resolvedDisplayCompanyName, 'تجزئة هايبر ماركت');
      expect(user1006.resolvedDisplayCompanyName, isNot('mm'));
    });

    test('resolvedDisplayWarehouseName prefers displayWarehouseName', () {
      expect(user1006.resolvedDisplayWarehouseName, 'MMS000WH');
    });

    test('profileChannelLabel is retailChannelName only', () {
      expect(user1006.profileChannelLabel, 'سلة المواد الغذائية المخفضة');
    });

    test('profileCurrencyLabel exposes currency', () {
      expect(user1006.profileCurrencyLabel, 'SAR');
    });

    test('12344 hides warehouse row when selection required', () {
      final UserSessionEntity user12344 = UserSessionModel.fromJson(
        Fixtures.sampleActivationUser12344,
      ).toEntity();
      expect(user12344.needsWarehouseSelection, isTrue);
      expect(user12344.profileChannelLabel, isNull);
      expect(user12344.profileCurrencyLabel, isNull);
    });
  });
}
