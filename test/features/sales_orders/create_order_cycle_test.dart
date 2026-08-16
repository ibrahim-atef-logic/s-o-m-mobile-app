import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/api_error_code.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/core/network/error_interceptor.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_session_store.dart';
import 'package:logic_retail_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:logic_retail_mobile/features/customers/data/datasources/customer_remote_data_source.dart';
import 'package:logic_retail_mobile/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';
import 'package:logic_retail_mobile/features/customers/domain/usecases/search_customers_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/datasources/sales_orders_remote_data_source.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/repositories/sales_orders_repository_impl.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/created_order_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/create_sales_order_usecase.dart';

import '../../helpers/activation_cycle_adapter.dart';
import '../../helpers/fixtures.dart';

/// Create-order cycle against the in-memory .NET API: login, search customers,
/// create the order with the session DataArea/warehouse.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ActivationCycleAdapter adapter;
  late Dio dio;
  late AuthRepositoryImpl auth;
  late SearchCustomersUseCase searchCustomers;
  late CreateSalesOrderUseCase createOrder;

  setUp(() {
    adapter = ActivationCycleAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://cycle.test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(ErrorInterceptor());
    auth = AuthRepositoryImpl(
      remote: AuthRemoteDataSourceImpl(dio),
      store: InMemoryAuthSessionStore(),
    );
    searchCustomers = SearchCustomersUseCase(
      CustomerRepositoryImpl(CustomerRemoteDataSourceImpl(dio)),
    );
    createOrder = CreateSalesOrderUseCase(
      SalesOrdersRepositoryImpl(SalesOrdersRemoteDataSourceImpl(dio)),
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

  test('1006 searches customers and creates an order in mm', () async {
    final UserSessionEntity session = await login(Fixtures.personnelNumber);
    expect(session.orderDataArea, 'mm');

    final Either<Failure, List<CustomerEntity>> found = await searchCustomers(
      company: session.orderDataArea,
      search: 'MMS',
    );
    final List<CustomerEntity> customers = found.getOrElse(
      (_) => <CustomerEntity>[],
    );
    expect(customers, hasLength(1));
    expect(customers.first.customerAccount, 'MMS021');

    final Either<Failure, CreatedOrderEntity> result = await createOrder(
      company: session.orderDataArea,
      custAccount: customers.first.customerAccount,
      inventLocationId: session.resolvedWarehouse,
      currencyCode: session.currency,
    );

    final CreatedOrderEntity created = result.getOrElse(
      (_) => throw StateError('create'),
    );
    expect(created.salesOrderNumber, Fixtures.createdSalesId);
    expect(created.dataAreaId, 'mm');
    expect(created.inventLocationId, Fixtures.warehouse);

    final RequestOptions post = adapter.requests.lastWhere(
      (RequestOptions r) =>
          r.method == 'POST' && r.path.endsWith('/sales-orders'),
    );
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      post.data as Map<dynamic, dynamic>,
    );
    expect(body['company'], 'mm');
    expect(body['company'], isNot(Fixtures.loginCompany));
    expect(body['custAccount'], 'MMS021');
    expect(body['inventLocationId'], Fixtures.warehouse);
    expect(body.containsKey('workerRecId'), isFalse);
  });

  test('12344 without a warehouse gets WAREHOUSE_REQUIRED', () async {
    final UserSessionEntity session = await login('12344');
    expect(session.warehouseMissing, isTrue);

    final Either<Failure, CreatedOrderEntity> result = await createOrder(
      company: session.orderDataArea,
      custAccount: 'PL-001',
      inventLocationId: session.resolvedWarehouse,
    );

    final Failure? failure = result.getLeft().toNullable();
    expect(failure?.isWarehouseRequired, isTrue);
  });

  test('the login registry key is rejected for customers and create', () async {
    await login(Fixtures.personnelNumber);

    final Either<Failure, List<CustomerEntity>> customers =
        await searchCustomers(company: Fixtures.loginCompany);
    final Either<Failure, CreatedOrderEntity> created = await createOrder(
      company: Fixtures.loginCompany,
      custAccount: 'MMS021',
      inventLocationId: Fixtures.warehouse,
    );

    expect(customers.getLeft().toNullable()?.isForbiddenCompany, isTrue);
    expect(created.getLeft().toNullable()?.isForbiddenCompany, isTrue);
  });
}
