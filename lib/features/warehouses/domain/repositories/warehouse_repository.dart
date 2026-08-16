import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/warehouse_entity.dart';

abstract class WarehouseRepository {
  Future<Either<Failure, List<WarehouseEntity>>> getWarehouses(String company);
}
