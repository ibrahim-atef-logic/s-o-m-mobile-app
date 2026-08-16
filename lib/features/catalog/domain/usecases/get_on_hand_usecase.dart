import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/warehouse_on_hand_entity.dart';
import '../repositories/catalog_repository.dart';

class GetOnHandUseCase {
  const GetOnHandUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, WarehouseOnHandEntity>> call({
    required String itemNumber,
    required String warehouse,
    required String company,
  }) {
    if (warehouse.trim().isEmpty) {
      return Future<Either<Failure, WarehouseOnHandEntity>>.value(
        const Left<Failure, WarehouseOnHandEntity>(
          ValidationFailure('WAREHOUSE_NOT_ASSIGNED'),
        ),
      );
    }
    if (itemNumber.trim().isEmpty) {
      return Future<Either<Failure, WarehouseOnHandEntity>>.value(
        const Left<Failure, WarehouseOnHandEntity>(
          ValidationFailure('Item is required'),
        ),
      );
    }
    return _repository.getOnHand(
      itemNumber: itemNumber,
      warehouse: warehouse,
      company: company,
    );
  }
}
