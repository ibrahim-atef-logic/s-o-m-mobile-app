import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/sales_order_header_entity.dart';
import '../entities/sales_order_line_entity.dart';

abstract class SalesOrdersRepository {
  Future<Either<Failure, List<SalesOrderHeaderEntity>>> getMyOrders({
    required String company,
  });

  Future<Either<Failure, List<SalesOrderLineEntity>>> getOrderLines({
    required String salesId,
    required String company,
  });
}
