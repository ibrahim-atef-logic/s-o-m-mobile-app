import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_line_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_sales_order_lines_usecase.dart';
import 'package:logic_retail_mobile/features/so_lines/presentation/cubit/so_lines_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSalesOrderLinesUseCase extends Mock
    implements GetSalesOrderLinesUseCase {}

void main() {
  late MockGetSalesOrderLinesUseCase useCase;
  late SoLinesCubit cubit;

  const SalesOrderLineEntity line = SalesOrderLineEntity(
    recordId: 1,
    salesId: 'SO-000100',
    itemId: '1000',
    productName: 'Mouse',
    salesQty: 2,
    salesUnit: 'ea',
    lineNum: 1,
    dataArea: 'usmf',
  );

  setUp(() {
    useCase = MockGetSalesOrderLinesUseCase();
    cubit = SoLinesCubit(getSalesOrderLinesUseCase: useCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('load success emits loaded', () async {
    when(
      () => useCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<SalesOrderLineEntity>>(
        <SalesOrderLineEntity>[line],
      ),
    );

    expectLater(
      cubit.stream,
      emitsInOrder(<SoLinesState>[
        const SoLinesLoading(),
        const SoLinesLoaded(<SalesOrderLineEntity>[line]),
      ]),
    );

    await cubit.load(salesId: 'SO-000100', company: 'usmf');
  });

  test('load failure emits failure', () async {
    when(
      () => useCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, List<SalesOrderLineEntity>>(
        ServerFailure('boom'),
      ),
    );

    expectLater(
      cubit.stream,
      emitsInOrder(<SoLinesState>[
        const SoLinesLoading(),
        const SoLinesFailure(ServerFailure('boom')),
      ]),
    );

    await cubit.load(salesId: 'SO-000100', company: 'usmf');
  });
}
