import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late LoginUseCase sut;

  const UserSessionEntity tUser = UserSessionEntity(
    personnelNumber: 'EMP001',
    workerRecId: 1,
    name: 'Ahmed',
    companies: <CompanyEntity>[
      CompanyEntity(code: 'usmf', name: 'USMF', groupId: 'G1'),
    ],
  );

  const AuthTokensEntity tTokens = AuthTokensEntity(
    accessToken: 'a',
    refreshToken: 'r',
    user: tUser,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    sut = LoginUseCase(mockRepo);
  });

  test('should return AuthTokensEntity on success', () async {
    when(
      () => mockRepo.login(
        company: any(named: 'company'),
        personnelNumber: any(named: 'personnelNumber'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Right<Failure, AuthTokensEntity>(tTokens));

    final Either<Failure, AuthTokensEntity> result = await sut(
      company: 'usmf',
      personnelNumber: 'EMP001',
      password: '1234',
    );

    expect(result, const Right<Failure, AuthTokensEntity>(tTokens));
    verify(
      () => mockRepo.login(
        company: 'usmf',
        personnelNumber: 'EMP001',
        password: '1234',
      ),
    ).called(1);
  });

  test('should return ValidationFailure when fields empty', () async {
    final Either<Failure, AuthTokensEntity> result = await sut(
      company: '',
      personnelNumber: ' ',
      password: '',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.login(
        company: any(named: 'company'),
        personnelNumber: any(named: 'personnelNumber'),
        password: any(named: 'password'),
      ),
    );
  });

  test('should return AuthFailure from repository', () async {
    when(
      () => mockRepo.login(
        company: any(named: 'company'),
        personnelNumber: any(named: 'personnelNumber'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, AuthTokensEntity>(AuthFailure()),
    );

    final Either<Failure, AuthTokensEntity> result = await sut(
      company: 'usmf',
      personnelNumber: 'EMP001',
      password: 'bad',
    );

    expect(result, const Left<Failure, AuthTokensEntity>(AuthFailure()));
  });
}
