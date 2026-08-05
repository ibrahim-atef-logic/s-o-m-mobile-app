import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/barcode_item_entity.dart';
import '../repositories/catalog_repository.dart';

class LookupBarcodeUseCase {
  const LookupBarcodeUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, BarcodeItemEntity>> call({
    required String code,
    required String company,
  }) {
    if (code.trim().isEmpty) {
      return Future<Either<Failure, BarcodeItemEntity>>.value(
        const Left<Failure, BarcodeItemEntity>(
          ValidationFailure('Barcode is required'),
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
    return _repository.lookupBarcode(code: code.trim(), company: company);
  }
}
