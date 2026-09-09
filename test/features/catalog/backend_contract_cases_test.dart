import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/api_error_code.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/core/utils/scan_code.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_submit_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_barcode_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_item_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_full_line_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_quick_batch_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

/// Contract cases from the live backend report (mm / logic-trial).
void main() {
  late MockCatalogRepository repo;
  late LookupBarcodeUseCase lookupBarcode;
  late LookupItemUseCase lookupItem;
  late SubmitFullLineUseCase submitFull;
  late SubmitQuickBatchUseCase submitQuick;

  const BarcodeItemEntity bosch = BarcodeItemEntity(
    barcode: Fixtures.barcode,
    itemNumber: Fixtures.itemNumber,
    productName: 'دريل كهربائي بوش 550',
    productDescription: 'Bosch',
    unitId: 'حبة',
    dataArea: Fixtures.legalEntity,
  );

  const BarcodeItemEntity spacedItem = BarcodeItemEntity(
    barcode: '8901427001262',
    itemNumber: '1500 ML',
    productName: '1500 ML',
    productDescription: '',
    unitId: 'pcs',
    dataArea: Fixtures.legalEntity,
  );

  setUp(() {
    repo = MockCatalogRepository();
    lookupBarcode = LookupBarcodeUseCase(repo);
    lookupItem = LookupItemUseCase(repo);
    submitFull = SubmitFullLineUseCase(repo);
    submitQuick = SubmitQuickBatchUseCase(repo);
  });

  group('ScanCode / space policy', () {
    test('strips CR LF tab only — keeps internal and end spaces', () {
      expect(ScanCode.stripControls('${Fixtures.barcode}\r\n'), Fixtures.barcode);
      expect(ScanCode.stripControls('BG 410.003'), 'BG 410.003');
      expect(ScanCode.stripControls('  BG410.003  '), '  BG410.003  ');
      expect(ScanCode.stripControls('1500 ML'), '1500 ML');
      expect(ScanCode.isBlank('   '), isTrue);
      expect(ScanCode.isBlank('\t\r\n'), isTrue);
    });
  });

  group('Barcode lookup (B1–B3)', () {
    test('B1 forwards 6287007961754 exactly', () async {
      when(
        () => repo.lookupBarcode(
          code: any(named: 'code'),
          company: any(named: 'company'),
        ),
      ).thenAnswer((_) async => const Right(bosch));

      final Either<Failure, BarcodeItemEntity> result = await lookupBarcode(
        code: Fixtures.barcode,
        company: Fixtures.legalEntity,
      );

      expect(result, const Right(bosch));
      verify(
        () => repo.lookupBarcode(
          code: Fixtures.barcode,
          company: Fixtures.legalEntity,
        ),
      ).called(1);
    });

    test('B3 padded barcode is forwarded without trim', () async {
      when(
        () => repo.lookupBarcode(
          code: any(named: 'code'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          ServerFailure('BARCODE_NOT_FOUND: Barcode not found'),
        ),
      );

      final Either<Failure, BarcodeItemEntity> result = await lookupBarcode(
        code: '  ${Fixtures.barcode}  ',
        company: Fixtures.legalEntity,
      );

      expect(result.isLeft(), isTrue);
      verify(
        () => repo.lookupBarcode(
          code: '  ${Fixtures.barcode}  ',
          company: Fixtures.legalEntity,
        ),
      ).called(1);
      expect(
        (result as Left<Failure, BarcodeItemEntity>).value.isItemNotFound,
        isTrue,
      );
    });
  });

  group('Item lookup (C1–C5)', () {
    test('C1 BG410.003 success', () async {
      when(
        () => repo.lookupItem(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
        ),
      ).thenAnswer((_) async => const Right(bosch));

      final Either<Failure, BarcodeItemEntity> result = await lookupItem(
        itemNumber: Fixtures.itemNumber,
        company: Fixtures.legalEntity,
      );

      expect(result, const Right(bosch));
    });

    test('C2 BG 410.003 kept with internal space (no collapse)', () async {
      when(
        () => repo.lookupItem(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          ServerFailure('ITEM_NOT_FOUND: Item not found'),
        ),
      );

      await lookupItem(itemNumber: 'BG 410.003', company: Fixtures.legalEntity);

      verify(
        () => repo.lookupItem(
          itemNumber: 'BG 410.003',
          company: Fixtures.legalEntity,
        ),
      ).called(1);
    });

    test('C3 padded item number forwarded raw', () async {
      when(
        () => repo.lookupItem(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
        ),
      ).thenAnswer((_) async => const Right(bosch));

      await lookupItem(
        itemNumber: '  BG410.003  ',
        company: Fixtures.legalEntity,
      );

      verify(
        () => repo.lookupItem(
          itemNumber: '  BG410.003  ',
          company: Fixtures.legalEntity,
        ),
      ).called(1);
    });

    test('C5 live spaced ItemId 1500 ML forwarded exactly', () async {
      when(
        () => repo.lookupItem(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
        ),
      ).thenAnswer((_) async => const Right(spacedItem));

      final Either<Failure, BarcodeItemEntity> result = await lookupItem(
        itemNumber: '1500 ML',
        company: Fixtures.legalEntity,
      );

      expect(result, const Right(spacedItem));
      verify(
        () => repo.lookupItem(
          itemNumber: '1500 ML',
          company: Fixtures.legalEntity,
        ),
      ).called(1);
    });
  });

  group('API error codes (A3, delete, stock, max lines)', () {
    test('FORBIDDEN_COMPANY is recognized', () {
      const Failure f = ServerFailure(
        'FORBIDDEN_COMPANY: Company not allowed for token',
      );
      expect(f.isForbiddenCompany, isTrue);
    });

    test('BARCODE_NOT_FOUND and ITEM_NOT_FOUND map as item-not-found', () {
      const Failure barcode = ServerFailure(
        'BARCODE_NOT_FOUND: Barcode not found',
      );
      const Failure item = ServerFailure('ITEM_NOT_FOUND: Item not found');
      expect(barcode.isItemNotFound, isTrue);
      expect(item.isItemNotFound, isTrue);
    });

    test('LINE_NOT_FOUND treat-as-gone flag', () {
      const Failure f = ServerFailure('LINE_NOT_FOUND: Line not found');
      expect(f.isLineNotFound, isTrue);
    });

    test('ORDER_NOT_EDITABLE and SO_NOT_OPEN lock flags', () {
      const Failure locked = ServerFailure(
        'ORDER_NOT_EDITABLE: Order is not editable (posted or confirmed). '
        'الأمر غير قابل للتعديل (مرحّل أو مؤكد). (salesId).',
      );
      const Failure closed = ServerFailure(
        'SO_NOT_OPEN: Sales order is not open',
      );
      expect(locked.isOrderNotEditable, isTrue);
      expect(closed.isSoNotOpen, isTrue);
      expect(locked.isOrderLockedForEdit, isTrue);
      expect(closed.isOrderLockedForEdit, isTrue);
    });

    test('NO_STOCK and QTY_EXCEEDS_STOCK flags', () {
      const Failure stock = ServerFailure('NO_STOCK: No available stock');
      const Failure qty = ServerFailure(
        'QTY_EXCEEDS_STOCK: Quantity exceeds available sales qty',
      );
      expect(stock.isNoStock, isTrue);
      expect(qty.isQtyExceedsStock, isTrue);
    });

    test('LINE_ALREADY_EXISTS and MAX_LINES flags', () {
      const Failure dup = ServerFailure(
        'LINE_ALREADY_EXISTS: Item BG410.003 is already on sales order',
      );
      const Failure max = ValidationFailure(
        'MAX_LINES: Quick add allows max 10 lines',
      );
      expect(dup.isLineAlreadyExists, isTrue);
      expect(max.isMaxLines, isTrue);
    });

    test('NO_PRICE flag', () {
      const Failure f = ServerFailure('NO_PRICE: Price not found');
      expect(f.isNoPrice, isTrue);
    });
  });

  group('Auto full vs Manual quick', () {
    test('submitFullLine forwards itemNumber and quantity', () async {
      when(
        () => repo.submitFullLine(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          itemNumber: any(named: 'itemNumber'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          LineSubmitResultEntity(success: true),
        ),
      );

      await submitFull(
        salesId: Fixtures.salesId,
        company: Fixtures.legalEntity,
        itemNumber: Fixtures.itemNumber,
        quantity: 1,
      );

      verify(
        () => repo.submitFullLine(
          salesId: Fixtures.salesId,
          company: Fixtures.legalEntity,
          itemNumber: Fixtures.itemNumber,
          quantity: 1,
        ),
      ).called(1);
    });

    test('quick batch uses barcode lines and rejects 11th locally', () async {
      final List<({String barcode, num quantity})> eleven =
          List<({String barcode, num quantity})>.generate(
            11,
            (int i) => (barcode: 'bc$i', quantity: 1),
          );

      final Either<Failure, LineSubmitResultEntity> result = await submitQuick(
        salesId: Fixtures.salesId,
        company: Fixtures.legalEntity,
        lines: eleven,
      );

      expect(result.isLeft(), isTrue);
      final Failure failure =
          (result as Left<Failure, LineSubmitResultEntity>).value;
      expect(failure.isMaxLines, isTrue);
      verifyNever(
        () => repo.submitQuickBatch(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          lines: any(named: 'lines'),
        ),
      );
    });

    test('quick batch of 10 barcodes is accepted for repository call', () async {
      when(
        () => repo.submitQuickBatch(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          lines: any(named: 'lines'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          LineSubmitResultEntity(success: true),
        ),
      );

      final List<({String barcode, num quantity})> ten =
          List<({String barcode, num quantity})>.generate(
            10,
            (int i) => (barcode: 'bc$i', quantity: 1),
          );

      final Either<Failure, LineSubmitResultEntity> result = await submitQuick(
        salesId: Fixtures.salesId,
        company: Fixtures.legalEntity,
        lines: ten,
      );

      expect(result.isRight(), isTrue);
      verify(
        () => repo.submitQuickBatch(
          salesId: Fixtures.salesId,
          company: Fixtures.legalEntity,
          lines: ten,
        ),
      ).called(1);
    });
  });
}
