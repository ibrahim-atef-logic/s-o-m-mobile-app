import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';

void main() {
  test('Failure hierarchy equality by message', () {
    expect(const AuthFailure('x'), const AuthFailure('x'));
    expect(const NetworkFailure(), isA<Failure>());
    expect(const ServerFailure('s').message, 's');
  });
}
