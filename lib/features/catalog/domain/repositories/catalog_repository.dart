import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/barcode_item_entity.dart';
import '../entities/failed_line_entity.dart';
import '../entities/line_submit_result_entity.dart';
import '../entities/price_info_entity.dart';
import '../entities/warehouse_on_hand_entity.dart';

abstract class CatalogRepository {
  Future<Either<Failure, BarcodeItemEntity>> lookupBarcode({
    required String code,
    required String company,
  });

  Future<Either<Failure, PriceInfoEntity>> resolvePrice({
    required String itemNumber,
    required String company,
    required String custAccount,
    required String priceGroup,
    String? unitId,
  });

  Future<Either<Failure, WarehouseOnHandEntity>> getOnHand({
    required String itemNumber,
    required String warehouse,
    required String company,
  });

  Future<Either<Failure, LineSubmitResultEntity>> submitFullLine({
    required String salesId,
    required String company,
    required String itemNumber,
    required num quantity,
  });

  Future<Either<Failure, LineSubmitResultEntity>> submitQuickBatch({
    required String salesId,
    required String company,
    required List<({String barcode, num quantity})> lines,
  });

  Future<Either<Failure, List<FailedLineEntity>>> getFailedLines({
    required String salesId,
    required String company,
    String? mode,
  });
}
