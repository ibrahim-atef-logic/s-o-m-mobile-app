import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, String>> call({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      return Future<Either<Failure, String>>.value(
        const Left<Failure, String>(
          ValidationFailure('Old and new passwords are required'),
        ),
      );
    }
    if (newPassword != confirmPassword) {
      return Future<Either<Failure, String>>.value(
        const Left<Failure, String>(
          ValidationFailure('New password and confirmation do not match'),
        ),
      );
    }
    if (newPassword == oldPassword) {
      return Future<Either<Failure, String>>.value(
        const Left<Failure, String>(
          ValidationFailure('New password must be different from the old one'),
        ),
      );
    }
    return _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
