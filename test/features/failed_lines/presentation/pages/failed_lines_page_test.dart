import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logic_retail_mobile/core/di/injection.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/failed_line_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_failed_lines_usecase.dart';
import 'package:logic_retail_mobile/features/failed_lines/presentation/cubit/failed_lines_cubit.dart';
import 'package:logic_retail_mobile/features/failed_lines/presentation/pages/failed_lines_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_app.dart';

class MockGetFailedLinesUseCase extends Mock implements GetFailedLinesUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetFailedLinesUseCase mockUseCase;

  setUp(() async {
    await sl.reset();
    mockUseCase = MockGetFailedLinesUseCase();
    sl.registerFactory(
      () => FailedLinesCubit(getFailedLinesUseCase: mockUseCase),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('shows empty state when no failed lines', (WidgetTester tester) async {
    when(
      () => mockUseCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<FailedLineEntity>>(<FailedLineEntity>[]),
    );

    await pumpTestApp(
      tester,
      home: const FailedLinesPage(salesId: Fixtures.salesId, company: 'mm'),
    );
    await tester.pumpAndSettle();

    expect(find.text('No failed lines'), findsOneWidget);
  });

  testWidgets('shows one failed line item number', (WidgetTester tester) async {
    when(
      () => mockUseCase(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        mode: any(named: 'mode'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<FailedLineEntity>>(
        <FailedLineEntity>[
          FailedLineEntity(
            id: 'fl-1',
            jobId: 'job-1',
            itemNumber: Fixtures.itemNumber,
            quantity: 3,
            status: 'Failed',
            commentEn: 'Failed',
          ),
        ],
      ),
    );

    await pumpTestApp(
      tester,
      home: const FailedLinesPage(salesId: Fixtures.salesId, company: 'mm'),
    );
    await tester.pumpAndSettle();

    expect(find.text(Fixtures.itemNumber), findsOneWidget);
  });
}
