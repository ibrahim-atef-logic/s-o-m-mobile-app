import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../datasources/warehouse_remote_data_source.dart';
import '../models/warehouse_model.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  WarehouseRepositoryImpl(this._remote);

  final WarehouseRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<WarehouseEntity>>> getWarehouses(
    String company,
  ) async {
    try {
      final List<WarehouseModel> models = await _remote.fetchWarehouses(
        company,
      );
      return Right<Failure, List<WarehouseEntity>>(<WarehouseEntity>[
        for (final WarehouseModel model in models)
          if (model.inventLocationId.isNotEmpty) model.toEntity(),
      ]);
    } on AuthException catch (e) {
      return Left<Failure, List<WarehouseEntity>>(AuthFailure(e.message));
    } on NetworkException {
      return const Left<Failure, List<WarehouseEntity>>(NetworkFailure());
    } on ServerException catch (e) {
      return Left<Failure, List<WarehouseEntity>>(ServerFailure(e.message));
    }
  }
}
