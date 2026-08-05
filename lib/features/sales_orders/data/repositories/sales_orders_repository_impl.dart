import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/sales_order_header_entity.dart';
import '../../domain/entities/sales_order_line_entity.dart';
import '../../domain/repositories/sales_orders_repository.dart';
import '../datasources/sales_orders_remote_data_source.dart';
import '../models/sales_order_header_model.dart';
import '../models/sales_order_line_model.dart';

class SalesOrdersRepositoryImpl implements SalesOrdersRepository {
  SalesOrdersRepositoryImpl(this._remote);

  final SalesOrdersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<SalesOrderHeaderEntity>>> getMyOrders({
    required String company,
  }) async {
    try {
      final List<SalesOrderHeaderModel> models = await _remote.getMyOrders(
        company: company,
      );
      return Right<Failure, List<SalesOrderHeaderEntity>>(
        models.map((SalesOrderHeaderModel m) => m.toEntity()).toList(),
      );
    } on AuthException catch (e) {
      return Left<Failure, List<SalesOrderHeaderEntity>>(
        AuthFailure(e.message),
      );
    } on NetworkException {
      return const Left<Failure, List<SalesOrderHeaderEntity>>(
        NetworkFailure(),
      );
    } on ServerException catch (e) {
      return Left<Failure, List<SalesOrderHeaderEntity>>(
        ServerFailure(e.message),
      );
    }
  }

  @override
  Future<Either<Failure, List<SalesOrderLineEntity>>> getOrderLines({
    required String salesId,
    required String company,
  }) async {
    try {
      final List<SalesOrderLineModel> models = await _remote.getOrderLines(
        salesId: salesId,
        company: company,
      );
      return Right<Failure, List<SalesOrderLineEntity>>(
        models.map((SalesOrderLineModel m) => m.toEntity()).toList(),
      );
    } on AuthException catch (e) {
      return Left<Failure, List<SalesOrderLineEntity>>(AuthFailure(e.message));
    } on NetworkException {
      return const Left<Failure, List<SalesOrderLineEntity>>(NetworkFailure());
    } on ServerException catch (e) {
      return Left<Failure, List<SalesOrderLineEntity>>(
        ServerFailure(e.message),
      );
    }
  }
}
