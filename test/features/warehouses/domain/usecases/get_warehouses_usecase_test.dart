import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/entities/warehouse_entity.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/repositories/warehouse_repository.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/usecases/get_warehouses_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

void main() {
  late MockWarehouseRepository repository;
  late GetWarehousesUseCase sut;

  const List<WarehouseEntity> warehouses = <WarehouseEntity>[
    WarehouseEntity(
      dataAreaId: 'mm',
      inventLocationId: 'MMS000WH',
      name: 'Main warehouse',
      inventSiteId: 'MMS000',
      inventLocationType: 'Standard',
    ),
  ];

  setUp(() {
    repository = MockWarehouseRepository();
    sut = GetWarehousesUseCase(repository);
  });

  test('returns warehouses for the trimmed operating company', () async {
    when(() => repository.getWarehouses(any())).thenAnswer(
      (_) async => const Right<Failure, List<WarehouseEntity>>(warehouses),
    );

    final Either<Failure, List<WarehouseEntity>> result = await sut(' mm ');

    expect(result.getOrElse((_) => <WarehouseEntity>[]), warehouses);
    verify(() => repository.getWarehouses('mm')).called(1);
  });

  test('rejects an empty company without hitting the API', () async {
    final Either<Failure, List<WarehouseEntity>> result = await sut('  ');

    expect(result.isLeft(), isTrue);
    expect(
      result.getLeft().toNullable(),
      isA<ValidationFailure>().having(
        (ValidationFailure f) => f.message,
        'message',
        'COMPANY_REQUIRED',
      ),
    );
    verifyNever(() => repository.getWarehouses(any()));
  });
}
