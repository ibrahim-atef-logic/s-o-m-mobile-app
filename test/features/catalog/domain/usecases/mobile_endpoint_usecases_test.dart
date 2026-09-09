import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/failed_line_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_submit_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/price_info_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/warehouse_on_hand_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_failed_lines_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_on_hand_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_barcode_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_item_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/delete_sales_order_line_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/resolve_price_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_full_line_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_quick_batch_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_line_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/repositories/sales_orders_repository.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_my_sales_orders_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_sales_order_lines_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockSalesOrdersRepository extends Mock implements SalesOrdersRepository {}

/// Unit coverage for every mobile-backed API use case (company=mm).
void main() {
  late MockCatalogRepository catalog;
  late MockSalesOrdersRepository salesOrders;

  const String company = 'mm';
  const String salesId = 'MM-245265';

  setUp(() {
    catalog = MockCatalogRepository();
    salesOrders = MockSalesOrdersRepository();
  });

  group('GET /api/v1/sales-orders', () {
    test('returns orders for company', () async {
      const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
        salesId: salesId,
        custAccount: 'TR-001',
        salesName: 'Logic Trial Retail',
        salesStatus: 'Backorder',
        documentStatus: 'None',
        dataArea: company,
        priceGroupId: 'Retail',
        inventLocationId: '11',
        inventSiteId: '1',
        createdDateTime: '2026-01-01',
      );
      when(() => salesOrders.getMyOrders(company: company)).thenAnswer(
        (_) async => const Right<Failure, List<SalesOrderHeaderEntity>>(
          <SalesOrderHeaderEntity>[order],
        ),
      );

      final Either<Failure, List<SalesOrderHeaderEntity>> result =
          await GetMySalesOrdersUseCase(salesOrders)(company: company);

      expect(result.isRight(), isTrue);
      verify(() => salesOrders.getMyOrders(company: company)).called(1);
    });

    test('empty company → ValidationFailure', () async {
      final Either<Failure, List<SalesOrderHeaderEntity>> result =
          await GetMySalesOrdersUseCase(salesOrders)(company: '  ');
      expect(result.isLeft(), isTrue);
    });
  });

  group('GET /api/v1/sales-orders/:id/lines', () {
    test('returns lines', () async {
      when(
        () => salesOrders.getOrderLines(
          salesId: salesId,
          company: company,
          top: any(named: 'top'),
          skip: any(named: 'skip'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<SalesOrderLineEntity>>(
          <SalesOrderLineEntity>[
            SalesOrderLineEntity(
              recordId: 2,
              salesId: salesId,
              itemId: 'ITEM-100',
              productName: 'Demo',
              salesQty: 1,
              salesUnit: 'ea',
              lineNum: 1,
              dataArea: company,
            ),
          ],
        ),
      );

      final Either<Failure, List<SalesOrderLineEntity>> result =
          await GetSalesOrderLinesUseCase(salesOrders)(
            salesId: salesId,
            company: company,
          );

      expect(result.isRight(), isTrue);
    });
  });

  group('GET /api/v1/barcodes/:code', () {
    test('lookup success', () async {
      const BarcodeItemEntity item = BarcodeItemEntity(
        barcode: 'BC-100',
        itemNumber: 'ITEM-200',
        productName: 'Scan Item',
        productDescription: '',
        unitId: 'ea',
        dataArea: company,
      );
      when(
        () => catalog.lookupBarcode(code: 'BC-100', company: company),
      ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(item));

      final Either<Failure, BarcodeItemEntity> result =
          await LookupBarcodeUseCase(catalog)(code: 'BC-100', company: company);

      expect(result, const Right<Failure, BarcodeItemEntity>(item));
    });

    test('empty barcode → ValidationFailure', () async {
      final Either<Failure, BarcodeItemEntity> result =
          await LookupBarcodeUseCase(catalog)(code: ' ', company: company);
      expect(result.isLeft(), isTrue);
    });
  });

  group('GET /api/v1/items/:itemNumber', () {
    test('lookup item success', () async {
      const BarcodeItemEntity item = BarcodeItemEntity(
        barcode: '6287007961754',
        itemNumber: 'BG410.003',
        productName: 'Drill',
        productDescription: '',
        unitId: 'ea',
        dataArea: company,
      );
      when(
        () => catalog.lookupItem(
          itemNumber: 'BG410.003',
          company: company,
        ),
      ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(item));

      final Either<Failure, BarcodeItemEntity> result =
          await LookupItemUseCase(catalog)(
            itemNumber: 'BG410.003',
            company: company,
          );

      expect(result, const Right<Failure, BarcodeItemEntity>(item));
    });
  });

  group('DELETE /api/v1/sales-orders/:id/lines/:recordId', () {
    test('delegates delete', () async {
      when(
        () => salesOrders.deleteOrderLine(
          salesId: salesId,
          company: company,
          recordId: 123,
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      final Either<Failure, void> result = await DeleteSalesOrderLineUseCase(
        salesOrders,
      )(salesId: salesId, company: company, recordId: 123);

      expect(result.isRight(), isTrue);
    });
  });

  group('POST /api/v1/item-price', () {
    test('resolve price success', () async {
      const PriceInfoEntity price = PriceInfoEntity(
        itemNumber: 'ITEM-200',
        price: 25.5,
        unitId: 'ea',
        currency: 'SAR',
      );
      when(
        () => catalog.resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: any(named: 'salesUnitId'),
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      ).thenAnswer((_) async => const Right<Failure, PriceInfoEntity>(price));

      final Either<Failure, PriceInfoEntity> result =
          await ResolvePriceUseCase(catalog)(
            itemNumber: 'ITEM-200',
            company: company,
            salesUnitId: 'ea',
            warehouseId: '11',
            channelRecId: 1,
          );

      expect(result, const Right<Failure, PriceInfoEntity>(price));
    });
  });

  group('GET /api/v1/inventory', () {
    test('on-hand success', () async {
      const WarehouseOnHandEntity onHand = WarehouseOnHandEntity(
        itemNumber: 'ITEM-200',
        warehouseId: '11',
        availableSalesQuantity: 100,
        availableOnHandQuantity: 100,
        unit: 'ea',
        productName: 'Scan Item',
      );
      when(
        () => catalog.getOnHand(
          itemNumber: any(named: 'itemNumber'),
          warehouse: any(named: 'warehouse'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, WarehouseOnHandEntity>(onHand),
      );

      final Either<Failure, WarehouseOnHandEntity> result =
          await GetOnHandUseCase(catalog)(
            itemNumber: 'ITEM-200',
            warehouse: '11',
            company: company,
          );

      expect(result, const Right<Failure, WarehouseOnHandEntity>(onHand));
    });
  });

  group('POST /lines/full', () {
    test('invalid qty → ValidationFailure', () async {
      final Either<Failure, LineSubmitResultEntity> result =
          await SubmitFullLineUseCase(catalog)(
            salesId: salesId,
            company: company,
            itemNumber: 'ITEM-200',
            quantity: 0,
          );
      expect(result.isLeft(), isTrue);
    });
  });

  group('POST /lines/quick', () {
    test('max 10 lines → ValidationFailure', () async {
      final List<({String barcode, num quantity})> lines =
          List<({String barcode, num quantity})>.generate(
            11,
            (int i) => (barcode: 'B$i', quantity: 1),
          );
      final Either<Failure, LineSubmitResultEntity> result =
          await SubmitQuickBatchUseCase(catalog)(
            salesId: salesId,
            company: company,
            lines: lines,
          );
      expect(
        result,
        const Left<Failure, LineSubmitResultEntity>(
          ValidationFailure('MAX_LINES: Quick add allows max 10 lines'),
        ),
      );
    });
  });

  group('GET /failed-lines', () {
    test('returns empty list', () async {
      when(
        () => catalog.getFailedLines(
          salesId: salesId,
          company: company,
          mode: any(named: 'mode'),
        ),
      ).thenAnswer(
        (_) async =>
            const Right<Failure, List<FailedLineEntity>>(<FailedLineEntity>[]),
      );

      final Either<Failure, List<FailedLineEntity>> result =
          await GetFailedLinesUseCase(catalog)(
            salesId: salesId,
            company: company,
            mode: 'full',
          );

      expect(result.isRight(), isTrue);
    });
  });
}
