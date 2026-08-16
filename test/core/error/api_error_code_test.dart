import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/api_error_code.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';

void main() {
  test('reads the code the interceptor prefixed onto the message', () {
    const Failure failure = ServerFailure(
      'WAREHOUSE_REQUIRED: No warehouse for this user',
    );

    expect(failure.apiCode, 'WAREHOUSE_REQUIRED');
    expect(failure.isWarehouseRequired, isTrue);
    expect(failure.isForbiddenCompany, isFalse);
  });

  test('flags forbidden company and dynamics outages', () {
    const Failure forbidden = ServerFailure(
      'FORBIDDEN_COMPANY: Company not allowed for token',
    );
    const Failure dynamics = ServerFailure('DYNAMICS_UNAVAILABLE: retry later');

    expect(forbidden.isForbiddenCompany, isTrue);
    expect(dynamics.isDynamicsOutage, isTrue);
    expect(dynamics.isWarehouseRequired, isFalse);
  });

  test('validation code is recognized for inline field errors', () {
    const Failure failure = ValidationFailure(
      'VALIDATION_ERROR: custAccount is required',
    );

    expect(failure.isValidationCode, isTrue);
  });

  test('plain messages have no code', () {
    const Failure network = NetworkFailure();
    const Failure prose = ServerFailure('Something broke: badly');

    expect(network.apiCode, isNull);
    expect(prose.apiCode, isNull);
  });
}
