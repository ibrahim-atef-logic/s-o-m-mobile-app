import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Warehouse picker route. Opened from create-order, never as a login gate.
const String kWarehouseGateRoute = '/warehouse';

/// Resolves the router redirect for [location] from the current [state].
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
    // Missing warehouse is not a login gate; the picker only opens on create-SO.
    if (onAuth || location == '/company') {
      return '/orders';
    }
  }
  return null;
}
