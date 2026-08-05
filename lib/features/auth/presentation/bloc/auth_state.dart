part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => <Object?>[];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final UserSessionEntity session;

  bool get needsCompany => false;

  @override
  List<Object?> get props => <Object?>[session];
}

final class AuthFailureState extends AuthState {
  const AuthFailureState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
