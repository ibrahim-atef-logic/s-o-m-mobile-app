import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/sales_orders_repository.dart';

/// Deletes one Dynamics line by RecId.
class DeleteSalesOrderLineUseCase {
  const DeleteSalesOrderLineUseCase(this._repository);

  final SalesOrdersRepository _repository;

  Future<Either<Failure, void>> call({
    required String salesId,
    required String company,
    required int recordId,
  }) {
    if (salesId.trim().isEmpty || company.trim().isEmpty || recordId <= 0) {
      return Future<Either<Failure, void>>.value(
        const Left<Failure, void>(ValidationFailure('LINE_DELETE_INVALID')),
      );
    }
    return _repository.deleteOrderLine(
      salesId: salesId.trim(),
      company: company.trim(),
      recordId: recordId,
    );
  }
}
