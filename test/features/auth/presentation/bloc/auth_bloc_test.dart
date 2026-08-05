import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/select_company_usecase.dart';
import 'package:logic_retail_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRestoreSessionUseCase extends Mock implements RestoreSessionUseCase {}

class MockSelectCompanyUseCase extends Mock implements SelectCompanyUseCase {}

void main() {
  late MockLoginUseCase login;
  late MockLogoutUseCase logout;
  late MockRestoreSessionUseCase restore;
  late MockSelectCompanyUseCase selectCompany;

  const CompanyEntity usmf = CompanyEntity(
    code: 'usmf',
    name: 'USMF',
    groupId: 'G1',
  );
  const CompanyEntity ussi = CompanyEntity(
    code: 'ussi',
    name: 'USSI',
    groupId: 'G2',
  );
  const UserSessionEntity multiCompanyUser = UserSessionEntity(
    personnelNumber: 'EMP001',
    workerRecId: 1,
    name: 'Ahmed',
    companies: <CompanyEntity>[usmf, ussi],
  );
  const UserSessionEntity singleCompanyUser = UserSessionEntity(
    personnelNumber: 'EMP002',
    workerRecId: 2,
    name: 'Sara',
    companies: <CompanyEntity>[usmf],
  );

  setUp(() {
    login = MockLoginUseCase();
    logout = MockLogoutUseCase();
    restore = MockRestoreSessionUseCase();
    selectCompany = MockSelectCompanyUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
    loginUseCase: login,
    logoutUseCase: logout,
    restoreSessionUseCase: restore,
    selectCompanyUseCase: selectCompany,
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated when no session',
    build: () {
      when(
        () => restore(),
      ).thenAnswer((_) async => const Right<Failure, UserSessionEntity?>(null));
      return buildBloc();
    },
    act: (AuthBloc bloc) => bloc.add(const AuthStarted()),
    expect: () => <AuthState>[const AuthLoading(), const AuthUnauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'login success with company scopes session',
    build: () {
      when(
        () => login(
          company: any(named: 'company'),
          personnelNumber: any(named: 'personnelNumber'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, AuthTokensEntity>(
          AuthTokensEntity(
            accessToken: 'a',
            refreshToken: 'r',
            user: multiCompanyUser,
          ),
        ),
      );
      return buildBloc();
    },
    act: (AuthBloc bloc) => bloc.add(
      const AuthLoginSubmitted(
        company: 'usmf',
        personnelNumber: 'EMP001',
        password: '1234',
      ),
    ),
    expect: () => <AuthState>[
      const AuthLoading(),
      AuthAuthenticated(multiCompanyUser.copyWith(selectedCompany: usmf)),
    ],
    verify: (AuthBloc bloc) {
      final AuthState state = bloc.state;
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).session.selectedCompany, usmf);
      expect(state.needsCompany, isFalse);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'login with logic-trial prefers matching company',
    build: () {
      const CompanyEntity trial = CompanyEntity(
        code: 'logic-trial',
        name: 'Logic Trial',
        groupId: 'GRP-TRIAL',
      );
      const UserSessionEntity trialUser = UserSessionEntity(
        personnelNumber: '1006',
        workerRecId: 5637144578,
        name: 'Trial User',
        companies: <CompanyEntity>[trial],
      );
      when(
        () => login(
          company: any(named: 'company'),
          personnelNumber: any(named: 'personnelNumber'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, AuthTokensEntity>(
          AuthTokensEntity(
            accessToken: 'a',
            refreshToken: 'r',
            user: trialUser,
          ),
        ),
      );
      return buildBloc();
    },
    act: (AuthBloc bloc) => bloc.add(
      const AuthLoginSubmitted(
        company: 'logic-trial',
        personnelNumber: '1006',
        password: '123',
      ),
    ),
    expect: () => <AuthState>[
      const AuthLoading(),
      AuthAuthenticated(
        const UserSessionEntity(
          personnelNumber: '1006',
          workerRecId: 5637144578,
          name: 'Trial User',
          companies: <CompanyEntity>[
            CompanyEntity(
              code: 'logic-trial',
              name: 'Logic Trial',
              groupId: 'GRP-TRIAL',
            ),
          ],
          selectedCompany: CompanyEntity(
            code: 'logic-trial',
            name: 'Logic Trial',
            groupId: 'GRP-TRIAL',
          ),
        ),
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'login success with single company auto-selects',
    build: () {
      when(
        () => login(
          company: any(named: 'company'),
          personnelNumber: any(named: 'personnelNumber'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, AuthTokensEntity>(
          AuthTokensEntity(
            accessToken: 'a',
            refreshToken: 'r',
            user: singleCompanyUser,
          ),
        ),
      );
      return buildBloc();
    },
    act: (AuthBloc bloc) => bloc.add(
      const AuthLoginSubmitted(
        company: 'usmf',
        personnelNumber: 'EMP002',
        password: 'pass',
      ),
    ),
    expect: () => <AuthState>[
      const AuthLoading(),
      AuthAuthenticated(singleCompanyUser.copyWith(selectedCompany: usmf)),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'login failure emits AuthFailureState',
    build: () {
      when(
        () => login(
          company: any(named: 'company'),
          personnelNumber: any(named: 'personnelNumber'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, AuthTokensEntity>(AuthFailure('bad')),
      );
      return buildBloc();
    },
    act: (AuthBloc bloc) => bloc.add(
      const AuthLoginSubmitted(company: 'usmf', personnelNumber: 'x', password: 'y'),
    ),
    expect: () => <AuthState>[
      const AuthLoading(),
      const AuthFailureState(AuthFailure('bad')),
    ],
  );
}
