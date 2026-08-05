import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/line_submit_result_entity.dart';
import '../repositories/catalog_repository.dart';

class SubmitFullLineUseCase {
  const SubmitFullLineUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, LineSubmitResultEntity>> call({
    required String salesId,
    required String company,
    required String itemNumber,
    required num quantity,
  }) {
    if (salesId.trim().isEmpty ||
        company.trim().isEmpty ||
        itemNumber.trim().isEmpty) {
      return Future<Either<Failure, LineSubmitResultEntity>>.value(
        const Left<Failure, LineSubmitResultEntity>(
          ValidationFailure('Sales order, company and item are required'),
        ),
      );
    }
    if (!_isValidQty(quantity)) {
      return Future<Either<Failure, LineSubmitResultEntity>>.value(
        const Left<Failure, LineSubmitResultEntity>(
          ValidationFailure('Quantity is invalid'),
        ),
      );
    }
    return _repository.submitFullLine(
      salesId: salesId,
      company: company,
      itemNumber: itemNumber,
      quantity: quantity,
    );
  }

  bool _isValidQty(num quantity) {
    return quantity >= 1 && quantity == quantity.roundToDouble();
  }
}
