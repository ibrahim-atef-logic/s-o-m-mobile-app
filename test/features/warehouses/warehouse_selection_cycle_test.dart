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
import 'package:logic_retail_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/select_warehouse_usecase.dart';
import 'package:logic_retail_mobile/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:logic_retail_mobile/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/warehouse_on_hand_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_on_hand_usecase.dart';
import 'package:logic_retail_mobile/features/warehouses/data/datasources/warehouse_remote_data_source.dart';
import 'package:logic_retail_mobile/features/warehouses/data/repositories/warehouse_repository_impl.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/entities/warehouse_entity.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/usecases/get_warehouses_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/activation_cycle_adapter.dart';
import '../../helpers/fixtures.dart';

/// Warehouse picker cycle for user 12344: login without a warehouse, load the
/// Standard list, persist the pick, then browse inventory with it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ActivationCycleAdapter adapter;
  late Dio dio;
  late AuthRepositoryImpl auth;
  late InMemoryAuthSessionStore store;
  late GetWarehousesUseCase getWarehouses;
  late GetOnHandUseCase getOnHand;

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
    getWarehouses = GetWarehousesUseCase(
      WarehouseRepositoryImpl(WarehouseRemoteDataSourceImpl(dio)),
    );
    getOnHand = GetOnHandUseCase(
      CatalogRepositoryImpl(CatalogRemoteDataSourceImpl(dio)),
    );
  });

  Future<UserSessionEntity> login(String personnelNumber) async {
    final Either<Failure, AuthTokensEntity> result = await LoginUseCase(auth)(
      company: Fixtures.loginCompany,
      personnelNumber: personnelNumber,
      password: Fixtures.password,
    );
    return result.getOrElse((_) => throw StateError('login')).user;
  }

  test('12344 picks a warehouse and inventory becomes usable', () async {
    final UserSessionEntity session = await login('12344');
    expect(session.warehouseMissing, isTrue);

    final Either<Failure, List<WarehouseEntity>> list = await getWarehouses(
      session.operatingCompany,
    );
    final List<WarehouseEntity> warehouses = list.getOrElse(
      (_) => <WarehouseEntity>[],
    );
    expect(warehouses, hasLength(2));
    expect(warehouses.first.inventLocationId, 'PLS001WH');
    expect(warehouses.last.displayName, 'PLS002WH');

    final WarehouseEntity picked = warehouses.first;
    final Either<Failure, UserSessionEntity> saved =
        await SelectWarehouseUseCase(auth)(
          inventLocationId: picked.inventLocationId,
          dataAreaId: picked.dataAreaId,
        );
    final UserSessionEntity updated = saved.getOrElse(
      (_) => throw StateError('persist'),
    );
    expect(updated.resolvedWarehouse, 'PLS001WH');
    expect(updated.needsWarehouseSelection, isFalse);
    expect(updated.warehouseMissing, isFalse);

    final AuthResponseModel? held = store.session;
    expect(held?.user.activeWarehouse, 'PLS001WH');
    expect(held?.user.inventLocation, 'PLS001WH');
    expect(held?.user.inventLocationDataAreaId, 'PLTR');
    expect(held?.user.needsWarehouseSelection, isFalse);

    final Either<Failure, WarehouseOnHandEntity> stock = await getOnHand(
      itemNumber: Fixtures.itemNumber,
      warehouse: updated.resolvedWarehouse ?? '',
      company: updated.operatingCompany,
    );
    expect(stock.isRight(), isTrue);

    final RequestOptions inventory = adapter.requests.lastWhere(
      (RequestOptions r) => r.path.contains('/inventory'),
    );
    expect(inventory.queryParameters['warehouse'], 'PLS001WH');
    expect(inventory.queryParameters['company'], 'PLTR');

    await LogoutUseCase(auth)();
    expect(store.session, isNull);
  });

  test(
    'the picker always queries activeCompany, never the login key',
    () async {
      final UserSessionEntity session = await login('12344');
      await getWarehouses(session.operatingCompany);

      final RequestOptions request = adapter.requests.lastWhere(
        (RequestOptions r) => r.path.contains('/warehouses'),
      );
      expect(request.queryParameters['company'], 'PLTR');
      expect(request.queryParameters['company'], isNot(Fixtures.loginCompany));
    },
  );

  test(
    'sending the login registry key is rejected as FORBIDDEN_COMPANY',
    () async {
      await login('12344');

      final Either<Failure, List<WarehouseEntity>> result = await getWarehouses(
        Fixtures.loginCompany,
      );

      expect(result.isLeft(), isTrue);
      result.fold((Failure f) {
        expect(f, isA<ServerFailure>());
        expect(f.message, contains('FORBIDDEN_COMPANY'));
      }, (_) {});
    },
  );

  test('1006 keeps its assigned warehouse and skips the picker', () async {
    final UserSessionEntity session = await login(Fixtures.personnelNumber);

    expect(session.resolvedWarehouse, Fixtures.warehouse);
    expect(session.warehouseMissing, isFalse);
    expect(
      adapter.requests.any(
        (RequestOptions r) => r.path.contains('/warehouses'),
      ),
      isFalse,
    );
  });
}
