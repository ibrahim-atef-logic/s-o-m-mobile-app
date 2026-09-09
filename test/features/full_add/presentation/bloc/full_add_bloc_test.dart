import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_item_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_submit_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/price_info_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/warehouse_on_hand_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_on_hand_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_barcode_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_item_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/resolve_price_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_full_line_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_quick_batch_usecase.dart';
import 'package:logic_retail_mobile/features/full_add/domain/entities/full_cart_item_entity.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/bloc/full_add_bloc.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockLookupBarcodeUseCase extends Mock implements LookupBarcodeUseCase {}

class MockLookupItemUseCase extends Mock implements LookupItemUseCase {}

class MockResolvePriceUseCase extends Mock implements ResolvePriceUseCase {}

class MockGetOnHandUseCase extends Mock implements GetOnHandUseCase {}

class MockSubmitFullLineUseCase extends Mock implements SubmitFullLineUseCase {}

class MockSubmitQuickBatchUseCase extends Mock
    implements SubmitQuickBatchUseCase {}

void main() {
  late MockLookupBarcodeUseCase lookup;
  late MockLookupItemUseCase lookupItem;
  late MockResolvePriceUseCase resolvePrice;
  late MockGetOnHandUseCase getOnHand;
  late MockSubmitFullLineUseCase submit;
  late MockSubmitQuickBatchUseCase submitQuick;

  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: 'SO-000100',
    custAccount: 'US-001',
    salesName: 'Contoso',
    dataArea: 'usmf',
    priceGroupId: 'RETAIL',
    inventLocationId: 'WH-11',
    inventSiteId: '1',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  const SalesOrderHeaderEntity orderWithoutWarehouse = SalesOrderHeaderEntity(
    salesId: 'SO-000100',
    custAccount: 'US-001',
    salesName: 'Contoso',
    dataArea: 'usmf',
    priceGroupId: 'RETAIL',
    inventLocationId: '',
    inventSiteId: '1',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  const BarcodeItemEntity item = BarcodeItemEntity(
    barcode: '6281001000002',
    itemNumber: '2000',
    productName: 'Keyboard',
    productDescription: 'KB',
    unitId: 'ea',
    dataArea: 'usmf',
  );

  const PriceInfoEntity price = PriceInfoEntity(
    itemNumber: '2000',
    price: 10,
    unitId: 'pcs',
    currency: 'SAR',
  );

  const WarehouseOnHandEntity onHand = WarehouseOnHandEntity(
    itemNumber: '2000',
    warehouseId: 'WH-11',
    availableSalesQuantity: 40,
    availableOnHandQuantity: 99,
    unit: 'pcs',
    productName: 'Keyboard',
  );

  const WarehouseOnHandEntity onHandEmptyUnit = WarehouseOnHandEntity(
    itemNumber: '2000',
    warehouseId: 'WH-11',
    availableSalesQuantity: 5,
    availableOnHandQuantity: 5,
    unit: '',
    productName: 'Keyboard',
  );

  FullAddBloc buildBloc() => FullAddBloc(
    order: order,
    lookupBarcodeUseCase: lookup,
    lookupItemUseCase: lookupItem,
    resolvePriceUseCase: resolvePrice,
    getOnHandUseCase: getOnHand,
    submitFullLineUseCase: submit,
    submitQuickBatchUseCase: submitQuick,
  );

  void stubHappyPath() {
    when(
      () => lookup(
        code: any(named: 'code'),
        company: any(named: 'company'),
      ),
    ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(item));
    when(
      () => resolvePrice(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
        salesUnitId: any(named: 'salesUnitId'),
        warehouseId: any(named: 'warehouseId'),
        channelRecId: any(named: 'channelRecId'),
      ),
    ).thenAnswer((_) async => const Right<Failure, PriceInfoEntity>(price));
    when(
      () => getOnHand(
        itemNumber: any(named: 'itemNumber'),
        warehouse: any(named: 'warehouse'),
        company: any(named: 'company'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, WarehouseOnHandEntity>(onHand),
    );
  }

  setUp(() {
    lookup = MockLookupBarcodeUseCase();
    lookupItem = MockLookupItemUseCase();
    resolvePrice = MockResolvePriceUseCase();
    getOnHand = MockGetOnHandUseCase();
    submit = MockSubmitFullLineUseCase();
    submitQuick = MockSubmitQuickBatchUseCase();
  });

  blocTest<FullAddBloc, FullAddState>(
    'lookup success then inventory without price',
    build: () {
      stubHappyPath();
      return buildBloc();
    },
    act: (FullAddBloc bloc) async {
      bloc.add(const FullAddBarcodeChanged('6281001000002'));
      bloc.add(const FullAddLookupRequested());
    },
    expect: () => <Matcher>[
      isA<FullAddState>(),
      isA<FullAddState>().having(
        (FullAddState s) => s.lookingUp,
        'lookingUp',
        true,
      ),
      isA<FullAddState>()
          .having((FullAddState s) => s.item, 'item', item)
          .having((FullAddState s) => s.fetchingQty, 'fetchingQty', true)
          .having((FullAddState s) => s.quantityText, 'qty empty', ''),
      isA<FullAddState>()
          .having((FullAddState s) => s.onHand, 'onHand', onHand)
          .having((FullAddState s) => s.price, 'price', isNull)
          .having((FullAddState s) => s.fetchingPrice, 'no price fetch', false),
    ],
    verify: (_) {
      verifyNever(
        () => resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: any(named: 'salesUnitId'),
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      );
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'item-number lookup uses LookupItemUseCase not barcode',
    build: () {
      when(
        () => lookupItem(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
        ),
      ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(item));
      when(
        () => resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: any(named: 'salesUnitId'),
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      ).thenAnswer((_) async => const Right<Failure, PriceInfoEntity>(price));
      when(
        () => getOnHand(
          itemNumber: any(named: 'itemNumber'),
          warehouse: any(named: 'warehouse'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, WarehouseOnHandEntity>(onHand),
      );
      return buildBloc();
    },
    act: (FullAddBloc bloc) async {
      bloc.add(const FullAddLookupByItemChanged(true));
      bloc.add(const FullAddBarcodeChanged('BG410.003'));
      bloc.add(const FullAddLookupRequested());
    },
    verify: (_) {
      verify(
        () => lookupItem(itemNumber: 'BG410.003', company: 'usmf'),
      ).called(1);
      verifyNever(
        () => lookup(
          code: any(named: 'code'),
          company: any(named: 'company'),
        ),
      );
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'barcode lookup failure keeps BARCODE_NOT_FOUND',
    build: () {
      when(
        () => lookup(
          code: any(named: 'code'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, BarcodeItemEntity>(
          ServerFailure('BARCODE_NOT_FOUND: Barcode not found'),
        ),
      );
      return buildBloc();
    },
    act: (FullAddBloc bloc) async {
      bloc.add(const FullAddBarcodeChanged('0000000000000'));
      bloc.add(const FullAddLookupRequested());
    },
    expect: () => <Matcher>[
      isA<FullAddState>(),
      isA<FullAddState>().having(
        (FullAddState s) => s.lookingUp,
        'lookingUp',
        true,
      ),
      isA<FullAddState>()
          .having((FullAddState s) => s.lookingUp, 'done', false)
          .having((FullAddState s) => s.item, 'item', isNull)
          .having(
            (FullAddState s) => s.failure?.message,
            'failure',
            contains('BARCODE_NOT_FOUND'),
          ),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'item lookup failure keeps ITEM_NOT_FOUND',
    build: () {
      when(
        () => lookupItem(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, BarcodeItemEntity>(
          ServerFailure('ITEM_NOT_FOUND: Item not found'),
        ),
      );
      return buildBloc();
    },
    act: (FullAddBloc bloc) async {
      bloc.add(const FullAddLookupByItemChanged(true));
      bloc.add(const FullAddBarcodeChanged('NO-SUCH-ITEM'));
      bloc.add(const FullAddLookupRequested());
    },
    expect: () => <Matcher>[
      isA<FullAddState>().having(
        (FullAddState s) => s.lookupByItem,
        'lookupByItem',
        true,
      ),
      isA<FullAddState>(),
      isA<FullAddState>().having(
        (FullAddState s) => s.lookingUp,
        'lookingUp',
        true,
      ),
      isA<FullAddState>()
          .having((FullAddState s) => s.item, 'item', isNull)
          .having(
            (FullAddState s) => s.failure?.message,
            'failure',
            contains('ITEM_NOT_FOUND'),
          ),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'forbidden company surfaces on lookup',
    build: () {
      when(
        () => lookup(
          code: any(named: 'code'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, BarcodeItemEntity>(
          ServerFailure('FORBIDDEN_COMPANY: Company not allowed for token'),
        ),
      );
      return buildBloc();
    },
    act: (FullAddBloc bloc) async {
      bloc.add(const FullAddBarcodeChanged('6287007961754'));
      bloc.add(const FullAddLookupRequested());
    },
    expect: () => <Matcher>[
      isA<FullAddState>(),
      isA<FullAddState>().having(
        (FullAddState s) => s.lookingUp,
        'lookingUp',
        true,
      ),
      isA<FullAddState>().having(
        (FullAddState s) => s.failure?.message,
        'failure',
        contains('FORBIDDEN_COMPANY'),
      ),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'item-price uses inventory unit not barcode unit on submit',
    build: () {
      stubHappyPath();
      when(
        () => submit(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          itemNumber: any(named: 'itemNumber'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, LineSubmitResultEntity>(
          LineSubmitResultEntity(
            success: true,
            item: LineItemResultEntity(
              id: '1',
              itemNumber: '2000',
              quantity: 1,
              status: 'synced',
              price: 10,
              unitId: 'pcs',
            ),
          ),
        ),
      );
      return FullAddBloc(
        order: order,
        lookupBarcodeUseCase: lookup,
        lookupItemUseCase: lookupItem,
        resolvePriceUseCase: resolvePrice,
        getOnHandUseCase: getOnHand,
        submitFullLineUseCase: submit,
        submitQuickBatchUseCase: submitQuick,
        sessionChannelRecId: 5637152827,
        sessionCurrency: 'SAR',
      );
    },
    seed: () => const FullAddState(
      order: order,
      barcode: '6281001000002',
      item: item,
      onHand: onHand,
      quantityText: '1',
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    verify: (_) {
      verify(
        () => resolvePrice(
          itemNumber: '2000',
          company: 'usmf',
          salesUnitId: 'pcs',
          warehouseId: 'WH-11',
          channelRecId: 5637152827,
        ),
      ).called(1);
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'item-price falls back to barcode unit when inventory unit empty',
    build: () {
      stubHappyPath();
      when(
        () => submit(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          itemNumber: any(named: 'itemNumber'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, LineSubmitResultEntity>(
          LineSubmitResultEntity(
            success: true,
            item: LineItemResultEntity(
              id: '1',
              itemNumber: '2000',
              quantity: 1,
              status: 'synced',
              price: 10,
              unitId: 'ea',
            ),
          ),
        ),
      );
      return buildBloc();
    },
    seed: () => const FullAddState(
      order: order,
      barcode: '6281001000002',
      item: item,
      onHand: onHandEmptyUnit,
      quantityText: '1',
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    verify: (_) {
      verify(
        () => resolvePrice(
          itemNumber: '2000',
          company: 'usmf',
          salesUnitId: 'ea',
          warehouseId: 'WH-11',
          channelRecId: null,
        ),
      ).called(1);
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'inventory failure does not call item-price on lookup',
    build: () {
      when(
        () => lookup(
          code: any(named: 'code'),
          company: any(named: 'company'),
        ),
      ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(item));
      when(
        () => getOnHand(
          itemNumber: any(named: 'itemNumber'),
          warehouse: any(named: 'warehouse'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, WarehouseOnHandEntity>(
          ServerFailure('NO_STOCK'),
        ),
      );
      return buildBloc();
    },
    act: (FullAddBloc bloc) async {
      bloc.add(const FullAddBarcodeChanged('6281001000002'));
      bloc.add(const FullAddLookupRequested());
    },
    verify: (_) {
      verifyNever(
        () => resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: any(named: 'salesUnitId'),
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      );
    },
    expect: () => <Matcher>[
      isA<FullAddState>(),
      isA<FullAddState>().having(
        (FullAddState s) => s.lookingUp,
        'lookingUp',
        true,
      ),
      isA<FullAddState>().having((FullAddState s) => s.item, 'item', item),
      isA<FullAddState>()
          .having((FullAddState s) => s.onHand, 'onHand', isNull)
          .having(
            (FullAddState s) => s.validation,
            'noStock',
            FullAddValidation.noStock,
          )
          .having((FullAddState s) => s.price, 'price', isNull),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'ITEM_NOT_FOUND on submit leaves price empty with noPrice validation',
    build: () {
      when(
        () => resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: any(named: 'salesUnitId'),
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, PriceInfoEntity>(
          ServerFailure('ITEM_NOT_FOUND: Item not found'),
        ),
      );
      return buildBloc();
    },
    seed: () => const FullAddState(
      order: order,
      barcode: '6281001000002',
      item: item,
      onHand: onHand,
      quantityText: '1',
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    expect: () => <Matcher>[
      isA<FullAddState>().having(
        (FullAddState s) => s.fetchingPrice,
        'fetchingPrice',
        true,
      ),
      isA<FullAddState>()
          .having((FullAddState s) => s.price, 'price', isNull)
          .having(
            (FullAddState s) => s.validation,
            'validation',
            FullAddValidation.noPrice,
          ),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'item-price sends preferred unit once (API owns conversion fallback)',
    build: () {
      when(
        () => resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: any(named: 'salesUnitId'),
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, PriceInfoEntity>(
          PriceInfoEntity(
            itemNumber: '2000',
            price: 19.95,
            unitId: 'حبة',
            currency: 'SAR',
          ),
        ),
      );
      when(
        () => submit(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          itemNumber: any(named: 'itemNumber'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, LineSubmitResultEntity>(
          LineSubmitResultEntity(
            success: true,
            item: LineItemResultEntity(
              id: '1',
              itemNumber: '2000',
              quantity: 1,
              status: 'synced',
              price: 19.95,
              unitId: 'حبة',
            ),
          ),
        ),
      );
      return buildBloc();
    },
    seed: () => const FullAddState(
      order: order,
      barcode: '0068',
      item: BarcodeItemEntity(
        barcode: '0068',
        itemNumber: '2000',
        productName: 'Keyboard',
        productDescription: 'KB',
        unitId: 'PCS',
        dataArea: 'usmf',
      ),
      onHand: WarehouseOnHandEntity(
        itemNumber: '2000',
        warehouseId: 'WH-11',
        availableSalesQuantity: 40,
        availableOnHandQuantity: 99,
        unit: '',
        productName: 'Keyboard',
      ),
      quantityText: '1',
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    verify: (_) {
      verify(
        () => resolvePrice(
          itemNumber: '2000',
          company: 'usmf',
          salesUnitId: 'PCS',
          warehouseId: 'WH-11',
          channelRecId: null,
        ),
      ).called(1);
      verifyNever(
        () => resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: 'حبة',
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      );
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'falls back to the session warehouse when the order header has none',
    build: () {
      when(
        () => getOnHand(
          itemNumber: any(named: 'itemNumber'),
          warehouse: any(named: 'warehouse'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, WarehouseOnHandEntity>(onHand),
      );
      return FullAddBloc(
        order: orderWithoutWarehouse,
        lookupBarcodeUseCase: lookup,
        lookupItemUseCase: lookupItem,
        resolvePriceUseCase: resolvePrice,
        getOnHandUseCase: getOnHand,
        submitFullLineUseCase: submit,
        submitQuickBatchUseCase: submitQuick,
        sessionWarehouse: 'MMS000WH',
      );
    },
    seed: () => const FullAddState(
      order: orderWithoutWarehouse,
      barcode: '6281001000002',
      item: item,
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddGetQtyRequested()),
    verify: (_) {
      verify(
        () => getOnHand(
          itemNumber: '2000',
          warehouse: 'MMS000WH',
          company: 'usmf',
        ),
      ).called(1);
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'submit validation fails when qty exceeds available',
    build: buildBloc,
    seed: () => const FullAddState(
      order: order,
      barcode: '6281001000002',
      item: item,
      price: price,
      onHand: onHand,
      quantityText: '50',
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    expect: () => <FullAddState>[
      const FullAddState(
        order: order,
        barcode: '6281001000002',
        item: item,
        price: price,
        onHand: onHand,
        quantityText: '50',
        validation: FullAddValidation.qtyExceeds,
      ),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'submit success adds cart line',
    build: () {
      when(
        () => submit(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          itemNumber: any(named: 'itemNumber'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, LineSubmitResultEntity>(
          LineSubmitResultEntity(
            success: true,
            item: LineItemResultEntity(
              id: '1',
              itemNumber: '2000',
              quantity: 2,
              status: 'synced',
              price: 10,
              unitId: 'pcs',
            ),
          ),
        ),
      );
      return buildBloc();
    },
    seed: () => const FullAddState(
      order: order,
      barcode: '6281001000002',
      item: item,
      price: price,
      onHand: onHand,
      quantityText: '2',
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    expect: () => <Matcher>[
      isA<FullAddState>().having(
        (FullAddState s) => s.submitting,
        'submitting',
        true,
      ),
      isA<FullAddState>()
          .having((FullAddState s) => s.submitSucceeded, 'ok', true)
          .having((FullAddState s) => s.cart, 'cart', <FullCartItemEntity>[
            const FullCartItemEntity(
              barcode: '6281001000002',
              itemNumber: '2000',
              productName: 'Keyboard',
              quantity: 2,
              price: 10,
              unitId: 'pcs',
            ),
          ]),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'auto submit keeps autoMode and posts once via submitFullLine',
    build: () {
      when(
        () => submit(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          itemNumber: any(named: 'itemNumber'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, LineSubmitResultEntity>(
          LineSubmitResultEntity(
            success: true,
            item: LineItemResultEntity(
              id: '1',
              itemNumber: '2000',
              quantity: 2,
              status: 'synced',
              price: 10,
              unitId: 'pcs',
            ),
          ),
        ),
      );
      return buildBloc();
    },
    seed: () => const FullAddState(
      order: order,
      barcode: '6287007961754',
      item: item,
      price: price,
      onHand: onHand,
      quantityText: '2',
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    verify: (FullAddBloc bloc) {
      verify(
        () => submit(
          salesId: 'SO-000100',
          company: 'usmf',
          itemNumber: '2000',
          quantity: 2,
        ),
      ).called(1);
      expect(bloc.state.autoMode, isTrue);
      expect(bloc.state.submitSucceeded, isTrue);
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'manual submit also posts via submitFullLine and keeps autoMode false',
    build: () {
      when(
        () => submit(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          itemNumber: any(named: 'itemNumber'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, LineSubmitResultEntity>(
          LineSubmitResultEntity(
            success: true,
            item: LineItemResultEntity(
              id: '1',
              itemNumber: '2000',
              quantity: 2,
              status: 'synced',
              price: 10,
              unitId: 'pcs',
            ),
          ),
        ),
      );
      return buildBloc();
    },
    seed: () => const FullAddState(
      order: order,
      barcode: '6287007961754',
      item: item,
      price: price,
      onHand: onHand,
      quantityText: '2',
      autoMode: false,
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddSubmitRequested()),
    verify: (FullAddBloc bloc) {
      verify(
        () => submit(
          salesId: 'SO-000100',
          company: 'usmf',
          itemNumber: '2000',
          quantity: 2,
        ),
      ).called(1);
      expect(bloc.state.autoMode, isFalse);
      expect(bloc.state.submitSucceeded, isTrue);
    },
  );

  blocTest<FullAddBloc, FullAddState>(
    'scan reset keeps autoMode and lookupByItem',
    build: buildBloc,
    seed: () => const FullAddState(
      order: order,
      barcode: 'BG 410.003',
      item: item,
      autoMode: false,
      lookupByItem: true,
    ),
    act: (FullAddBloc bloc) => bloc.add(const FullAddScanReset()),
    expect: () => <Matcher>[
      isA<FullAddState>()
          .having((FullAddState s) => s.barcode, 'barcode', '')
          .having((FullAddState s) => s.item, 'item', isNull)
          .having((FullAddState s) => s.autoMode, 'auto', false)
          .having((FullAddState s) => s.lookupByItem, 'byItem', true),
    ],
  );

  blocTest<FullAddBloc, FullAddState>(
    'item lookup forwards internal spaces without trim',
    build: () {
      when(
        () => lookupItem(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
        ),
      ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(item));
      when(
        () => resolvePrice(
          itemNumber: any(named: 'itemNumber'),
          company: any(named: 'company'),
          salesUnitId: any(named: 'salesUnitId'),
          warehouseId: any(named: 'warehouseId'),
          channelRecId: any(named: 'channelRecId'),
        ),
      ).thenAnswer((_) async => const Right<Failure, PriceInfoEntity>(price));
      when(
        () => getOnHand(
          itemNumber: any(named: 'itemNumber'),
          warehouse: any(named: 'warehouse'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, WarehouseOnHandEntity>(onHand),
      );
      return buildBloc();
    },
    act: (FullAddBloc bloc) async {
      bloc.add(const FullAddLookupByItemChanged(true));
      bloc.add(const FullAddBarcodeChanged('BG 410.003'));
      bloc.add(const FullAddLookupRequested());
    },
    verify: (_) {
      verify(
        () => lookupItem(itemNumber: 'BG 410.003', company: 'usmf'),
      ).called(1);
    },
  );
}
