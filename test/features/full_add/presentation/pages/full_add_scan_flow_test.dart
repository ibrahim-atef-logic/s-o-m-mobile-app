import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/price_info_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/warehouse_on_hand_entity.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/bloc/full_add_bloc.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/widgets/full_add_scan_panel.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_app.dart';

class MockFullAddBloc extends MockBloc<FullAddEvent, FullAddState>
    implements FullAddBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFullAddBloc bloc;

  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: Fixtures.salesId,
    custAccount: Fixtures.custAccount,
    salesName: 'Trial Customer',
    dataArea: Fixtures.legalEntity,
    priceGroupId: 'RETAIL',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MM',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  const FullAddState seeded = FullAddState(
    order: order,
    barcode: Fixtures.barcode,
    item: BarcodeItemEntity(
      barcode: Fixtures.barcode,
      itemNumber: Fixtures.itemNumber,
      productName: 'Bag Item',
      productDescription: 'Desc',
      unitId: 'pcs',
      dataArea: Fixtures.legalEntity,
    ),
    price: PriceInfoEntity(
      itemNumber: Fixtures.itemNumber,
      price: 12.5,
      unitId: 'pcs',
      currency: 'SAR',
    ),
    onHand: WarehouseOnHandEntity(
      itemNumber: Fixtures.itemNumber,
      warehouseId: Fixtures.warehouse,
      availableSalesQuantity: 25,
      availableOnHandQuantity: 30,
      unit: 'pcs',
      productName: 'Bag Item',
    ),
    quantityText: '1',
  );

  setUp(() {
    bloc = MockFullAddBloc();
    when(() => bloc.state).thenReturn(seeded);
    whenListen(bloc, Stream<FullAddState>.value(seeded), initialState: seeded);
  });

  testWidgets('FullAddScanPanel shows item and available qty', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const Scaffold(body: FullAddScanPanel()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FullAddScanPanel), findsOneWidget);
    expect(find.text(Fixtures.itemNumber), findsOneWidget);
    expect(find.textContaining('Available quantity'), findsOneWidget);
    // availableSalesQuantity=25 with unit pcs — never show availableOnHandQuantity=30
    expect(find.textContaining('25 pcs'), findsOneWidget);
    expect(find.textContaining('30'), findsNothing);
  });

  testWidgets('scan lookup failure shows Item not found on the field', (
    WidgetTester tester,
  ) async {
    const FullAddState failed = FullAddState(
      order: order,
      barcode: Fixtures.unknownBarcode,
      failure: ServerFailure('BARCODE_NOT_FOUND: Barcode not found'),
    );
    when(() => bloc.state).thenReturn(failed);
    whenListen(bloc, Stream<FullAddState>.value(failed), initialState: failed);

    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const Scaffold(body: FullAddScanPanel()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Item not found'), findsOneWidget);
  });

  testWidgets('scan lookup failure shows Arabic item-not-found', (
    WidgetTester tester,
  ) async {
    const FullAddState failed = FullAddState(
      order: order,
      barcode: 'NO-SUCH-ITEM',
      lookupByItem: true,
      failure: ServerFailure('ITEM_NOT_FOUND: Item not found'),
    );
    when(() => bloc.state).thenReturn(failed);
    whenListen(bloc, Stream<FullAddState>.value(failed), initialState: failed);

    await pumpTestApp(
      tester,
      locale: const Locale('ar'),
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const Scaffold(body: FullAddScanPanel()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('الصنف غير موجود'), findsOneWidget);
  });

  testWidgets('forbidden company lookup shows the session company error', (
    WidgetTester tester,
  ) async {
    const FullAddState failed = FullAddState(
      order: order,
      barcode: Fixtures.barcode,
      failure: ServerFailure(
        'FORBIDDEN_COMPANY: Company not allowed for token',
      ),
    );
    when(() => bloc.state).thenReturn(failed);
    whenListen(bloc, Stream<FullAddState>.value(failed), initialState: failed);

    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const Scaffold(body: FullAddScanPanel()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('This company is not allowed for the current session'),
      findsOneWidget,
    );
  });

  testWidgets('auto mode has no Submit or Add button', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const Scaffold(body: FullAddScanPanel()),
    );
    await tester.pump();

    expect(find.textContaining('Posts to the order immediately'), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Add'), findsNothing);
  });

  testWidgets('qty plus in auto dispatches submit once', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const Scaffold(body: FullAddScanPanel()),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();

    verify(() => bloc.add(const FullAddSubmitRequested())).called(1);
  });

  testWidgets('manual mode shows Add and not Submit', (
    WidgetTester tester,
  ) async {
    const FullAddState manual = FullAddState(
      order: order,
      barcode: Fixtures.barcode,
      item: BarcodeItemEntity(
        barcode: Fixtures.barcode,
        itemNumber: Fixtures.itemNumber,
        productName: 'Bag Item',
        productDescription: 'Desc',
        unitId: 'pcs',
        dataArea: Fixtures.legalEntity,
      ),
      price: PriceInfoEntity(
        itemNumber: Fixtures.itemNumber,
        price: 12.5,
        unitId: 'pcs',
        currency: 'SAR',
      ),
      onHand: WarehouseOnHandEntity(
        itemNumber: Fixtures.itemNumber,
        warehouseId: Fixtures.warehouse,
        availableSalesQuantity: 25,
        availableOnHandQuantity: 30,
        unit: 'pcs',
        productName: 'Bag Item',
      ),
      quantityText: '1',
      autoMode: false,
    );
    when(() => bloc.state).thenReturn(manual);
    whenListen(bloc, Stream<FullAddState>.value(manual), initialState: manual);

    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const Scaffold(body: FullAddScanPanel()),
    );
    await tester.pump();

    expect(find.text('Review quantity, then tap Add'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Add to cart'), findsNothing);
  });
}
