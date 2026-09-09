import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/repositories/sales_orders_repository.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_my_sales_orders_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesOrdersRepository extends Mock implements SalesOrdersRepository {}

void main() {
  late MockSalesOrdersRepository repo;
  late GetMySalesOrdersUseCase sut;

  setUp(() {
    repo = MockSalesOrdersRepository();
    sut = GetMySalesOrdersUseCase(repo);
  });

  test('returns ValidationFailure when company empty', () async {
    final Either<Failure, List<SalesOrderHeaderEntity>> result = await sut(
      company: '',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(() => repo.getMyOrders(company: any(named: 'company')));
  });

  test('returns orders from repository, sorted', () async {
    const SalesOrderHeaderEntity older = SalesOrderHeaderEntity(
      salesId: 'MM-1',
      custAccount: 'C',
      salesName: 'N',
      dataArea: 'usmf',
      priceGroupId: '',
      inventLocationId: '',
      inventSiteId: '',
      salesStatus: '',
      documentStatus: '',
      createdDateTime: '2026-01-01T00:00:00Z',
    );
    const SalesOrderHeaderEntity newer = SalesOrderHeaderEntity(
      salesId: 'MM-2',
      custAccount: 'C',
      salesName: 'N',
      dataArea: 'usmf',
      priceGroupId: '',
      inventLocationId: '',
      inventSiteId: '',
      salesStatus: '',
      documentStatus: '',
      createdDateTime: '2026-08-01T00:00:00Z',
    );
    when(() => repo.getMyOrders(company: 'usmf')).thenAnswer(
      (_) async => const Right<Failure, List<SalesOrderHeaderEntity>>(
        <SalesOrderHeaderEntity>[older, newer],
      ),
    );
    final Either<Failure, List<SalesOrderHeaderEntity>> result = await sut(
      company: 'usmf',
    );
    expect(
      result
          .getOrElse((_) => <SalesOrderHeaderEntity>[])
          .map((SalesOrderHeaderEntity o) => o.salesId)
          .toList(),
      <String>['MM-2', 'MM-1'],
    );
  });
}
