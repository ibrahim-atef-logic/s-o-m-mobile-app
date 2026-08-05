import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_submit_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_quick_batch_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepo;
  late SubmitQuickBatchUseCase sut;

  const LineSubmitResultEntity tResult = LineSubmitResultEntity(
    success: true,
    jobId: 'job-q',
  );

  setUp(() {
    mockRepo = MockCatalogRepository();
    sut = SubmitQuickBatchUseCase(mockRepo);
  });

  test('returns result on success', () async {
    when(
      () => mockRepo.submitQuickBatch(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        lines: any(named: 'lines'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, LineSubmitResultEntity>(tResult),
    );

    final Either<Failure, LineSubmitResultEntity> result = await sut(
      salesId: 'SO-000101',
      company: 'usmf',
      lines: <({String barcode, num quantity})>[
        (barcode: '6281001000003', quantity: 1),
      ],
    );

    expect(result, const Right<Failure, LineSubmitResultEntity>(tResult));
  });

  test('returns ValidationFailure when lines empty', () async {
    final Either<Failure, LineSubmitResultEntity> result = await sut(
      salesId: 'SO-000101',
      company: 'usmf',
      lines: <({String barcode, num quantity})>[],
    );
    expect(result.isLeft(), isTrue);
  });

  test('returns ValidationFailure when more than 10 lines', () async {
    final List<({String barcode, num quantity})> lines =
        List<({String barcode, num quantity})>.generate(
          11,
          (int i) => (barcode: 'b$i', quantity: 1),
        );
    final Either<Failure, LineSubmitResultEntity> result = await sut(
      salesId: 'SO-000101',
      company: 'usmf',
      lines: lines,
    );
    expect(result.isLeft(), isTrue);
  });
}
