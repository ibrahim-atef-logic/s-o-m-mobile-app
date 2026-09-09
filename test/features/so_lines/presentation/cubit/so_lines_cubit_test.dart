import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_line_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/delete_sales_order_line_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_sales_order_lines_usecase.dart';
import 'package:logic_retail_mobile/features/so_lines/presentation/cubit/so_lines_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSalesOrderLinesUseCase extends Mock
    implements GetSalesOrderLinesUseCase {}

class MockDeleteSalesOrderLineUseCase extends Mock
    implements DeleteSalesOrderLineUseCase {}

void main() {
  late MockGetSalesOrderLinesUseCase useCase;
  late MockDeleteSalesOrderLineUseCase deleteUseCase;
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

  const SalesOrderLineEntity line2 = SalesOrderLineEntity(
    recordId: 2,
    salesId: 'SO-000100',
    itemId: '2000',
    productName: 'Keyboard',
    salesQty: 1,
    salesUnit: 'ea',
    lineNum: 2,
    dataArea: 'usmf',
  );

  setUp(() {
    useCase = MockGetSalesOrderLinesUseCase();
    deleteUseCase = MockDeleteSalesOrderLineUseCase();
    cubit = SoLinesCubit(
      getSalesOrderLinesUseCase: useCase,
      deleteSalesOrderLineUseCase: deleteUseCase,
    );
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

  test('deleteLine removes matching recordId on success', () async {
    when(
      () => useCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<SalesOrderLineEntity>>(
        <SalesOrderLineEntity>[line, line2],
      ),
    );
    when(
      () => deleteUseCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        recordId: any(named: 'recordId'),
      ),
    ).thenAnswer((_) async => const Right<Failure, void>(null));

    await cubit.load(salesId: 'SO-000100', company: 'usmf');
    await cubit.deleteLine(salesId: 'SO-000100', company: 'mm', recordId: 1);

    final SoLinesState state = cubit.state;
    expect(state, isA<SoLinesLoaded>());
    expect((state as SoLinesLoaded).lines, <SalesOrderLineEntity>[line2]);
  });

  test('deleteLine treats LINE_NOT_FOUND as success', () async {
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
    when(
      () => deleteUseCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        recordId: any(named: 'recordId'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, void>(
        ServerFailure('LINE_NOT_FOUND: Line not found'),
      ),
    );

    await cubit.load(salesId: 'SO-000100', company: 'usmf');
    await cubit.deleteLine(salesId: 'SO-000100', company: 'mm', recordId: 1);

    expect(cubit.state, const SoLinesLoaded(<SalesOrderLineEntity>[]));
  });

  test('deleteLine keeps lines and sets actionFailure on 409', () async {
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
    when(
      () => deleteUseCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        recordId: any(named: 'recordId'),
      ),
    ).thenAnswer(
      (_) async => const Left<Failure, void>(
        ServerFailure('ORDER_NOT_EDITABLE: Order confirmed / الأمر مؤكد'),
      ),
    );

    await cubit.load(salesId: 'SO-000100', company: 'usmf');
    await cubit.deleteLine(salesId: 'SO-000100', company: 'mm', recordId: 1);

    final SoLinesState state = cubit.state;
    expect(state, isA<SoLinesLoaded>());
    final SoLinesLoaded loaded = state as SoLinesLoaded;
    expect(loaded.lines, <SalesOrderLineEntity>[line]);
    expect(
      loaded.actionFailure,
      const ServerFailure('ORDER_NOT_EDITABLE: Order confirmed / الأمر مؤكد'),
    );
  });
}
