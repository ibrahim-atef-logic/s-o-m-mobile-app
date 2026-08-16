import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_session_entity.dart';
import '../repositories/auth_repository.dart';

/// Stores the warehouse chosen in the picker into the cached session.
///
/// Returns the updated session so callers can refresh the auth state without
/// re-reading secure storage.
class SelectWarehouseUseCase {
  const SelectWarehouseUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserSessionEntity>> call({
    required String inventLocationId,
    String? dataAreaId,
  }) {
    return _repository.persistWarehouse(
      inventLocationId: inventLocationId,
      dataAreaId: dataAreaId,
    );
  }
}
