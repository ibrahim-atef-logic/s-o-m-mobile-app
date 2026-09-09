import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/created_order_entity.dart';
import '../../domain/entities/sales_order_header_entity.dart';
import '../../domain/entities/sales_order_line_entity.dart';
import '../../domain/repositories/sales_orders_repository.dart';
import '../datasources/sales_orders_remote_data_source.dart';
import '../models/created_order_model.dart';
import '../models/sales_order_header_model.dart';
import '../models/sales_order_line_model.dart';

class SalesOrdersRepositoryImpl implements SalesOrdersRepository {
  SalesOrdersRepositoryImpl(this._remote);

  final SalesOrdersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<SalesOrderHeaderEntity>>> getMyOrders({
    required String company,
  }) {
    return _guard<List<SalesOrderHeaderEntity>>(() async {
      final List<SalesOrderHeaderModel> models = await _remote.getMyOrders(
        company: company,
      );
      return models.map((SalesOrderHeaderModel m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, SalesOrderHeaderEntity>> getOrder({
    required String salesId,
    required String company,
  }) {
    return _guard<SalesOrderHeaderEntity>(() async {
      final SalesOrderHeaderModel model = await _remote.getOrder(
        salesId: salesId,
        company: company,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, SalesOrderHeaderEntity>> refreshOrder({
    required String salesId,
    required String company,
  }) {
    return _guard<SalesOrderHeaderEntity>(() async {
      final SalesOrderHeaderModel model = await _remote.refreshOrder(
        salesId: salesId,
        company: company,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<SalesOrderLineEntity>>> getOrderLines({
    required String salesId,
    required String company,
    int top = 50,
    int skip = 0,
  }) {
    return _guard<List<SalesOrderLineEntity>>(() async {
      final List<SalesOrderLineModel> models = await _remote.getOrderLines(
        salesId: salesId,
        company: company,
        top: top,
        skip: skip,
      );
      return models.map((SalesOrderLineModel m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, void>> deleteOrderLine({
    required String salesId,
    required String company,
    required int recordId,
  }) {
    return _guard<void>(() {
      return _remote.deleteOrderLine(
        salesId: salesId,
        company: company,
        recordId: recordId,
      );
    });
  }

  @override
  Future<Either<Failure, CreatedOrderEntity>> createOrder({
    required String company,
    required String custAccount,
    String? inventLocationId,
    String? inventSiteId,
    String? currencyCode,
  }) {
    return _guard<CreatedOrderEntity>(() async {
      final CreatedOrderModel model = await _remote.createOrder(
        company: company,
        custAccount: custAccount,
        inventLocationId: inventLocationId,
        inventSiteId: inventSiteId,
        currencyCode: currencyCode,
      );
      return model.toEntity();
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right<Failure, T>(await action());
    } on AuthException catch (e) {
      return Left<Failure, T>(AuthFailure(e.message));
    } on NetworkException {
      return Left<Failure, T>(const NetworkFailure());
    } on ServerException catch (e) {
      return Left<Failure, T>(ServerFailure(e.message));
    }
  }
}
