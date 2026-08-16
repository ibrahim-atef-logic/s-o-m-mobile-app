import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/created_order_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/repositories/sales_orders_repository.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/create_sales_order_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockSalesOrdersRepository extends Mock implements SalesOrdersRepository {}

void main() {
  late MockSalesOrdersRepository repository;
  late CreateSalesOrderUseCase sut;

  const CreatedOrderEntity created = CreatedOrderEntity(
    salesOrderNumber: Fixtures.createdSalesId,
    dataAreaId: 'mm',
    custAccount: 'MMS021',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MMS000',
    currencyCode: 'SAR',
    orderTakerPersonnelNumber: Fixtures.personnelNumber,
  );

  setUp(() {
    repository = MockSalesOrdersRepository();
    sut = CreateSalesOrderUseCase(repository);
  });

  void stubCreate() {
    when(
      () => repository.createOrder(
        company: any(named: 'company'),
        custAccount: any(named: 'custAccount'),
        inventLocationId: any(named: 'inventLocationId'),
        inventSiteId: any(named: 'inventSiteId'),
        currencyCode: any(named: 'currencyCode'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, CreatedOrderEntity>(created),
    );
  }

  test('sends the DataArea, customer, warehouse and currency', () async {
    stubCreate();

    final Either<Failure, CreatedOrderEntity> result = await sut(
      company: ' mm ',
      custAccount: ' MMS021 ',
      inventLocationId: Fixtures.warehouse,
      currencyCode: 'SAR',
    );

    expect(result.toNullable()?.salesOrderNumber, Fixtures.createdSalesId);
    verify(
      () => repository.createOrder(
        company: 'mm',
        custAccount: 'MMS021',
        inventLocationId: Fixtures.warehouse,
        inventSiteId: null,
        currencyCode: 'SAR',
      ),
    ).called(1);
  });

  test('rejects a missing customer before calling the API', () async {
    final Either<Failure, CreatedOrderEntity> result = await sut(
      company: 'mm',
      custAccount: '   ',
    );

    expect(result.getLeft().toNullable()?.message, 'CUSTOMER_REQUIRED');
    verifyNever(
      () => repository.createOrder(
        company: any(named: 'company'),
        custAccount: any(named: 'custAccount'),
      ),
    );
  });

  test('rejects a missing company before calling the API', () async {
    final Either<Failure, CreatedOrderEntity> result = await sut(
      company: '  ',
      custAccount: 'MMS021',
    );

    expect(result.getLeft().toNullable()?.message, 'COMPANY_REQUIRED');
  });

  test('created order maps to a usable header for the detail screen', () {
    expect(
      created.toHeader(salesName: 'عميل نقدي').salesId,
      Fixtures.createdSalesId,
    );
    expect(created.toHeader().dataArea, 'mm');
    expect(created.toHeader().inventLocationId, Fixtures.warehouse);
  });
}
