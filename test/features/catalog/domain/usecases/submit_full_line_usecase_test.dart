import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_item_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_submit_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_full_line_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepo;
  late SubmitFullLineUseCase sut;

  const LineSubmitResultEntity tResult = LineSubmitResultEntity(
    success: true,
    jobId: 'job-1',
    item: LineItemResultEntity(
      id: 'i1',
      itemNumber: '2000',
      quantity: 2,
      status: 'synced',
    ),
  );

  setUp(() {
    mockRepo = MockCatalogRepository();
    sut = SubmitFullLineUseCase(mockRepo);
  });

  test('returns result on success', () async {
    when(
      () => mockRepo.submitFullLine(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        itemNumber: any(named: 'itemNumber'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, LineSubmitResultEntity>(tResult),
    );

    final Either<Failure, LineSubmitResultEntity> result = await sut(
      salesId: 'SO-000100',
      company: 'usmf',
      itemNumber: '2000',
      quantity: 2,
    );

    expect(result, const Right<Failure, LineSubmitResultEntity>(tResult));
  });

  test('returns ValidationFailure for invalid quantity', () async {
    final Either<Failure, LineSubmitResultEntity> result = await sut(
      salesId: 'SO-000100',
      company: 'usmf',
      itemNumber: '2000',
      quantity: 0,
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.submitFullLine(
        salesId: any(named: 'salesId'),
        company: any(named: 'company'),
        itemNumber: any(named: 'itemNumber'),
        quantity: any(named: 'quantity'),
      ),
    );
  });

  test('returns ValidationFailure for decimal quantity', () async {
    final Either<Failure, LineSubmitResultEntity> result = await sut(
      salesId: 'SO-000100',
      company: 'usmf',
      itemNumber: '2000',
      quantity: 1.5,
    );
    expect(result.isLeft(), isTrue);
  });
}
