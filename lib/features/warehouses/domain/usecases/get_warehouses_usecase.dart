import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/warehouse_entity.dart';
import '../repositories/warehouse_repository.dart';

/// Loads Standard warehouses for the operating company.
///
/// Why: the backend rejects the login registry key with `403
/// FORBIDDEN_COMPANY`, so callers must pass `session.operatingCompany`.
class GetWarehousesUseCase {
  const GetWarehousesUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Either<Failure, List<WarehouseEntity>>> call(String company) {
    final String trimmed = company.trim();
    if (trimmed.isEmpty) {
      return Future<Either<Failure, List<WarehouseEntity>>>.value(
        const Left<Failure, List<WarehouseEntity>>(
          ValidationFailure('COMPANY_REQUIRED'),
        ),
      );
    }
    return _repository.getWarehouses(trimmed);
  }
}
