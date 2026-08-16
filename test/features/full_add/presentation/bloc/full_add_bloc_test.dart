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
import 'package:logic_retail_mobile/features/catalog/domain/usecases/resolve_price_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_full_line_usecase.dart';
import 'package:logic_retail_mobile/features/full_add/domain/entities/full_cart_item_entity.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/bloc/full_add_bloc.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockLookupBarcodeUseCase extends Mock implements LookupBarcodeUseCase {}

class MockResolvePriceUseCase extends Mock implements ResolvePriceUseCase {}

class MockGetOnHandUseCase extends Mock implements GetOnHandUseCase {}

class MockSubmitFullLineUseCase extends Mock implements SubmitFullLineUseCase {}

void main() {
  late MockLookupBarcodeUseCase lookup;
  late MockResolvePriceUseCase resolvePrice;
  late MockGetOnHandUseCase getOnHand;
  late MockSubmitFullLineUseCase submit;

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
    unitId: 'ea',
    customerAccountNumber: 'US-001',
    priceCustomerGroupCode: 'RETAIL',
    dataArea: 'usmf',
  );

  const WarehouseOnHandEntity onHand = WarehouseOnHandEntity(
    itemNumber: '2000',
    warehouseId: 'WH-11',
    availableSalesQuantity: 40,
    availableOnHandQuantity: 40,
    unit: 'pcs',
    productName: 'Keyboard',
  );

  FullAddBloc buildBloc() => FullAddBloc(
    order: order,
    lookupBarcodeUseCase: lookup,
    resolvePriceUseCase: resolvePrice,
    getOnHandUseCase: getOnHand,
    submitFullLineUseCase: submit,
  );

  setUp(() {
    lookup = MockLookupBarcodeUseCase();
    resolvePrice = MockResolvePriceUseCase();
    getOnHand = MockGetOnHandUseCase();
    submit = MockSubmitFullLineUseCase();
  });

  blocTest<FullAddBloc, FullAddState>(
    'lookup success then resolves price and on-hand',
    build: () {
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
          custAccount: any(named: 'custAccount'),
          priceGroup: any(named: 'priceGroup'),
          unitId: any(named: 'unitId'),
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
      isA<FullAddState>().having((FullAddState s) => s.item, 'item', item),
      isA<FullAddState>().having((FullAddState s) => s.price, 'price', price),
      isA<FullAddState>().having(
        (FullAddState s) => s.fetchingQty,
        'fetchingQty',
        true,
      ),
      isA<FullAddState>().having((FullAddState s) => s.onHand, 'onHand', onHand),
    ],
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
        resolvePriceUseCase: resolvePrice,
        getOnHandUseCase: getOnHand,
        submitFullLineUseCase: submit,
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
              unitId: 'ea',
            ),
          ]),
    ],
  );
}
