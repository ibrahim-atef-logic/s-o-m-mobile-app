import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_session_entity.dart';
import '../repositories/auth_repository.dart';

class FetchMeUseCase {
  const FetchMeUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserSessionEntity>> call() {
    return _repository.fetchMe();
  }
}
