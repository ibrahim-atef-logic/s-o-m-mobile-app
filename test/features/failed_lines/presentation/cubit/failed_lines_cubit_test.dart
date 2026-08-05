import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/failed_line_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_failed_lines_usecase.dart';
import 'package:logic_retail_mobile/features/failed_lines/presentation/cubit/failed_lines_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFailedLinesUseCase extends Mock implements GetFailedLinesUseCase {}

void main() {
  late MockGetFailedLinesUseCase useCase;
  late FailedLinesCubit cubit;

  const FailedLineEntity line = FailedLineEntity(
    id: 'f1',
    jobId: 'j1',
    itemNumber: '1000',
    quantity: 1,
    status: 'failed',
    commentEn: 'No price',
    commentAr: 'لا سعر',
  );

  setUp(() {
    useCase = MockGetFailedLinesUseCase();
    cubit = FailedLinesCubit(getFailedLinesUseCase: useCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('load success emits loaded', () async {
    when(
      () => useCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<FailedLineEntity>>(
        <FailedLineEntity>[line],
      ),
    );

    expectLater(
      cubit.stream,
      emitsInOrder(<FailedLinesState>[
        const FailedLinesLoading(),
        const FailedLinesLoaded(<FailedLineEntity>[line]),
      ]),
    );

    await cubit.load(salesId: 'SO-000100', company: 'usmf', mode: 'full');
  });

  test('load failure emits failure', () async {
    when(
      () => useCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer(
      (_) async =>
          const Left<Failure, List<FailedLineEntity>>(ServerFailure('boom')),
    );

    expectLater(
      cubit.stream,
      emitsInOrder(<FailedLinesState>[
        const FailedLinesLoading(),
        const FailedLinesFailure(ServerFailure('boom')),
      ]),
    );

    await cubit.load(salesId: 'SO-000100', company: 'usmf');
  });
}
