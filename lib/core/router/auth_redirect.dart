import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Route the app is forced to while a session has no warehouse.
const String kWarehouseGateRoute = '/warehouse';

/// Resolves the router redirect for [location] from the current [state].
///
/// Why: a session without a warehouse cannot resolve inventory or create-SO
/// calls, so the warehouse picker blocks the app until one is picked.
String? resolveAuthRedirect({
  required AuthState state,
  required String location,
}) {
  final bool onAuth = location == '/hello' || location == '/login';

  if (state is AuthLoading || state is AuthInitial) {
    return null;
  }
  if (state is AuthUnauthenticated || state is AuthFailureState) {
    return onAuth ? null : '/hello';
  }
  if (state is AuthAuthenticated) {
    if (state.session.warehouseMissing) {
      return location == kWarehouseGateRoute ? null : kWarehouseGateRoute;
    }
    if (onAuth || location == '/company') {
      return '/orders';
    }
  }
  return null;
}
