import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/price_info_entity.dart';
import '../repositories/catalog_repository.dart';

class ResolvePriceUseCase {
  const ResolvePriceUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, PriceInfoEntity>> call({
    required String itemNumber,
    required String company,
    required String salesUnitId,
    String? warehouseId,
    int? channelRecId,
  }) {
    // Empty salesUnitId is allowed — some DataAreas resolve price without a unit.
    if (itemNumber.trim().isEmpty || company.trim().isEmpty) {
      return Future<Either<Failure, PriceInfoEntity>>.value(
        const Left<Failure, PriceInfoEntity>(
          ValidationFailure('Item and company are required'),
        ),
      );
    }
    final String warehouse = warehouseId?.trim() ?? '';
    return _repository.resolvePrice(
      itemNumber: itemNumber.trim(),
      company: company.trim(),
      salesUnitId: salesUnitId.trim(),
      warehouseId: warehouse.isEmpty ? null : warehouse,
      channelRecId: channelRecId,
    );
  }
}
