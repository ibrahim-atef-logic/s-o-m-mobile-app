import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_tokens_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthTokensEntity>> call({
    required String company,
    required String personnelNumber,
    required String password,
  }) {
    if (company.trim().isEmpty ||
        personnelNumber.trim().isEmpty ||
        password.isEmpty) {
      return Future<Either<Failure, AuthTokensEntity>>.value(
        const Left<Failure, AuthTokensEntity>(
          ValidationFailure(
            'Company, personnel number and password are required',
          ),
        ),
      );
    }
    return _repository.login(
      company: company.trim(),
      personnelNumber: personnelNumber.trim(),
      password: password,
    );
  }
}
