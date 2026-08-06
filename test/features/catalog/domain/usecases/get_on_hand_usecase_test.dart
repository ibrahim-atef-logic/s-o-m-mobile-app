import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/warehouse_on_hand_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/get_on_hand_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository mockRepo;
  late GetOnHandUseCase sut;

  const WarehouseOnHandEntity tOnHand = WarehouseOnHandEntity(
    itemNumber: 'BG410.003',
    warehouseId: 'MMS000WH',
    availableSalesQuantity: 25,
    availableOnHandQuantity: 30,
    unit: 'pcs',
    productName: 'Bag',
  );

  setUp(() {
    mockRepo = MockCatalogRepository();
    sut = GetOnHandUseCase(mockRepo);
  });

  test('returns ValidationFailure when item or warehouse empty', () async {
    final Either<Failure, WarehouseOnHandEntity> result = await sut(
      itemNumber: '',
      warehouse: 'MMS000WH',
      company: 'mm',
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => mockRepo.getOnHand(
        itemNumber: any(named: 'itemNumber'),
        warehouse: any(named: 'warehouse'),
        company: any(named: 'company'),
      ),
    );
  });

  test('forwards params to repository on success', () async {
    when(
      () => mockRepo.getOnHand(
        itemNumber: any(named: 'itemNumber'),
        warehouse: any(named: 'warehouse'),
        company: any(named: 'company'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, WarehouseOnHandEntity>(tOnHand),
    );

    final Either<Failure, WarehouseOnHandEntity> result = await sut(
      itemNumber: 'BG410.003',
      warehouse: 'MMS000WH',
      company: 'mm',
    );

    expect(result, const Right<Failure, WarehouseOnHandEntity>(tOnHand));
    verify(
      () => mockRepo.getOnHand(
        itemNumber: 'BG410.003',
        warehouse: 'MMS000WH',
        company: 'mm',
      ),
    ).called(1);
  });
}
