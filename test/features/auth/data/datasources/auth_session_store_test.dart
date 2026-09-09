import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/auth/stored_session_wipe.dart';
import 'package:logic_retail_mobile/core/constants/app_constants.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_session_store.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryAuthSessionStore sut;

  final AuthResponseModel session = AuthResponseModel.fromJson(
    Fixtures.sampleLoginDataJson,
  );

  setUp(() {
    sut = InMemoryAuthSessionStore();
  });

  test('keeps the full activation payload in memory', () {
    sut.save(session);

    expect(sut.accessToken, session.accessToken);
    expect(sut.refreshToken, session.refreshToken);
    expect(sut.session?.user.activeCompany, 'mm');
    expect(sut.session?.user.activeWarehouse, 'MMS000WH');
    expect(sut.session?.user.defaultCustAccount, '10-10002');
    expect(sut.session?.user.retailChannelId, '912');
    expect(sut.session?.user.retailChannelName, 'سلة المواد الغذائية المخفضة');
    expect(sut.session?.user.currency, 'SAR');
    expect(sut.session?.user.workerRecId, 5637227826);
  });

  test('writes nothing to secure storage or preferences', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    sut.save(session);

    const FlutterSecureStorage secure = FlutterSecureStorage();
    for (final String key in StorageKeys.sessionKeys) {
      expect(await secure.read(key: key), isNull, reason: key);
      expect(prefs.getString(key), isNull, reason: key);
    }
  });

  test('clear drops the session so the next start needs a login', () {
    sut
      ..save(session)
      ..clear();

    expect(sut.session, isNull);
    expect(sut.accessToken, isNull);
    expect(sut.refreshToken, isNull);
  });

  test('saveAccessToken renews the token inside a live session', () {
    sut
      ..save(session)
      ..saveAccessToken('renewed');

    expect(sut.accessToken, 'renewed');
    expect(sut.session?.user.personnelNumber, Fixtures.personnelNumber);
  });

  test('wipeStoredSession deletes keys left by an older build', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      StorageKeys.accessToken: 'old-access',
      StorageKeys.refreshToken: 'old-refresh',
      StorageKeys.authSessionJson: '{"accessToken":"old"}',
    });
    SharedPreferences.setMockInitialValues(<String, Object>{
      StorageKeys.userJson: '{"personnelNumber":"1006"}',
      StorageKeys.localeCode: 'ar',
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    const FlutterSecureStorage secure = FlutterSecureStorage();

    await wipeStoredSession(secureStorage: secure, prefs: prefs);

    expect(await secure.read(key: StorageKeys.accessToken), isNull);
    expect(await secure.read(key: StorageKeys.refreshToken), isNull);
    expect(await secure.read(key: StorageKeys.authSessionJson), isNull);
    expect(prefs.getString(StorageKeys.userJson), isNull);
    expect(prefs.getString(StorageKeys.localeCode), 'ar');
  });
}
