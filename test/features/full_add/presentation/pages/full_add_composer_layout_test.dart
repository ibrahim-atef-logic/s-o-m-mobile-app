import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/price_info_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/warehouse_on_hand_entity.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/bloc/full_add_bloc.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/widgets/full_add_scan_panel.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockFullAddBloc extends MockBloc<FullAddEvent, FullAddState>
    implements FullAddBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFullAddBloc bloc;

  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: Fixtures.salesId,
    custAccount: Fixtures.custAccount,
    salesName: 'Trial',
    dataArea: Fixtures.legalEntity,
    priceGroupId: 'RETAIL',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MM',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  const FullAddState ready = FullAddState(
    order: order,
    barcode: Fixtures.barcode,
    item: BarcodeItemEntity(
      barcode: Fixtures.barcode,
      itemNumber: Fixtures.itemNumber,
      productName: 'Bosch drill',
      productDescription: 'Drill',
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
      productName: 'Bosch drill',
    ),
    quantityText: '1',
  );

  setUp(() {
    bloc = MockFullAddBloc();
    when(() => bloc.state).thenReturn(ready);
    whenListen(bloc, Stream<FullAddState>.value(ready), initialState: ready);
  });

  Future<void> pumpLayout(
    WidgetTester tester, {
    required Size size,
    double insetBottom = 0,
    FullAddState? state,
  }) async {
    final FullAddState current = state ?? ready;
    when(() => bloc.state).thenReturn(current);
    whenListen(
      bloc,
      Stream<FullAddState>.value(current),
      initialState: current,
    );
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = FakeViewPadding(bottom: insetBottom);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<FullAddBloc>.value(
          value: bloc,
          child: Scaffold(
            body: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                const SliverToBoxAdapter(child: FullAddScanPanel()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, int i) => ListTile(title: Text('Line $i')),
                    childCount: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  void expectComposerReachable() {
    expect(find.byType(FullAddScanPanel), findsOneWidget);
    expect(find.text(Fixtures.barcode), findsWidgets);
    expect(find.byType(TextField), findsWidgets);
  }

  testWidgets('360 phone + keyboard has no overflow', (
    WidgetTester tester,
  ) async {
    await pumpLayout(tester, size: const Size(360, 640), insetBottom: 280);
    expect(tester.takeException(), isNull);
    expectComposerReachable();
    await tester.ensureVisible(find.text('1').first);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Add to cart'), findsNothing);
  });

  testWidgets('412 phone composer stays above scrollable lines', (
    WidgetTester tester,
  ) async {
    await pumpLayout(tester, size: const Size(412, 915));
    expect(tester.takeException(), isNull);
    expectComposerReachable();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -240));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(FullAddScanPanel), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  testWidgets('768 tablet composer has no overflow', (
    WidgetTester tester,
  ) async {
    await pumpLayout(tester, size: const Size(768, 1024));
    expect(tester.takeException(), isNull);
    expectComposerReachable();
  });
}
