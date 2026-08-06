import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('LogoutUseCase', () {
    test('delegates to repository.logout', () async {
      final LogoutUseCase sut = LogoutUseCase(mockRepo);
      when(() => mockRepo.logout()).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );

      final Either<Failure, void> result = await sut();

      expect(result.isRight(), isTrue);
      verify(() => mockRepo.logout()).called(1);
    });

    test('returns failure from repository', () async {
      final LogoutUseCase sut = LogoutUseCase(mockRepo);
      when(() => mockRepo.logout()).thenAnswer(
        (_) async => const Left<Failure, void>(NetworkFailure()),
      );

      final Either<Failure, void> result = await sut();
      expect(result, const Left<Failure, void>(NetworkFailure()));
    });
  });

  group('RestoreSessionUseCase', () {
    test('returns session when repository has one', () async {
      final RestoreSessionUseCase sut = RestoreSessionUseCase(mockRepo);
      const UserSessionEntity session = UserSessionEntity(
        personnelNumber: '1006',
        workerRecId: 1,
        name: 'Trial',
        companies: <CompanyEntity>[
          CompanyEntity(code: 'mm', name: 'MM', groupId: 'G'),
        ],
      );
      when(() => mockRepo.restoreSession()).thenAnswer(
        (_) async => const Right<Failure, UserSessionEntity?>(session),
      );

      final Either<Failure, UserSessionEntity?> result = await sut();
      expect(result, const Right<Failure, UserSessionEntity?>(session));
    });

    test('returns null session when none stored', () async {
      final RestoreSessionUseCase sut = RestoreSessionUseCase(mockRepo);
      when(() => mockRepo.restoreSession()).thenAnswer(
        (_) async => const Right<Failure, UserSessionEntity?>(null),
      );

      final Either<Failure, UserSessionEntity?> result = await sut();
      expect(result, const Right<Failure, UserSessionEntity?>(null));
    });
  });
}
