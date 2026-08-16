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
import 'package:logic_retail_mobile/features/auth/domain/usecases/select_warehouse_usecase.dart';
import 'package:logic_retail_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/entities/warehouse_entity.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/usecases/get_warehouses_usecase.dart';
import 'package:logic_retail_mobile/features/warehouses/presentation/cubit/warehouse_picker_cubit.dart';
import 'package:logic_retail_mobile/features/warehouses/presentation/pages/warehouse_picker_page.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockGetWarehousesUseCase extends Mock implements GetWarehousesUseCase {}

class MockSelectWarehouseUseCase extends Mock
    implements SelectWarehouseUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc authBloc;
  late MockGetWarehousesUseCase getWarehouses;
  late MockSelectWarehouseUseCase selectWarehouse;

  const CompanyEntity pltr = CompanyEntity(
    code: 'PLTR',
    name: 'PLTR',
    groupId: '',
  );

  const UserSessionEntity noWarehouse = UserSessionEntity(
    personnelNumber: '12344',
    workerRecId: 2,
    name: 'مروان وهاس',
    companies: <CompanyEntity>[pltr],
    activeCompany: 'PLTR',
    needsWarehouseSelection: true,
  );

  const WarehouseEntity mms021 = WarehouseEntity(
    dataAreaId: 'PLTR',
    inventLocationId: 'MMS021ST',
    name: 'Trial warehouse',
    inventSiteId: 'MMS021',
    inventLocationType: 'Standard',
  );

  setUpAll(() {
    registerFallbackValue(const AuthProfileOpened());
  });

  setUp(() async {
    await sl.reset();
    authBloc = MockAuthBloc();
    getWarehouses = MockGetWarehousesUseCase();
    selectWarehouse = MockSelectWarehouseUseCase();

    when(() => authBloc.state).thenReturn(const AuthAuthenticated(noWarehouse));
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => authBloc.add(any())).thenReturn(null);
    when(authBloc.close).thenAnswer((_) async {});

    sl.registerFactory(
      () => WarehousePickerCubit(
        getWarehousesUseCase: getWarehouses,
        selectWarehouseUseCase: selectWarehouse,
      ),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpPicker(WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/warehouse',
      routes: <RouteBase>[
        GoRoute(
          path: '/warehouse',
          builder: (BuildContext context, GoRouterState state) =>
              const WarehousePickerPage(),
        ),
        GoRoute(
          path: '/orders',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Text('orders-home')),
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
    await tester.pumpAndSettle();
  }

  testWidgets('loads warehouses for the active company', (
    WidgetTester tester,
  ) async {
    when(() => getWarehouses(any())).thenAnswer(
      (_) async => const Right<Failure, List<WarehouseEntity>>(
        <WarehouseEntity>[mms021],
      ),
    );

    await pumpPicker(tester);

    expect(find.text('Trial warehouse'), findsOneWidget);
    expect(find.text('MMS021ST · MMS021'), findsOneWidget);
    verify(() => getWarehouses('PLTR')).called(1);
  });

  testWidgets('shows the empty state for a company without warehouses', (
    WidgetTester tester,
  ) async {
    when(() => getWarehouses(any())).thenAnswer(
      (_) async =>
          const Right<Failure, List<WarehouseEntity>>(<WarehouseEntity>[]),
    );

    await pumpPicker(tester);

    expect(
      find.text('No standard warehouses are available for this company'),
      findsOneWidget,
    );
  });

  testWidgets('shows the error state when loading fails', (
    WidgetTester tester,
  ) async {
    when(() => getWarehouses(any())).thenAnswer(
      (_) async => const Left<Failure, List<WarehouseEntity>>(NetworkFailure()),
    );

    await pumpPicker(tester);

    expect(
      find.text('Could not load warehouses, please try again'),
      findsOneWidget,
    );
  });

  testWidgets('picking a warehouse updates the session and continues home', (
    WidgetTester tester,
  ) async {
    when(() => getWarehouses(any())).thenAnswer(
      (_) async => const Right<Failure, List<WarehouseEntity>>(
        <WarehouseEntity>[mms021],
      ),
    );
    when(
      () => selectWarehouse(
        inventLocationId: any(named: 'inventLocationId'),
        dataAreaId: any(named: 'dataAreaId'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, UserSessionEntity>(
        noWarehouse.copyWith(
          activeWarehouse: 'MMS021ST',
          inventLocation: 'MMS021ST',
          needsWarehouseSelection: false,
        ),
      ),
    );

    await pumpPicker(tester);
    await tester.tap(find.text('Trial warehouse'));
    await tester.pumpAndSettle();

    verify(
      () => selectWarehouse(inventLocationId: 'MMS021ST', dataAreaId: 'PLTR'),
    ).called(1);
    final AuthSessionUpdated dispatched =
        verify(() => authBloc.add(captureAny())).captured.last
            as AuthSessionUpdated;
    expect(dispatched.session.resolvedWarehouse, 'MMS021ST');
    expect(dispatched.session.warehouseMissing, isFalse);
    expect(find.text('orders-home'), findsOneWidget);
  });
}
