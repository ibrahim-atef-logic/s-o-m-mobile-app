import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/user_session_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/usecases/select_company_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Owns authentication session lifecycle for the app.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    required SelectCompanyUseCase selectCompanyUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _restoreSessionUseCase = restoreSessionUseCase,
       _selectCompanyUseCase = selectCompanyUseCase,
       super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthCompanySelected>(_onCompanySelected);
    on<AuthLogoutRequested>(_onLogout);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final SelectCompanyUseCase _selectCompanyUseCase;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final Either<Failure, UserSessionEntity?> result =
        await _restoreSessionUseCase();
    result.fold((Failure f) => emit(const AuthUnauthenticated()), (
      UserSessionEntity? session,
    ) {
      if (session == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      emit(
        AuthAuthenticated(_withDefaultCompany(session)),
      );
    });
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final Either<Failure, AuthTokensEntity> result = await _loginUseCase(
      company: event.company,
      personnelNumber: event.personnelNumber,
      password: event.password,
    );
    result.fold((Failure f) => emit(AuthFailureState(f)), (
      AuthTokensEntity tokens,
    ) {
      emit(
        AuthAuthenticated(
          _withDefaultCompany(
            tokens.user,
            preferredCode: event.company,
          ),
        ),
      );
    });
  }

  Future<void> _onCompanySelected(
    AuthCompanySelected event,
    Emitter<AuthState> emit,
  ) async {
    final AuthState current = state;
    if (current is! AuthAuthenticated) return;
    emit(const AuthLoading());
    final Either<Failure, UserSessionEntity> result =
        await _selectCompanyUseCase(
          session: current.session,
          companyCode: event.companyCode,
        );
    result.fold(
      (Failure f) => emit(AuthFailureState(f)),
      (UserSessionEntity session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logoutUseCase();
    emit(const AuthUnauthenticated());
  }

  UserSessionEntity _withDefaultCompany(
    UserSessionEntity session, {
    String? preferredCode,
  }) {
    if (session.selectedCompany != null) {
      return session;
    }
    final String? preferred = preferredCode?.trim();
    if (preferred != null && preferred.isNotEmpty) {
      for (final CompanyEntity company in session.companies) {
        if (company.code.toLowerCase() == preferred.toLowerCase()) {
          return session.copyWith(selectedCompany: company);
        }
      }
    }
    if (session.companies.isEmpty) {
      return session;
    }
    return session.copyWith(selectedCompany: session.companies.first);
  }
}
