import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_barcode_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepo;
  late LookupBarcodeUseCase sut;

  const BarcodeItemEntity tItem = BarcodeItemEntity(
    barcode: '6281001000002',
    itemNumber: '2000',
    productName: 'Keyboard',
    productDescription: 'KB',
    unitId: 'ea',
    dataArea: 'usmf',
  );

  setUp(() {
    mockRepo = MockCatalogRepository();
    sut = LookupBarcodeUseCase(mockRepo);
  });

  test('returns barcode item on success', () async {
    when(
      () => mockRepo.lookupBarcode(
        code: any(named: 'code'),
        company: any(named: 'company'),
      ),
    ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(tItem));

    final Either<Failure, BarcodeItemEntity> result = await sut(
      code: '6281001000002',
      company: 'usmf',
    );

    expect(result, const Right<Failure, BarcodeItemEntity>(tItem));
    verify(
      () => mockRepo.lookupBarcode(code: '6281001000002', company: 'usmf'),
    ).called(1);
  });

  test('returns ValidationFailure when barcode empty', () async {
    final Either<Failure, BarcodeItemEntity> result = await sut(
      code: '  ',
      company: 'usmf',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.lookupBarcode(
        code: any(named: 'code'),
        company: any(named: 'company'),
      ),
    );
  });

  test('returns ServerFailure from repository', () async {
    when(
      () => mockRepo.lookupBarcode(
        code: any(named: 'code'),
        company: any(named: 'company'),
      ),
    ).thenAnswer(
      (_) async =>
          const Left<Failure, BarcodeItemEntity>(ServerFailure('not found')),
    );

    final Either<Failure, BarcodeItemEntity> result = await sut(
      code: '999',
      company: 'usmf',
    );

    expect(
      result,
      const Left<Failure, BarcodeItemEntity>(ServerFailure('not found')),
    );
  });
}
