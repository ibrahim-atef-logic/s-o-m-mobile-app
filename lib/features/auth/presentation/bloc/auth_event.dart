part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({
    required this.company,
    required this.personnelNumber,
    required this.password,
  });

  final String company;
  final String personnelNumber;
  final String password;

  @override
  List<Object?> get props => <Object?>[company, personnelNumber, password];
}

final class AuthCompanySelected extends AuthEvent {
  const AuthCompanySelected(this.companyCode);

  final String companyCode;

  @override
  List<Object?> get props => <Object?>[companyCode];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
