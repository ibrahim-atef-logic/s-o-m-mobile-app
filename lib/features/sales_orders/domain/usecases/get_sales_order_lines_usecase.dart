import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/sales_order_line_entity.dart';
import '../repositories/sales_orders_repository.dart';

class GetSalesOrderLinesUseCase {
  const GetSalesOrderLinesUseCase(this._repository);

  final SalesOrdersRepository _repository;

  Future<Either<Failure, List<SalesOrderLineEntity>>> call({
    required String salesId,
    required String company,
    int top = 50,
    int skip = 0,
  }) {
    return _repository.getOrderLines(
      salesId: salesId,
      company: company,
      top: top,
      skip: skip,
    );
  }
}
