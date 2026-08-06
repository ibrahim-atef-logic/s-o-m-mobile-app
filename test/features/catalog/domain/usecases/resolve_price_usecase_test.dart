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
    customerAccountNumber: '20-10004',
    priceCustomerGroupCode: 'RETAIL',
    dataArea: 'mm',
  );

  setUp(() {
    mockRepo = MockCatalogRepository();
    sut = ResolvePriceUseCase(mockRepo);
  });

  test('returns ValidationFailure when item or company empty', () async {
    final Either<Failure, PriceInfoEntity> result = await sut(
      itemNumber: ' ',
      company: 'mm',
      custAccount: '20-10004',
      priceGroup: 'RETAIL',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.resolvePrice(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
        custAccount: any(named: 'custAccount'),
        priceGroup: any(named: 'priceGroup'),
        unitId: any(named: 'unitId'),
      ),
    );
  });

  test('forwards unitId to repository', () async {
    when(
      () => mockRepo.resolvePrice(
        itemNumber: any(named: 'itemNumber'),
        company: any(named: 'company'),
        custAccount: any(named: 'custAccount'),
        priceGroup: any(named: 'priceGroup'),
        unitId: any(named: 'unitId'),
      ),
    ).thenAnswer((_) async => const Right<Failure, PriceInfoEntity>(tPrice));

    final Either<Failure, PriceInfoEntity> result = await sut(
      itemNumber: ' BG410.003 ',
      company: ' mm ',
      custAccount: '20-10004',
      priceGroup: 'RETAIL',
      unitId: ' pcs ',
    );

    expect(result, const Right<Failure, PriceInfoEntity>(tPrice));
    verify(
      () => mockRepo.resolvePrice(
        itemNumber: 'BG410.003',
        company: 'mm',
        custAccount: '20-10004',
        priceGroup: 'RETAIL',
        unitId: 'pcs',
      ),
    ).called(1);
  });
}
