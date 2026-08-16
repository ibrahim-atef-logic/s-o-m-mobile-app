import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_session_store.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/entities/auth_tokens_entity.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/fetch_me_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/select_company_usecase.dart';
import '../../features/auth/domain/usecases/select_warehouse_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cubit/change_password_cubit.dart';
import '../../features/catalog/data/datasources/catalog_remote_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/usecases/get_failed_lines_usecase.dart';
import '../../features/catalog/domain/usecases/get_on_hand_usecase.dart';
import '../../features/catalog/domain/usecases/lookup_barcode_usecase.dart';
import '../../features/catalog/domain/usecases/resolve_price_usecase.dart';
import '../../features/catalog/domain/usecases/submit_full_line_usecase.dart';
import '../../features/catalog/domain/usecases/submit_quick_batch_usecase.dart';
import '../../features/customers/data/datasources/customer_remote_data_source.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/search_customers_usecase.dart';
import '../../features/customers/presentation/cubit/customer_picker_cubit.dart';
import '../../features/failed_lines/presentation/cubit/failed_lines_cubit.dart';
import '../../features/full_add/presentation/bloc/full_add_bloc.dart';
import '../../features/quick_add/presentation/bloc/quick_add_bloc.dart';
import '../../features/sales_orders/data/datasources/sales_orders_remote_data_source.dart';
import '../../features/sales_orders/data/repositories/sales_orders_repository_impl.dart';
import '../../features/sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../features/sales_orders/domain/repositories/sales_orders_repository.dart';
import '../../features/sales_orders/domain/usecases/create_sales_order_usecase.dart';
import '../../features/sales_orders/domain/usecases/get_my_sales_orders_usecase.dart';
import '../../features/sales_orders/domain/usecases/get_sales_order_lines_usecase.dart';
import '../../features/sales_orders/domain/usecases/get_sales_order_usecase.dart';
import '../../features/sales_orders/presentation/bloc/sales_orders_bloc.dart';
import '../../features/sales_orders/presentation/cubit/create_order_cubit.dart';
import '../../features/so_lines/presentation/cubit/so_lines_cubit.dart';
import '../../features/warehouses/data/datasources/warehouse_remote_data_source.dart';
import '../../features/warehouses/data/repositories/warehouse_repository_impl.dart';
import '../../features/warehouses/domain/repositories/warehouse_repository.dart';
import '../../features/warehouses/domain/usecases/get_warehouses_usecase.dart';
import '../../features/warehouses/presentation/cubit/warehouse_picker_cubit.dart';
import '../auth/auth_session_controller.dart';
import '../auth/stored_session_wipe.dart';
import '../constants/app_constants.dart';
import '../error/failures.dart';
import '../locale/locale_cubit.dart';
import '../locale/locale_repository.dart';
import '../network/auth_interceptor.dart';
import '../network/error_interceptor.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  await wipeStoredSession(secureStorage: secureStorage, prefs: prefs);

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<FlutterSecureStorage>(secureStorage)
    ..registerLazySingleton<LocaleRepository>(() => LocaleRepository(sl()))
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit(sl()))
    ..registerLazySingleton<AuthSessionController>(AuthSessionController.new)
    ..registerLazySingleton<AuthSessionStore>(InMemoryAuthSessionStore.new);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrlNormalized,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: <String, Object?>{'Content-Type': 'application/json'},
    ),
  );
  sl.registerSingleton<Dio>(dio);

  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: sl(), store: sl()),
    )
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => SelectCompanyUseCase(sl()))
    ..registerLazySingleton(() => FetchMeUseCase(sl()))
    ..registerLazySingleton(() => ChangePasswordUseCase(sl()))
    ..registerLazySingleton(() => SelectWarehouseUseCase(sl()))
    ..registerFactory(
      () => AuthBloc(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        selectCompanyUseCase: sl(),
        fetchMeUseCase: sl(),
      ),
    )
    ..registerFactory(() => ChangePasswordCubit(sl()))
    ..registerLazySingleton<WarehouseRemoteDataSource>(
      () => WarehouseRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<WarehouseRepository>(
      () => WarehouseRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetWarehousesUseCase(sl()))
    ..registerFactory(
      () => WarehousePickerCubit(
        getWarehousesUseCase: sl(),
        selectWarehouseUseCase: sl(),
      ),
    )
    ..registerLazySingleton<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => SearchCustomersUseCase(sl()))
    ..registerFactory(() => CustomerPickerCubit(searchCustomersUseCase: sl()))
    ..registerLazySingleton<SalesOrdersRemoteDataSource>(
      () => SalesOrdersRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<SalesOrdersRepository>(
      () => SalesOrdersRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetMySalesOrdersUseCase(sl()))
    ..registerLazySingleton(() => GetSalesOrderUseCase(sl()))
    ..registerLazySingleton(() => GetSalesOrderLinesUseCase(sl()))
    ..registerLazySingleton(() => CreateSalesOrderUseCase(sl()))
    ..registerFactory(() => SalesOrdersBloc(getMySalesOrdersUseCase: sl()))
    ..registerFactory(
      () => CreateOrderCubit(
        createSalesOrderUseCase: sl(),
        getSalesOrderUseCase: sl(),
        searchCustomersUseCase: sl(),
      ),
    )
    ..registerFactory(() => SoLinesCubit(getSalesOrderLinesUseCase: sl()))
    ..registerLazySingleton<CatalogRemoteDataSource>(
      () => CatalogRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => LookupBarcodeUseCase(sl()))
    ..registerLazySingleton(() => ResolvePriceUseCase(sl()))
    ..registerLazySingleton(() => GetOnHandUseCase(sl()))
    ..registerLazySingleton(() => SubmitFullLineUseCase(sl()))
    ..registerLazySingleton(() => SubmitQuickBatchUseCase(sl()))
    ..registerLazySingleton(() => GetFailedLinesUseCase(sl()))
    ..registerFactoryParam<FullAddBloc, SalesOrderHeaderEntity, String?>(
      (SalesOrderHeaderEntity order, String? sessionWarehouse) => FullAddBloc(
        order: order,
        lookupBarcodeUseCase: sl(),
        resolvePriceUseCase: sl(),
        getOnHandUseCase: sl(),
        submitFullLineUseCase: sl(),
        sessionWarehouse: sessionWarehouse,
      ),
    )
    ..registerFactoryParam<QuickAddBloc, SalesOrderHeaderEntity, void>(
      (SalesOrderHeaderEntity order, _) =>
          QuickAddBloc(order: order, submitQuickBatchUseCase: sl()),
    )
    ..registerFactory(() => FailedLinesCubit(getFailedLinesUseCase: sl()));

  dio.interceptors.addAll(<Interceptor>[
    AuthInterceptor(
      tokenReader: () async => sl<AuthSessionStore>().accessToken,
      onRefresh: () async {
        final Either<Failure, AuthTokensEntity> result =
            await sl<AuthRepository>().refresh();
        return result.isRight();
      },
      onRefreshFailed: () {
        sl<AuthSessionStore>().clear();
        sl<AuthSessionController>().notifyExpired();
      },
      dio: dio,
    ),
    ErrorInterceptor(),
    if (kDebugMode) PrettyDioLogger(requestBody: true, responseBody: true),
  ]);
}
