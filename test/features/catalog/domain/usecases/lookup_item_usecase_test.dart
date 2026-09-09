import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/barcode_item_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/lookup_item_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepo;
  late LookupItemUseCase sut;

  const BarcodeItemEntity tItem = BarcodeItemEntity(
    barcode: '6287007961754',
    itemNumber: 'BG410.003',
    productName: 'Drill',
    productDescription: 'Bosch',
    unitId: 'ea',
    dataArea: 'mm',
  );

  setUp(() {
    mockRepo = MockCatalogRepository();
    sut = LookupItemUseCase(mockRepo);
  });

  test('returns item on success', () async {
    when(
      () => mockRepo.lookupItem(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
      ),
    ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(tItem));

    final Either<Failure, BarcodeItemEntity> result = await sut(
      itemNumber: 'BG410.003',
      company: 'mm',
    );

    expect(result, const Right<Failure, BarcodeItemEntity>(tItem));
    verify(
      () => mockRepo.lookupItem(itemNumber: 'BG410.003', company: 'mm'),
    ).called(1);
  });

  test('returns ValidationFailure when item number empty', () async {
    final Either<Failure, BarcodeItemEntity> result = await sut(
      itemNumber: '  ',
      company: 'mm',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.lookupItem(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
      ),
    );
  });

  test('forwards item number with internal spaces', () async {
    when(
      () => mockRepo.lookupItem(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
      ),
    ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(tItem));

    await sut(itemNumber: 'BG 410.003', company: 'mm');

    verify(
      () => mockRepo.lookupItem(itemNumber: 'BG 410.003', company: 'mm'),
    ).called(1);
  });

  test('forwards padded item number without trim', () async {
    when(
      () => mockRepo.lookupItem(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
      ),
    ).thenAnswer((_) async => const Right<Failure, BarcodeItemEntity>(tItem));

    await sut(itemNumber: '  BG410.003  ', company: 'mm');

    verify(
      () => mockRepo.lookupItem(itemNumber: '  BG410.003  ', company: 'mm'),
    ).called(1);
  });
}
