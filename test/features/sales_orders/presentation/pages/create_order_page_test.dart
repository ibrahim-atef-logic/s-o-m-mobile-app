import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logic_retail_mobile/core/di/injection.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';
import 'package:logic_retail_mobile/features/customers/domain/usecases/search_customers_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/created_order_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/create_sales_order_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_sales_order_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/presentation/cubit/create_order_cubit.dart';
import 'package:logic_retail_mobile/features/sales_orders/presentation/pages/create_order_page.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockCreateSalesOrderUseCase extends Mock
    implements CreateSalesOrderUseCase {}

class MockGetSalesOrderUseCase extends Mock implements GetSalesOrderUseCase {}

class MockSearchCustomersUseCase extends Mock
    implements SearchCustomersUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc authBloc;
  late MockCreateSalesOrderUseCase create;
  late MockGetSalesOrderUseCase getOrder;
  late MockSearchCustomersUseCase search;

  const CustomerEntity defaultCustomer = CustomerEntity(
    dataAreaId: 'mm',
    customerAccount: Fixtures.defaultCustAccount,
    name: 'عميل نقدي ميرا مارت جدة 01',
  );

  const UserSessionEntity session = UserSessionEntity(
    personnelNumber: Fixtures.personnelNumber,
    workerRecId: 5637227826,
    name: 'محمد عفيف',
    companies: <CompanyEntity>[
      CompanyEntity(code: 'mm', name: 'mm', groupId: ''),
    ],
    activeCompany: 'mm',
    inventLocationDataAreaId: 'mm',
    activeWarehouse: Fixtures.warehouse,
    currency: 'SAR',
    defaultCustAccount: Fixtures.defaultCustAccount,
    needsWarehouseSelection: false,
  );

  const CreatedOrderEntity created = CreatedOrderEntity(
    salesOrderNumber: Fixtures.createdSalesId,
    dataAreaId: 'mm',
    custAccount: Fixtures.defaultCustAccount,
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MMS000',
    currencyCode: 'SAR',
  );

  setUp(() async {
    await sl.reset();
    authBloc = MockAuthBloc();
    create = MockCreateSalesOrderUseCase();
    getOrder = MockGetSalesOrderUseCase();
    search = MockSearchCustomersUseCase();

    when(() => authBloc.state).thenReturn(const AuthAuthenticated(session));
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(authBloc.close).thenAnswer((_) async {});
    when(
      () => search(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<CustomerEntity>>(<CustomerEntity>[
        defaultCustomer,
      ]),
    );

    sl.registerFactory(
      () => CreateOrderCubit(
        createSalesOrderUseCase: create,
        getSalesOrderUseCase: getOrder,
        searchCustomersUseCase: search,
      ),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<SalesOrderHeaderEntity?> pumpPage(WidgetTester tester) async {
    SalesOrderHeaderEntity? popped;
    final GoRouter router = GoRouter(
      initialLocation: '/orders',
      routes: <RouteBase>[
        GoRoute(
          path: '/orders',
          builder: (BuildContext context, GoRouterState state) => Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () async {
                  popped = await context.push<SalesOrderHeaderEntity>(
                    '/orders/new',
                  );
                },
                child: const Text('open-create'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/orders/new',
          builder: (BuildContext context, GoRouterState state) =>
              const CreateOrderPage(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.tap(find.text('open-create'));
    await tester.pumpAndSettle();
    return popped;
  }

  testWidgets('shows session company, warehouse and preselected customer', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('New sales order'), findsOneWidget);
    expect(find.text('mm'), findsOneWidget);
    expect(find.text(Fixtures.warehouse), findsOneWidget);
    expect(find.text('عميل نقدي ميرا مارت جدة 01'), findsOneWidget);
    expect(find.text(Fixtures.defaultCustAccount), findsOneWidget);
  });

  testWidgets('creating the order pops the new header back to the list', (
    WidgetTester tester,
  ) async {
    when(
      () => create(
        company: any(named: 'company'),
        custAccount: any(named: 'custAccount'),
        inventLocationId: any(named: 'inventLocationId'),
        inventSiteId: any(named: 'inventSiteId'),
        currencyCode: any(named: 'currencyCode'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, CreatedOrderEntity>(created),
    );
    when(
      () => getOrder(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
      ),
    ).thenAnswer(
      (_) async =>
          const Left<Failure, SalesOrderHeaderEntity>(NetworkFailure()),
    );

    await pumpPage(tester);
    await tester.tap(find.text('Create order'));
    await tester.pumpAndSettle();

    verify(
      () => create(
        company: 'mm',
        custAccount: Fixtures.defaultCustAccount,
        inventLocationId: Fixtures.warehouse,
        currencyCode: 'SAR',
      ),
    ).called(1);
    expect(find.text('open-create'), findsOneWidget);
  });

  testWidgets('a failure keeps the form open with an error toast', (
    WidgetTester tester,
  ) async {
    when(
      () => create(
        company: any(named: 'company'),
        custAccount: any(named: 'custAccount'),
        inventLocationId: any(named: 'inventLocationId'),
        inventSiteId: any(named: 'inventSiteId'),
        currencyCode: any(named: 'currencyCode'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, CreatedOrderEntity>(
        ServerFailure('FORBIDDEN_COMPANY: Company not allowed for token'),
      ),
    );

    await pumpPage(tester);
    await tester.tap(find.text('Create order'));
    await tester.pumpAndSettle();

    expect(find.text('New sales order'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
