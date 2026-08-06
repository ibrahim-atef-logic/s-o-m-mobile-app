import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('AuthResponseModel parses tokens and mm/rest companies', () {
    final AuthResponseModel model =
        AuthResponseModel.fromJson(Fixtures.sampleLoginDataJson);

    expect(model.accessToken, 'access-token-sample');
    expect(model.refreshToken, 'refresh-token-sample');
    expect(model.user.personnelNumber, Fixtures.personnelNumber);
    expect(model.user.companies.map((c) => c.code), containsAll(<String>['mm', 'rest']));

    final tokens = model.toEntity();
    expect(tokens.accessToken, 'access-token-sample');
    expect(tokens.user.companies.length, 2);
  });
}
