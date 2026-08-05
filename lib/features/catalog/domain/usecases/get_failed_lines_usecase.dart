import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/failed_line_entity.dart';
import '../repositories/catalog_repository.dart';

class GetFailedLinesUseCase {
  const GetFailedLinesUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, List<FailedLineEntity>>> call({
    required String salesId,
    required String company,
    String? mode,
  }) {
    if (salesId.trim().isEmpty || company.trim().isEmpty) {
      return Future<Either<Failure, List<FailedLineEntity>>>.value(
        const Left<Failure, List<FailedLineEntity>>(
          ValidationFailure('Sales order and company are required'),
        ),
      );
    }
    return _repository.getFailedLines(
      salesId: salesId,
      company: company,
      mode: mode,
    );
  }
}
