import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/core/router/auth_redirect.dart';
import 'package:logic_retail_mobile/features/auth/data/models/user_session_model.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/presentation/bloc/auth_bloc.dart';

import '../../helpers/fixtures.dart';

void main() {
  final UserSessionEntity user1006 = UserSessionModel.fromJson(
    Fixtures.sampleActivationUser1006,
  ).toEntity();
  final UserSessionEntity user12344 = UserSessionModel.fromJson(
    Fixtures.sampleActivationUser12344,
  ).toEntity();

  String? redirect(AuthState state, String location) =>
      resolveAuthRedirect(state: state, location: location);

  test('1006 goes home after login and is never sent to the picker', () {
    final AuthState state = AuthAuthenticated(user1006);

    expect(redirect(state, '/login'), '/orders');
    expect(redirect(state, '/orders'), isNull);
    expect(redirect(state, '/profile'), isNull);
  });

  test('12344 goes home after login; warehouse is chosen on create-order', () {
    final AuthState blocked = AuthAuthenticated(user12344);

    expect(redirect(blocked, '/login'), '/orders');
    expect(redirect(blocked, '/orders'), isNull);
    expect(redirect(blocked, kWarehouseGateRoute), isNull);

    final AuthState picked = AuthAuthenticated(
      user12344.copyWith(
        activeWarehouse: 'PLS001WH',
        inventLocation: 'PLS001WH',
        needsWarehouseSelection: false,
      ),
    );
    expect(redirect(picked, kWarehouseGateRoute), isNull);
    expect(redirect(picked, '/login'), '/orders');
  });

  test('the picker stays reachable for an intentional warehouse change', () {
    expect(redirect(AuthAuthenticated(user1006), kWarehouseGateRoute), isNull);
  });

  test('unauthenticated states fall back to the hello screen', () {
    expect(redirect(const AuthUnauthenticated(), '/orders'), '/hello');
    expect(redirect(const AuthUnauthenticated(), '/hello'), isNull);
    expect(
      redirect(const AuthFailureState(AuthFailure()), kWarehouseGateRoute),
      '/hello',
    );
  });

  test('loading and initial states never redirect', () {
    expect(redirect(const AuthLoading(), '/orders'), isNull);
    expect(redirect(const AuthInitial(), kWarehouseGateRoute), isNull);
  });
}
