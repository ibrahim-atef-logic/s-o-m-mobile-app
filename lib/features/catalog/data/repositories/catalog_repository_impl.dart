import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/barcode_item_entity.dart';
import '../../domain/entities/failed_line_entity.dart';
import '../../domain/entities/line_submit_result_entity.dart';
import '../../domain/entities/price_info_entity.dart';
import '../../domain/entities/warehouse_on_hand_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';
import '../models/barcode_item_model.dart';
import '../models/failed_line_model.dart';
import '../models/line_submit_result_model.dart';
import '../models/price_info_model.dart';
import '../models/warehouse_on_hand_model.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<Either<Failure, BarcodeItemEntity>> lookupBarcode({
    required String code,
    required String company,
  }) async {
    try {
      final BarcodeItemModel model = await _remote.lookupBarcode(
        code: code,
        company: company,
      );
      return Right<Failure, BarcodeItemEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, BarcodeItemEntity>(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, PriceInfoEntity>> resolvePrice({
    required String itemNumber,
    required String company,
    required String custAccount,
    required String priceGroup,
  }) async {
    try {
      final PriceInfoModel model = await _remote.resolvePrice(
        itemNumber: itemNumber,
        company: company,
        custAccount: custAccount,
        priceGroup: priceGroup,
      );
      return Right<Failure, PriceInfoEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, PriceInfoEntity>(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, WarehouseOnHandEntity>> getOnHand({
    required String itemNumber,
    required String warehouse,
    required String company,
  }) async {
    try {
      final WarehouseOnHandModel model = await _remote.getOnHand(
        itemNumber: itemNumber,
        warehouse: warehouse,
        company: company,
      );
      return Right<Failure, WarehouseOnHandEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, WarehouseOnHandEntity>(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, LineSubmitResultEntity>> submitFullLine({
    required String salesId,
    required String company,
    required String itemNumber,
    required num quantity,
  }) async {
    try {
      final LineSubmitResultModel model = await _remote.submitFullLine(
        salesId: salesId,
        company: company,
        itemNumber: itemNumber,
        quantity: quantity,
      );
      return Right<Failure, LineSubmitResultEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, LineSubmitResultEntity>(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, LineSubmitResultEntity>> submitQuickBatch({
    required String salesId,
    required String company,
    required List<({String barcode, num quantity})> lines,
  }) async {
    try {
      final LineSubmitResultModel model = await _remote.submitQuickBatch(
        salesId: salesId,
        company: company,
        lines: lines
            .map(
              (({String barcode, num quantity}) l) => <String, Object>{
                'barcode': l.barcode,
                'quantity': l.quantity,
              },
            )
            .toList(),
      );
      return Right<Failure, LineSubmitResultEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, LineSubmitResultEntity>(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<FailedLineEntity>>> getFailedLines({
    required String salesId,
    required String company,
    String? mode,
  }) async {
    try {
      final List<FailedLineModel> models = await _remote.getFailedLines(
        salesId: salesId,
        company: company,
        mode: mode,
      );
      return Right<Failure, List<FailedLineEntity>>(
        models.map((FailedLineModel m) => m.toEntity()).toList(),
      );
    } catch (e) {
      return Left<Failure, List<FailedLineEntity>>(_toFailure(e));
    }
  }

  Failure _toFailure(Object e) {
    if (e is AuthException) return AuthFailure(e.message);
    if (e is NetworkException) return const NetworkFailure();
    if (e is ServerException) return ServerFailure(e.message);
    return ServerFailure(e.toString());
  }
}
