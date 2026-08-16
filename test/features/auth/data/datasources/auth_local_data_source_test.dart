import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/constants/app_constants.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthLocalDataSourceImpl sut;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sut = AuthLocalDataSourceImpl(
      secureStorage: const FlutterSecureStorage(),
      prefs: await SharedPreferences.getInstance(),
    );
  });

  test('saveSession persists tokens and full user including activation fields',
      () async {
    final AuthResponseModel session =
        AuthResponseModel.fromJson(Fixtures.sampleLoginDataJson);
    await sut.saveSession(session);

    final AuthResponseModel? restored = await sut.readSession();
    expect(restored, isNotNull);
    expect(restored!.accessToken, session.accessToken);
    expect(restored.refreshToken, session.refreshToken);
    expect(restored.user.activeCompany, 'mm');
    expect(restored.user.activeWarehouse, 'MMS000WH');
    expect(restored.user.defaultCustAccount, '10-10002');
    expect(restored.user.retailChannelId, '912');
    expect(restored.user.currency, 'SAR');
    expect(restored.user.workerRecId, 5637227826);

    const FlutterSecureStorage secure = FlutterSecureStorage();
    final String? blob = await secure.read(key: StorageKeys.authSessionJson);
    expect(blob, isNotNull);
    final Map<String, dynamic> decoded =
        jsonDecode(blob!) as Map<String, dynamic>;
    expect(decoded['user'], isA<Map<String, dynamic>>());
  });

  test('clear wipes tokens and user cache', () async {
    await sut.saveSession(
      AuthResponseModel.fromJson(Fixtures.sampleLoginDataIncompleteJson),
    );
    await sut.clear();
    expect(await sut.readSession(), isNull);
    expect(await sut.readAccessToken(), isNull);
    expect(await sut.readRefreshToken(), isNull);
  });
}
