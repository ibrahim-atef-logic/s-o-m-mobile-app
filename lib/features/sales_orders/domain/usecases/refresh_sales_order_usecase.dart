import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/sales_order_header_entity.dart';
import '../repositories/sales_orders_repository.dart';

/// Re-reads the sales order header from Dynamics (status + totals).
class RefreshSalesOrderUseCase {
  const RefreshSalesOrderUseCase(this._repository);

  final SalesOrdersRepository _repository;

  Future<Either<Failure, SalesOrderHeaderEntity>> call({
    required String salesId,
    required String company,
  }) {
    if (salesId.trim().isEmpty || company.trim().isEmpty) {
      return Future<Either<Failure, SalesOrderHeaderEntity>>.value(
        const Left<Failure, SalesOrderHeaderEntity>(
          ValidationFailure('Order and company are required'),
        ),
      );
    }
    return _repository.refreshOrder(
      salesId: salesId.trim(),
      company: company.trim(),
    );
  }
}
