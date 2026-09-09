import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_page_result.dart';
import 'package:logic_retail_mobile/features/customers/domain/usecases/search_customers_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/created_order_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/create_sales_order_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_sales_order_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/presentation/cubit/create_order_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockCreateSalesOrderUseCase extends Mock
    implements CreateSalesOrderUseCase {}

class MockGetSalesOrderUseCase extends Mock implements GetSalesOrderUseCase {}

class MockSearchCustomersUseCase extends Mock
    implements SearchCustomersUseCase {}

void main() {
  late MockCreateSalesOrderUseCase create;
  late MockGetSalesOrderUseCase getOrder;
  late MockSearchCustomersUseCase search;

  const CustomerEntity defaultCustomer = CustomerEntity(
    dataAreaId: 'mm',
    customerAccount: Fixtures.defaultCustAccount,
    name: 'Trial Customer',
  );
  const CustomerEntity picked = CustomerEntity(
    dataAreaId: 'mm',
    customerAccount: 'MMS021',
    name: 'عميل نقدي ميرا مارت جدة 01',
  );

  const UserSessionEntity session = UserSessionEntity(
    personnelNumber: Fixtures.personnelNumber,
    workerRecId: 5637227826,
    name: 'محمد عفيف',
    companies: <CompanyEntity>[
      CompanyEntity(code: 'mm', name: 'mm', groupId: ''),
    ],
    company: 'mm',
    activeCompany: 'mm',
    inventLocationDataAreaId: 'mm',
    activeWarehouse: Fixtures.warehouse,
    inventLocation: Fixtures.warehouse,
    currency: 'SAR',
    defaultCustAccount: Fixtures.defaultCustAccount,
    needsWarehouseSelection: false,
  );

  const CreatedOrderEntity created = CreatedOrderEntity(
    salesOrderNumber: Fixtures.createdSalesId,
    dataAreaId: 'mm',
    custAccount: 'MMS021',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MMS000',
    currencyCode: 'SAR',
  );

  const SalesOrderHeaderEntity header = SalesOrderHeaderEntity(
    salesId: Fixtures.createdSalesId,
    custAccount: 'MMS021',
    salesName: 'عميل نقدي ميرا مارت جدة 01',
    dataArea: 'mm',
    priceGroupId: 'RETAIL',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MMS000',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  CreateOrderCubit build() => CreateOrderCubit(
    createSalesOrderUseCase: create,
    getSalesOrderUseCase: getOrder,
    searchCustomersUseCase: search,
  );

  void stubDefaultCustomer() {
    when(
      () => search(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, CustomerPageResult>(
        CustomerPageResult(
          items: const <CustomerEntity>[defaultCustomer],
          top: 30,
          skip: 0,
          count: 1,
          hasMore: false,
        ),
      ),
    );
  }

  void stubCreate(Either<Failure, CreatedOrderEntity> result) {
    when(
      () => create(
        company: any(named: 'company'),
        custAccount: any(named: 'custAccount'),
        inventLocationId: any(named: 'inventLocationId'),
        inventSiteId: any(named: 'inventSiteId'),
        currencyCode: any(named: 'currencyCode'),
      ),
    ).thenAnswer((_) async => result);
  }

  setUp(() {
    create = MockCreateSalesOrderUseCase();
    getOrder = MockGetSalesOrderUseCase();
    search = MockSearchCustomersUseCase();
  });

  blocTest<CreateOrderCubit, CreateOrderState>(
    'seeds company/warehouse from the session and preselects its customer',
    setUp: stubDefaultCustomer,
    build: build,
    act: (CreateOrderCubit cubit) => cubit.start(session),
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.company, 'mm');
      expect(cubit.state.warehouse, Fixtures.warehouse);
      expect(cubit.state.customer, defaultCustomer);
      expect(cubit.state.canSubmit, isTrue);
      verify(
        () =>
            search(company: 'mm', search: Fixtures.defaultCustAccount, top: 10),
      ).called(1);
    },
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'the warehouse company wins over activeCompany for the DataArea',
    setUp: stubDefaultCustomer,
    build: build,
    act: (CreateOrderCubit cubit) => cubit.start(
      session.copyWith(activeCompany: 'PLTR', inventLocationDataAreaId: 'mm'),
    ),
    verify: (CreateOrderCubit cubit) => expect(cubit.state.company, 'mm'),
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'a session without a warehouse opens the picker and cannot submit yet',
    setUp: stubDefaultCustomer,
    build: build,
    act: (CreateOrderCubit cubit) => cubit.start(
      const UserSessionEntity(
        personnelNumber: '12344',
        workerRecId: 2,
        name: 'Trial',
        companies: <CompanyEntity>[
          CompanyEntity(code: 'mm', name: 'mm', groupId: ''),
        ],
        activeCompany: 'mm',
        needsWarehouseSelection: true,
        defaultCustAccount: Fixtures.defaultCustAccount,
      ),
    ),
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.warehouse, isNull);
      expect(cubit.state.canSubmit, isFalse);
    },
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'creates the order and re-reads the header for the detail screen',
    setUp: () {
      stubDefaultCustomer();
      stubCreate(const Right<Failure, CreatedOrderEntity>(created));
      when(
        () => getOrder(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, SalesOrderHeaderEntity>(header),
      );
    },
    build: build,
    act: (CreateOrderCubit cubit) async {
      await cubit.start(session);
      cubit.selectCustomer(picked);
      await cubit.submit();
    },
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.createdOrder, header);
      expect(cubit.state.submitting, isFalse);
      verify(
        () => create(
          company: 'mm',
          custAccount: 'MMS021',
          inventLocationId: Fixtures.warehouse,
        ),
      ).called(1);
      verify(
        () => getOrder(salesId: Fixtures.createdSalesId, company: 'mm'),
      ).called(1);
    },
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'falls back to the create response when the header re-read fails',
    setUp: () {
      stubDefaultCustomer();
      stubCreate(const Right<Failure, CreatedOrderEntity>(created));
      when(
        () => getOrder(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, SalesOrderHeaderEntity>(NetworkFailure()),
      );
    },
    build: build,
    act: (CreateOrderCubit cubit) async {
      await cubit.start(session);
      cubit.selectCustomer(picked);
      await cubit.submit();
    },
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.createdOrder?.salesId, Fixtures.createdSalesId);
      expect(cubit.state.createdOrder?.salesName, picked.displayName);
    },
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'WAREHOUSE_REQUIRED asks the screen to open the warehouse picker',
    setUp: () {
      stubDefaultCustomer();
      stubCreate(
        const Left<Failure, CreatedOrderEntity>(
          ServerFailure('WAREHOUSE_REQUIRED: No warehouse for this user'),
        ),
      );
    },
    build: build,
    act: (CreateOrderCubit cubit) async {
      await cubit.start(session);
      await cubit.submit();
    },
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.warehouseRequired, isTrue);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.createdOrder, isNull);
    },
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'VALIDATION_ERROR becomes an inline customer error',
    setUp: () {
      stubDefaultCustomer();
      stubCreate(
        const Left<Failure, CreatedOrderEntity>(
          ServerFailure('VALIDATION_ERROR: custAccount is required'),
        ),
      );
    },
    build: build,
    act: (CreateOrderCubit cubit) async {
      await cubit.start(session);
      await cubit.submit();
    },
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.customerError, isNotNull);
      expect(cubit.state.failure, isNull);
    },
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'FORBIDDEN_COMPANY surfaces as a plain failure for the toast',
    setUp: () {
      stubDefaultCustomer();
      stubCreate(
        const Left<Failure, CreatedOrderEntity>(
          ServerFailure('FORBIDDEN_COMPANY: Company not allowed for token'),
        ),
      );
    },
    build: build,
    act: (CreateOrderCubit cubit) async {
      await cubit.start(session);
      await cubit.submit();
    },
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.failure, isA<ServerFailure>());
      expect(cubit.state.warehouseRequired, isFalse);
    },
  );

  blocTest<CreateOrderCubit, CreateOrderState>(
    'a session without a default customer cannot submit yet',
    build: build,
    act: (CreateOrderCubit cubit) async {
      await cubit.start(session.copyWith(defaultCustAccount: ''));
      await cubit.submit();
    },
    verify: (CreateOrderCubit cubit) {
      expect(cubit.state.canSubmit, isFalse);
      expect(cubit.state.customerError, 'CUSTOMER_REQUIRED');
      verifyNever(
        () => create(
          company: any(named: 'company'),
          custAccount: any(named: 'custAccount'),
        ),
      );
    },
  );
}
