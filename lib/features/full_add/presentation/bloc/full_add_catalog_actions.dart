import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/barcode_item_entity.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../../../catalog/domain/entities/price_info_entity.dart';
import '../../../catalog/domain/entities/warehouse_on_hand_entity.dart';
import '../../../catalog/domain/usecases/get_on_hand_usecase.dart';
import '../../../catalog/domain/usecases/lookup_barcode_usecase.dart';
import '../../../catalog/domain/usecases/resolve_price_usecase.dart';
import '../../../catalog/domain/usecases/submit_full_line_usecase.dart';
import '../../../sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../domain/entities/full_cart_item_entity.dart';

/// Side-effect helpers for FullAddBloc catalog calls.
class FullAddCatalogActions {
  FullAddCatalogActions({
    required LookupBarcodeUseCase lookupBarcodeUseCase,
    required ResolvePriceUseCase resolvePriceUseCase,
    required GetOnHandUseCase getOnHandUseCase,
    required SubmitFullLineUseCase submitFullLineUseCase,
  }) : _lookupBarcodeUseCase = lookupBarcodeUseCase,
       _resolvePriceUseCase = resolvePriceUseCase,
       _getOnHandUseCase = getOnHandUseCase,
       _submitFullLineUseCase = submitFullLineUseCase;

  final LookupBarcodeUseCase _lookupBarcodeUseCase;
  final ResolvePriceUseCase _resolvePriceUseCase;
  final GetOnHandUseCase _getOnHandUseCase;
  final SubmitFullLineUseCase _submitFullLineUseCase;

  Future<Either<Failure, BarcodeItemEntity>> lookup({
    required String barcode,
    required String company,
  }) {
    return _lookupBarcodeUseCase(code: barcode, company: company);
  }

  Future<Either<Failure, PriceInfoEntity>> resolvePrice({
    required BarcodeItemEntity item,
    required SalesOrderHeaderEntity order,
  }) {
    return _resolvePriceUseCase(
      itemNumber: item.itemNumber,
      company: order.dataArea,
      custAccount: order.custAccount,
      priceGroup: order.priceGroupId,
    );
  }

  Future<Either<Failure, WarehouseOnHandEntity>> getOnHand({
    required BarcodeItemEntity item,
    required SalesOrderHeaderEntity order,
  }) {
    return _getOnHandUseCase(
      itemNumber: item.itemNumber,
      warehouse: order.inventLocationId,
      company: order.dataArea,
    );
  }

  Future<Either<Failure, LineSubmitResultEntity>> submit({
    required SalesOrderHeaderEntity order,
    required String itemNumber,
    required int quantity,
  }) {
    return _submitFullLineUseCase(
      salesId: order.salesId,
      company: order.dataArea,
      itemNumber: itemNumber,
      quantity: quantity,
    );
  }

  FullCartItemEntity toCartItem({
    required BarcodeItemEntity item,
    required int qty,
    required LineSubmitResultEntity submit,
    PriceInfoEntity? price,
  }) {
    return FullCartItemEntity(
      barcode: item.barcode,
      itemNumber: item.itemNumber,
      productName: item.productName,
      quantity: qty,
      price: submit.item?.price ?? price?.price,
      unitId: submit.item?.unitId ?? price?.unitId,
    );
  }
}
