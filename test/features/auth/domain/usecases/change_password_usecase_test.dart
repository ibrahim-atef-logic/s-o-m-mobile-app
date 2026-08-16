import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late ChangePasswordUseCase sut;

  setUp(() {
    repo = MockAuthRepository();
    sut = ChangePasswordUseCase(repo);
  });

  test('rejects empty, mismatch, and same-as-old without calling API', () async {
    expect(
      (await sut(oldPassword: '', newPassword: 'a', confirmPassword: 'a')).isLeft(),
      isTrue,
    );
    expect(
      (await sut(oldPassword: '1', newPassword: '2', confirmPassword: '3')).isLeft(),
      isTrue,
    );
    expect(
      (await sut(oldPassword: '1', newPassword: '1', confirmPassword: '1')).isLeft(),
      isTrue,
    );
    verifyNever(
      () => repo.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  test('calls repository when validation passes', () async {
    when(
      () => repo.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async => const Right<Failure, String>('ok'));

    final Either<Failure, String> result = await sut(
      oldPassword: '123',
      newPassword: '456',
      confirmPassword: '456',
    );

    expect(result, const Right<Failure, String>('ok'));
  });
}
