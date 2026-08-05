import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/sales_order_header_entity.dart';
import '../repositories/sales_orders_repository.dart';

class GetMySalesOrdersUseCase {
  const GetMySalesOrdersUseCase(this._repository);

  final SalesOrdersRepository _repository;

  Future<Either<Failure, List<SalesOrderHeaderEntity>>> call({
    required String company,
  }) {
    if (company.trim().isEmpty) {
      return Future<Either<Failure, List<SalesOrderHeaderEntity>>>.value(
        const Left<Failure, List<SalesOrderHeaderEntity>>(
          ValidationFailure('Company is required'),
        ),
      );
    }
    return _repository.getMyOrders(company: company.trim());
  }
}
