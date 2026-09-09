import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/line_submit_result_entity.dart';
import '../repositories/catalog_repository.dart';

class SubmitQuickBatchUseCase {
  const SubmitQuickBatchUseCase(this._repository);

  final CatalogRepository _repository;

  static const int kMaxLines = 10;

  Future<Either<Failure, LineSubmitResultEntity>> call({
    required String salesId,
    required String company,
    required List<({String barcode, num quantity})> lines,
  }) {
    if (salesId.trim().isEmpty || company.trim().isEmpty) {
      return Future<Either<Failure, LineSubmitResultEntity>>.value(
        const Left<Failure, LineSubmitResultEntity>(
          ValidationFailure('Sales order and company are required'),
        ),
      );
    }
    if (lines.isEmpty) {
      return Future<Either<Failure, LineSubmitResultEntity>>.value(
        const Left<Failure, LineSubmitResultEntity>(
          ValidationFailure('At least one line is required'),
        ),
      );
    }
    if (lines.length > kMaxLines) {
      return Future<Either<Failure, LineSubmitResultEntity>>.value(
        const Left<Failure, LineSubmitResultEntity>(
          ValidationFailure('MAX_LINES: Quick add allows max 10 lines'),
        ),
      );
    }
    return _repository.submitQuickBatch(
      salesId: salesId,
      company: company,
      lines: lines,
    );
  }
}
