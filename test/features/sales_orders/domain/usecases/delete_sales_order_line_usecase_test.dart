import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/repositories/sales_orders_repository.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/delete_sales_order_line_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesOrdersRepository extends Mock implements SalesOrdersRepository {}

void main() {
  late MockSalesOrdersRepository mockRepo;
  late DeleteSalesOrderLineUseCase sut;

  setUp(() {
    mockRepo = MockSalesOrdersRepository();
    sut = DeleteSalesOrderLineUseCase(mockRepo);
  });

  test('delegates to repository', () async {
    when(
      () => mockRepo.deleteOrderLine(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        recordId: any(named: 'recordId'),
      ),
    ).thenAnswer((_) async => const Right<Failure, void>(null));

    final Either<Failure, void> result = await sut(
      salesId: 'MM-245531',
      company: 'mm',
      recordId: 123,
    );

    expect(result.isRight(), isTrue);
    verify(
      () => mockRepo.deleteOrderLine(
        salesId: 'MM-245531',
        company: 'mm',
        recordId: 123,
      ),
    ).called(1);
  });

  test('returns ValidationFailure for invalid recordId', () async {
    final Either<Failure, void> result = await sut(
      salesId: 'MM-1',
      company: 'mm',
      recordId: 0,
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.deleteOrderLine(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        recordId: any(named: 'recordId'),
      ),
    );
  });
}
