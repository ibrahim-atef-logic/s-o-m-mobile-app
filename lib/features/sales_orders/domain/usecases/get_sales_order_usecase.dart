import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/sales_order_header_entity.dart';
import '../repositories/sales_orders_repository.dart';

class GetSalesOrderUseCase {
  const GetSalesOrderUseCase(this._repository);

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
    return _repository.getOrder(
      salesId: salesId.trim(),
      company: company.trim(),
    );
  }
}
