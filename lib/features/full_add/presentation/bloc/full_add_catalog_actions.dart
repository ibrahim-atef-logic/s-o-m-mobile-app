import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/barcode_item_entity.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../../../catalog/domain/entities/price_info_entity.dart';
import '../../../catalog/domain/entities/warehouse_on_hand_entity.dart';
import '../../../catalog/domain/usecases/get_on_hand_usecase.dart';
import '../../../catalog/domain/usecases/lookup_barcode_usecase.dart';
import '../../../catalog/domain/usecases/lookup_item_usecase.dart';
import '../../../catalog/domain/usecases/resolve_price_usecase.dart';
import '../../../catalog/domain/usecases/submit_full_line_usecase.dart';
import '../../../sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../domain/entities/full_cart_item_entity.dart';
import '../../domain/full_add_display_unit.dart';

/// Side-effect helpers for FullAddBloc catalog calls.
class FullAddCatalogActions {
  FullAddCatalogActions({
    required LookupBarcodeUseCase lookupBarcodeUseCase,
    required LookupItemUseCase lookupItemUseCase,
    required ResolvePriceUseCase resolvePriceUseCase,
    required GetOnHandUseCase getOnHandUseCase,
    required SubmitFullLineUseCase submitFullLineUseCase,
    String? sessionWarehouse,
    int? sessionChannelRecId,
    String? sessionCurrency,
  }) : _lookupBarcodeUseCase = lookupBarcodeUseCase,
       _lookupItemUseCase = lookupItemUseCase,
       _resolvePriceUseCase = resolvePriceUseCase,
       _getOnHandUseCase = getOnHandUseCase,
       _submitFullLineUseCase = submitFullLineUseCase,
       _sessionWarehouse = sessionWarehouse,
       _sessionChannelRecId = sessionChannelRecId,
       _sessionCurrency = sessionCurrency;

  final LookupBarcodeUseCase _lookupBarcodeUseCase;
  final LookupItemUseCase _lookupItemUseCase;
  final ResolvePriceUseCase _resolvePriceUseCase;
  final GetOnHandUseCase _getOnHandUseCase;
  final SubmitFullLineUseCase _submitFullLineUseCase;
  final String? _sessionWarehouse;
  final int? _sessionChannelRecId;
  final String? _sessionCurrency;

  Future<Either<Failure, BarcodeItemEntity>> lookup({
    required String barcode,
    required String company,
    bool byItem = false,
  }) {
    if (byItem) {
      return _lookupItemUseCase(itemNumber: barcode, company: company);
    }
    return _lookupBarcodeUseCase(code: barcode, company: company);
  }

  /// Prefer inventory unit, else barcode/item unitId.
  /// Unit conversion fallback (حبة / empty) is owned by the API.
  Future<Either<Failure, PriceInfoEntity>> resolvePrice({
    required BarcodeItemEntity item,
    required SalesOrderHeaderEntity order,
    String? inventoryUnit,
  }) async {
    final String preferred = FullAddDisplayUnit.resolve(
          inventoryUnit: inventoryUnit,
          lookupUnitId: item.unitId,
        ) ??
        '';
    final Either<Failure, PriceInfoEntity> result = await _resolvePriceUseCase(
      itemNumber: item.itemNumber,
      company: order.dataArea,
      salesUnitId: preferred,
      warehouseId: _resolvedWarehouse(order),
      channelRecId: _sessionChannelRecId,
    );
    return result.map(
      (PriceInfoEntity price) => price.withCurrencyFallback(_sessionCurrency),
    );
  }

  Future<Either<Failure, WarehouseOnHandEntity>> getOnHand({
    required BarcodeItemEntity item,
    required SalesOrderHeaderEntity order,
  }) {
    return _getOnHandUseCase(
      itemNumber: item.itemNumber,
      warehouse: _resolvedWarehouse(order) ?? '',
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
    String? inventoryUnit,
  }) {
    final String? displayUnit = FullAddDisplayUnit.resolve(
      inventoryUnit: inventoryUnit,
      lookupUnitId: item.unitId,
    );
    return FullCartItemEntity(
      barcode: item.barcode,
      itemNumber: item.itemNumber,
      productName: item.productName,
      quantity: qty,
      price: submit.item?.price ?? price?.price,
      unitId: submit.item?.unitId ?? displayUnit ?? price?.unitId,
      posted: true,
    );
  }

  String? _resolvedWarehouse(SalesOrderHeaderEntity order) {
    final String fromOrder = order.inventLocationId.trim();
    if (fromOrder.isNotEmpty) {
      return fromOrder;
    }
    final String session = _sessionWarehouse?.trim() ?? '';
    return session.isEmpty ? null : session;
  }
}
