import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/core/network/error_interceptor.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_session_store.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:logic_retail_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:logic_retail_mobile/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_on_hand_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/datasources/sales_orders_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/activation_cycle_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ActivationCycleAdapter adapter;
  late Dio dio;
  late AuthRepositoryImpl auth;
  late InMemoryAuthSessionStore store;
  late SalesOrdersRemoteDataSourceImpl sales;
  late CatalogRemoteDataSourceImpl catalog;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});
    adapter = ActivationCycleAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://cycle.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(ErrorInterceptor());
    store = InMemoryAuthSessionStore();
    auth = AuthRepositoryImpl(
      remote: AuthRemoteDataSourceImpl(dio),
      store: store,
    );
    sales = SalesOrdersRemoteDataSourceImpl(dio);
    catalog = CatalogRemoteDataSourceImpl(dio);
  });

  Future<UserSessionEntity> login1006() async {
    final Either<Failure, AuthTokensEntity> result = await LoginUseCase(auth)(
      company: Fixtures.loginCompany,
      personnelNumber: Fixtures.personnelNumber,
      password: Fixtures.password,
    );
    expect(result.isRight(), isTrue);
    return result.getOrElse((_) => throw StateError('login')).user;
  }

  test(
    'full activation cycle: login cache, mm company, catalog, logout',
    () async {
      final Either<Failure, AuthTokensEntity> bad = await LoginUseCase(auth)(
        company: Fixtures.loginCompany,
        personnelNumber: Fixtures.personnelNumber,
        password: 'wrong',
      );
      expect(bad.isLeft(), isTrue);
      bad.fold((Failure f) => expect(f, isA<AuthFailure>()), (_) {});

      final UserSessionEntity session = await login1006();
      expect(session.operatingCompany, 'mm');
      expect(session.resolvedWarehouse, Fixtures.warehouse);
      expect(session.defaultCustAccount, '10-10002');
      expect(session.retailChannelId, '912');
      expect(session.retailChannelName, 'سلة المواد الغذائية المخفضة');
      expect(session.displayBranchLabel, 'سلة المواد الغذائية المخفضة');
      expect(session.currency, 'SAR');
      expect(session.workerRecId, 5637227826);
      expect(session.warehouseMissing, isFalse);

      final AuthResponseModel? held = store.session;
      expect(held?.user.activeCompany, 'mm');
      expect(held?.user.activeWarehouse, Fixtures.warehouse);

      final String company = session.operatingCompany;
      await sales.getMyOrders(company: company);
      await sales.getOrder(salesId: Fixtures.salesId, company: company);
      await sales.getOrderLines(salesId: Fixtures.salesId, company: company);
      await catalog.lookupBarcode(code: Fixtures.barcode, company: company);
      await catalog.resolvePrice(
        itemNumber: Fixtures.itemNumber,
        company: company,
        salesUnitId: 'pcs',
        warehouseId: Fixtures.warehouse,
        channelRecId: session.retailChannelTableRecId,
      );
      await catalog.resolvePrice(
        itemNumber: Fixtures.itemNumber,
        company: company,
        salesUnitId: 'pcs',
      );
      await catalog.getOnHand(
        itemNumber: Fixtures.itemNumber,
        warehouse: session.resolvedWarehouse!,
        company: company,
      );
      await catalog.submitFullLine(
        salesId: Fixtures.salesId,
        company: company,
        itemNumber: Fixtures.itemNumber,
        quantity: 1,
      );
      await catalog.submitQuickBatch(
        salesId: Fixtures.salesId,
        company: company,
        lines: <Map<String, Object>>[
          <String, Object>{'barcode': Fixtures.barcode, 'quantity': 1},
        ],
      );
      await catalog.getFailedLines(salesId: Fixtures.salesId, company: company);
      await auth.fetchMe();
      final Either<Failure, String> changed = await ChangePasswordUseCase(auth)(
        oldPassword: '123',
        newPassword: '456',
        confirmPassword: '456',
      );
      expect(changed, const Right<Failure, String>('Password changed'));

      for (final RequestOptions req in adapter.requests) {
        if (req.path.contains('/auth/login') ||
            req.path.contains('/auth/refresh') ||
            req.path.contains('/auth/logout') ||
            req.path.contains('/auth/change-password') ||
            req.path.contains('/auth/me')) {
          continue;
        }
        final Object? q = req.queryParameters['company'];
        final Object? b = req.data is Map ? (req.data as Map)['company'] : null;
        expect(q ?? b, 'mm', reason: '${req.method} ${req.path}');
        expect(q ?? b, isNot(Fixtures.loginCompany));
      }
      expect(
        adapter.requests.any(
          (RequestOptions r) =>
              r.path.contains('/change-password') &&
              r.data is Map &&
              (r.data as Map).containsKey('personnelNumber'),
        ),
        isFalse,
      );

      await LogoutUseCase(auth)();
      expect(store.session, isNull);
    },
  );

  test(
    '12344 incomplete cycle still caches and blocks empty warehouse',
    () async {
      final Either<Failure, AuthTokensEntity> result = await LoginUseCase(auth)(
        company: Fixtures.loginCompany,
        personnelNumber: '12344',
        password: Fixtures.password,
      );
      final UserSessionEntity user = result
          .getOrElse((_) => throw StateError('login'))
          .user;
      expect(user.operatingCompany, 'PLTR');
      expect(user.warehouseMissing, isTrue);
      expect(user.needsWarehouseSelection, isTrue);

      await sales.getMyOrders(company: user.operatingCompany);
      final GetOnHandUseCase onHand = GetOnHandUseCase(
        CatalogRepositoryImpl(catalog),
      );
      final Either<Failure, dynamic> stock = await onHand(
        itemNumber: Fixtures.itemNumber,
        warehouse: user.resolvedWarehouse ?? '',
        company: user.operatingCompany,
      );
      expect(stock.isLeft(), isTrue);
      stock.fold(
        (Failure f) => expect(f.message, 'WAREHOUSE_NOT_ASSIGNED'),
        (_) {},
      );
      expect(
        adapter.requests.any(
          (RequestOptions r) => r.path.contains('/inventory'),
        ),
        isFalse,
      );
    },
  );
}
