import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/scan_code.dart';
import '../entities/barcode_item_entity.dart';
import '../repositories/catalog_repository.dart';

/// Resolves a D365 item id via `GET /api/v1/items/{itemNumber}`.
class LookupItemUseCase {
  const LookupItemUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, BarcodeItemEntity>> call({
    required String itemNumber,
    required String company,
  }) {
    final String sanitized = ScanCode.stripControls(itemNumber);
    if (ScanCode.isBlank(sanitized)) {
      return Future<Either<Failure, BarcodeItemEntity>>.value(
        const Left<Failure, BarcodeItemEntity>(
          ValidationFailure('Item number is required'),
        ),
      );
    }
    if (company.trim().isEmpty) {
      return Future<Either<Failure, BarcodeItemEntity>>.value(
        const Left<Failure, BarcodeItemEntity>(
          ValidationFailure('Company is required'),
        ),
      );
    }
    return _repository.lookupItem(itemNumber: sanitized, company: company);
  }
}
