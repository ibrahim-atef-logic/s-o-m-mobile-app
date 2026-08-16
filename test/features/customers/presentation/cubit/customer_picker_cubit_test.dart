import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';
import 'package:logic_retail_mobile/features/customers/domain/usecases/search_customers_usecase.dart';
import 'package:logic_retail_mobile/features/customers/presentation/cubit/customer_picker_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchCustomersUseCase extends Mock
    implements SearchCustomersUseCase {}

void main() {
  late MockSearchCustomersUseCase search;

  const CustomerEntity mms021 = CustomerEntity(
    dataAreaId: 'mm',
    customerAccount: 'MMS021',
    name: 'عميل نقدي ميرا مارت جدة 01',
  );

  const Duration debounce = Duration(milliseconds: 40);

  CustomerPickerCubit build() =>
      CustomerPickerCubit(searchCustomersUseCase: search, debounce: debounce);

  void stubResult(List<CustomerEntity> customers) {
    when(
      () => search(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
      ),
    ).thenAnswer((_) async => Right<Failure, List<CustomerEntity>>(customers));
  }

  setUp(() {
    search = MockSearchCustomersUseCase();
  });

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'loads the first page for the operating company',
    setUp: () => stubResult(<CustomerEntity>[mms021]),
    build: build,
    act: (CustomerPickerCubit cubit) => cubit.load('mm'),
    expect: () => <CustomerPickerState>[
      const CustomerPickerLoading(),
      const CustomerPickerLoaded(customers: <CustomerEntity>[mms021]),
    ],
    verify: (_) =>
        verify(() => search(company: 'mm', search: '', top: 50)).called(1),
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'debounces typing into a single request',
    setUp: () => stubResult(<CustomerEntity>[mms021]),
    build: build,
    act: (CustomerPickerCubit cubit) async {
      await cubit.load('mm');
      cubit
        ..search('M')
        ..search('MM')
        ..search('MMS');
      await Future<void>.delayed(debounce * 4);
    },
    verify: (_) {
      verify(() => search(company: 'mm', search: '', top: 50)).called(1);
      verify(() => search(company: 'mm', search: 'MMS', top: 50)).called(1);
      verifyNoMoreInteractions(search);
    },
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'emits the failure state when the search cannot run',
    setUp: () {
      when(
        () => search(
          company: any(named: 'company'),
          search: any(named: 'search'),
          top: any(named: 'top'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<CustomerEntity>>(
          ServerFailure('FORBIDDEN_COMPANY: not allowed'),
        ),
      );
    },
    build: build,
    act: (CustomerPickerCubit cubit) => cubit.load('logic-trial'),
    expect: () => <Matcher>[
      isA<CustomerPickerLoading>(),
      isA<CustomerPickerFailure>(),
    ],
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'an empty result keeps the loaded state for the empty view',
    setUp: () => stubResult(<CustomerEntity>[]),
    build: build,
    act: (CustomerPickerCubit cubit) => cubit.load('mm'),
    expect: () => <CustomerPickerState>[
      const CustomerPickerLoading(),
      const CustomerPickerLoaded(customers: <CustomerEntity>[]),
    ],
  );
}
