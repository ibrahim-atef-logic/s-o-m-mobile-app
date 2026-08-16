import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/select_warehouse_usecase.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/entities/warehouse_entity.dart';
import 'package:logic_retail_mobile/features/warehouses/domain/usecases/get_warehouses_usecase.dart';
import 'package:logic_retail_mobile/features/warehouses/presentation/cubit/warehouse_picker_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetWarehousesUseCase extends Mock implements GetWarehousesUseCase {}

class MockSelectWarehouseUseCase extends Mock
    implements SelectWarehouseUseCase {}

void main() {
  late MockGetWarehousesUseCase getWarehouses;
  late MockSelectWarehouseUseCase selectWarehouse;

  const WarehouseEntity mms000 = WarehouseEntity(
    dataAreaId: 'mm',
    inventLocationId: 'MMS000WH',
    name: 'Main warehouse',
    inventSiteId: 'MMS000',
    inventLocationType: 'Standard',
  );

  const UserSessionEntity picked = UserSessionEntity(
    personnelNumber: '12344',
    workerRecId: 2,
    name: 'مروان وهاس',
    companies: <CompanyEntity>[
      CompanyEntity(code: 'PLTR', name: 'PLTR', groupId: ''),
    ],
    activeCompany: 'PLTR',
    activeWarehouse: 'MMS000WH',
    inventLocation: 'MMS000WH',
    needsWarehouseSelection: false,
  );

  WarehousePickerCubit build() => WarehousePickerCubit(
    getWarehousesUseCase: getWarehouses,
    selectWarehouseUseCase: selectWarehouse,
  );

  setUp(() {
    getWarehouses = MockGetWarehousesUseCase();
    selectWarehouse = MockSelectWarehouseUseCase();
  });

  blocTest<WarehousePickerCubit, WarehousePickerState>(
    'emits loaded warehouses for the operating company',
    setUp: () {
      when(() => getWarehouses(any())).thenAnswer(
        (_) async => const Right<Failure, List<WarehouseEntity>>(
          <WarehouseEntity>[mms000],
        ),
      );
    },
    build: build,
    act: (WarehousePickerCubit cubit) => cubit.load('mm'),
    expect: () => <WarehousePickerState>[
      const WarehousePickerLoading(),
      const WarehousePickerLoaded(warehouses: <WarehouseEntity>[mms000]),
    ],
    verify: (_) => verify(() => getWarehouses('mm')).called(1),
  );

  blocTest<WarehousePickerCubit, WarehousePickerState>(
    'emits loaded with an empty list without crashing',
    setUp: () {
      when(() => getWarehouses(any())).thenAnswer(
        (_) async =>
            const Right<Failure, List<WarehouseEntity>>(<WarehouseEntity>[]),
      );
    },
    build: build,
    act: (WarehousePickerCubit cubit) => cubit.load('PLTR'),
    expect: () => <WarehousePickerState>[
      const WarehousePickerLoading(),
      const WarehousePickerLoaded(warehouses: <WarehouseEntity>[]),
    ],
  );

  blocTest<WarehousePickerCubit, WarehousePickerState>(
    'emits failure when the list cannot be loaded',
    setUp: () {
      when(() => getWarehouses(any())).thenAnswer(
        (_) async => const Left<Failure, List<WarehouseEntity>>(
          ServerFailure('FORBIDDEN_COMPANY'),
        ),
      );
    },
    build: build,
    act: (WarehousePickerCubit cubit) => cubit.load('logic-trial'),
    expect: () => <Matcher>[
      isA<WarehousePickerLoading>(),
      isA<WarehousePickerFailure>(),
    ],
  );

  blocTest<WarehousePickerCubit, WarehousePickerState>(
    'persists the picked warehouse and exposes the updated session',
    setUp: () {
      when(() => getWarehouses(any())).thenAnswer(
        (_) async => const Right<Failure, List<WarehouseEntity>>(
          <WarehouseEntity>[mms000],
        ),
      );
      when(
        () => selectWarehouse(
          inventLocationId: any(named: 'inventLocationId'),
          dataAreaId: any(named: 'dataAreaId'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, UserSessionEntity>(picked),
      );
    },
    build: build,
    act: (WarehousePickerCubit cubit) async {
      await cubit.load('PLTR');
      await cubit.select(mms000);
    },
    skip: 2,
    expect: () => <Matcher>[
      isA<WarehousePickerLoaded>().having(
        (WarehousePickerLoaded s) => s.saving,
        'saving',
        isTrue,
      ),
      isA<WarehousePickerSaved>().having(
        (WarehousePickerSaved s) => s.session.resolvedWarehouse,
        'warehouse',
        'MMS000WH',
      ),
    ],
    verify: (_) {
      verify(
        () => selectWarehouse(inventLocationId: 'MMS000WH', dataAreaId: 'mm'),
      ).called(1);
    },
  );

  blocTest<WarehousePickerCubit, WarehousePickerState>(
    'keeps the list and surfaces the failure when saving fails',
    setUp: () {
      when(() => getWarehouses(any())).thenAnswer(
        (_) async => const Right<Failure, List<WarehouseEntity>>(
          <WarehouseEntity>[mms000],
        ),
      );
      when(
        () => selectWarehouse(
          inventLocationId: any(named: 'inventLocationId'),
          dataAreaId: any(named: 'dataAreaId'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, UserSessionEntity>(CacheFailure()),
      );
    },
    build: build,
    act: (WarehousePickerCubit cubit) async {
      await cubit.load('mm');
      await cubit.select(mms000);
    },
    skip: 3,
    expect: () => <Matcher>[
      isA<WarehousePickerLoaded>()
          .having((WarehousePickerLoaded s) => s.saving, 'saving', isFalse)
          .having(
            (WarehousePickerLoaded s) => s.saveFailure,
            'saveFailure',
            isA<CacheFailure>(),
          ),
    ],
  );
}
