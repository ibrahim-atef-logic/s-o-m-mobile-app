import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/price_info_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/resolve_price_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepo;
  late ResolvePriceUseCase sut;

  const PriceInfoEntity tPrice = PriceInfoEntity(
    itemNumber: 'BG410.003',
    price: 12.5,
    unitId: 'pcs',
    currency: 'SAR',
  );

  setUp(() {
    mockRepo = MockCatalogRepository();
    sut = ResolvePriceUseCase(mockRepo);
  });

  test('returns ValidationFailure when item/company empty', () async {
    final Either<Failure, PriceInfoEntity> result = await sut(
      itemNumber: ' ',
      company: 'mm',
      salesUnitId: 'pcs',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.resolvePrice(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
        salesUnitId: any(named: 'salesUnitId'),
        warehouseId: any(named: 'warehouseId'),
        channelRecId: any(named: 'channelRecId'),
      ),
    );
  });

  test('allows empty salesUnitId for DataAreas that resolve without unit', () async {
    when(
      () => mockRepo.resolvePrice(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
        salesUnitId: any(named: 'salesUnitId'),
        warehouseId: any(named: 'warehouseId'),
        channelRecId: any(named: 'channelRecId'),
      ),
    ).thenAnswer((_) async => const Right<Failure, PriceInfoEntity>(tPrice));

    final Either<Failure, PriceInfoEntity> result = await sut(
      itemNumber: 'BG410.003',
      company: 'ty',
      salesUnitId: '',
    );

    expect(result, const Right<Failure, PriceInfoEntity>(tPrice));
    verify(
      () => mockRepo.resolvePrice(
        itemNumber: 'BG410.003',
        company: 'ty',
        salesUnitId: '',
        warehouseId: null,
        channelRecId: null,
      ),
    ).called(1);
  });

  test('forwards salesUnitId warehouse and channel to repository', () async {
    when(
      () => mockRepo.resolvePrice(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
        salesUnitId: any(named: 'salesUnitId'),
        warehouseId: any(named: 'warehouseId'),
        channelRecId: any(named: 'channelRecId'),
      ),
    ).thenAnswer((_) async => const Right<Failure, PriceInfoEntity>(tPrice));

    final Either<Failure, PriceInfoEntity> result = await sut(
      itemNumber: ' BG410.003 ',
      company: ' mm ',
      salesUnitId: ' pcs ',
      warehouseId: ' MMS000WH ',
      channelRecId: 5637152827,
    );

    expect(result, const Right<Failure, PriceInfoEntity>(tPrice));
    verify(
      () => mockRepo.resolvePrice(
        itemNumber: 'BG410.003',
        company: 'mm',
        salesUnitId: 'pcs',
        warehouseId: 'MMS000WH',
        channelRecId: 5637152827,
      ),
    ).called(1);
  });
}
