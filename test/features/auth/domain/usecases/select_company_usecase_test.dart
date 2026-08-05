import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/select_company_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SelectCompanyUseCase sut;

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
  const UserSessionEntity session = UserSessionEntity(
    personnelNumber: 'EMP001',
    workerRecId: 1,
    name: 'Ahmed',
    companies: <CompanyEntity>[usmf, ussi],
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    sut = SelectCompanyUseCase(mockRepo);
  });

  test('should persist and return session with selected company', () async {
    when(
      () => mockRepo.persistSelectedCompany('usmf'),
    ).thenAnswer((_) async => const Right<Failure, void>(null));

    final Either<Failure, UserSessionEntity> result = await sut(
      session: session,
      companyCode: 'usmf',
    );

    expect(
      result,
      const Right<Failure, UserSessionEntity>(
        UserSessionEntity(
          personnelNumber: 'EMP001',
          workerRecId: 1,
          name: 'Ahmed',
          companies: <CompanyEntity>[usmf, ussi],
          selectedCompany: usmf,
        ),
      ),
    );
  });

  test('should return ValidationFailure for unknown company', () async {
    final Either<Failure, UserSessionEntity> result = await sut(
      session: session,
      companyCode: 'xx',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(() => mockRepo.persistSelectedCompany(any()));
  });
}
