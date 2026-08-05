import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_tokens_entity.dart';
import '../entities/user_session_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthTokensEntity>> login({
    required String company,
    required String personnelNumber,
    required String password,
  });

  Future<Either<Failure, AuthTokensEntity>> refresh();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserSessionEntity?>> restoreSession();

  Future<Either<Failure, void>> persistSelectedCompany(String companyCode);

  Future<String?> readAccessToken();
}
