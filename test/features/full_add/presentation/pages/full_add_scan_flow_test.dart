import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/price_info_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/warehouse_on_hand_entity.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/bloc/full_add_bloc.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/pages/full_add_scan_page.dart';
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
      customerAccountNumber: Fixtures.custAccount,
      priceCustomerGroupCode: 'RETAIL',
      dataArea: Fixtures.legalEntity,
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

  testWidgets('FullAddScanPage shows item and available qty', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: bloc),
      ],
      home: const FullAddScanPage(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FullAddScanPage), findsOneWidget);
    expect(find.text(Fixtures.itemNumber), findsOneWidget);
    expect(find.textContaining('Available quantity'), findsOneWidget);
    expect(find.textContaining('25'), findsWidgets);
  });
}
