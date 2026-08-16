import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/locale/locale_cubit.dart';
import 'package:logic_retail_mobile/core/locale/locale_repository.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/presentation/bloc/sales_orders_bloc.dart';
import 'package:logic_retail_mobile/features/sales_orders/presentation/pages/my_sales_orders_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockSalesOrdersBloc extends Mock implements SalesOrdersBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc authBloc;
  late MockSalesOrdersBloc salesBloc;
  late LocaleCubit localeCubit;

  const CompanyEntity mm = CompanyEntity(
    code: 'mm',
    name: 'MM Company',
    groupId: 'GRP-MM',
  );

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

  setUpAll(() {
    registerFallbackValue(const SalesOrdersRequested('mm'));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    localeCubit = LocaleCubit(LocaleRepository(prefs));
    authBloc = MockAuthBloc();
    salesBloc = MockSalesOrdersBloc();

    when(() => authBloc.state).thenReturn(
      const AuthAuthenticated(
        UserSessionEntity(
          personnelNumber: '1006',
          workerRecId: 1,
          name: 'Trial',
          companies: <CompanyEntity>[mm],
          selectedCompany: mm,
        ),
      ),
    );
    when(() => authBloc.stream).thenAnswer((_) => const Stream<AuthState>.empty());
    when(authBloc.close).thenAnswer((_) async {});

    when(() => salesBloc.state).thenReturn(
      const SalesOrdersLoaded(<SalesOrderHeaderEntity>[order]),
    );
    when(() => salesBloc.stream).thenAnswer(
      (_) => Stream<SalesOrdersState>.value(
        const SalesOrdersLoaded(<SalesOrderHeaderEntity>[order]),
      ),
    );
    when(() => salesBloc.add(any())).thenReturn(null);
    when(salesBloc.close).thenAnswer((_) async {});
  });

  tearDown(() async {
    await localeCubit.close();
  });

  testWidgets('shows loaded salesId MM-245265', (WidgetTester tester) async {
    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SalesOrdersBloc>.value(value: salesBloc),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
      ],
      home: const MySalesOrdersPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text(Fixtures.salesId), findsOneWidget);
  });

  testWidgets('incomplete warehouse session still loads home with banner', (
    WidgetTester tester,
  ) async {
    when(() => authBloc.state).thenReturn(
      const AuthAuthenticated(
        UserSessionEntity(
          personnelNumber: '12344',
          workerRecId: 2,
          name: 'مروان وهاس',
          companies: <CompanyEntity>[
            CompanyEntity(code: 'PLTR', name: 'PLTR', groupId: ''),
          ],
          activeCompany: 'PLTR',
          needsWarehouseSelection: true,
        ),
      ),
    );
    when(() => salesBloc.state).thenReturn(
      const SalesOrdersLoaded(<SalesOrderHeaderEntity>[]),
    );

    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SalesOrdersBloc>.value(value: salesBloc),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
      ],
      home: const MySalesOrdersPage(),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Warehouse is not assigned'), findsOneWidget);
    verify(() => salesBloc.add(const SalesOrdersRequested('PLTR'))).called(1);
  });
}
