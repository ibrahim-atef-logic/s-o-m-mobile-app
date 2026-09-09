import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_page_result.dart';
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

  CustomerPageResult pageOf(
    List<CustomerEntity> items, {
    bool hasMore = false,
    int skip = 0,
    int top = 30,
    int? totalCount,
  }) {
    return CustomerPageResult(
      items: items,
      top: top,
      skip: skip,
      count: items.length,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }

  void stubResult(CustomerPageResult page) {
    when(
      () => search(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => Right<Failure, CustomerPageResult>(page));
  }

  setUp(() {
    search = MockSearchCustomersUseCase();
  });

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'loads the first page for the operating company',
    setUp: () => stubResult(pageOf(<CustomerEntity>[mms021])),
    build: build,
    act: (CustomerPickerCubit cubit) => cubit.load('mm'),
    expect: () => <CustomerPickerState>[
      const CustomerPickerLoading(),
      CustomerPickerLoaded(
        customers: const <CustomerEntity>[mms021],
        hasMore: false,
        skip: 0,
        top: 30,
      ),
    ],
    verify: (_) => verify(
      () => search(company: 'mm', search: '', top: 30, skip: 0),
    ).called(1),
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'debounces typing into a single request',
    setUp: () => stubResult(pageOf(<CustomerEntity>[mms021])),
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
      verify(
        () => search(company: 'mm', search: '', top: 30, skip: 0),
      ).called(1);
      verify(
        () => search(company: 'mm', search: 'MMS', top: 30, skip: 0),
      ).called(1);
      verifyNoMoreInteractions(search);
    },
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'appends the next page on loadMore',
    setUp: () {
      var calls = 0;
      when(
        () => search(
          company: any(named: 'company'),
          search: any(named: 'search'),
          top: any(named: 'top'),
          skip: any(named: 'skip'),
        ),
      ).thenAnswer((_) async {
        calls += 1;
        if (calls == 1) {
          return Right<Failure, CustomerPageResult>(
            pageOf(<CustomerEntity>[mms021], hasMore: true, skip: 0),
          );
        }
        return Right<Failure, CustomerPageResult>(
          pageOf(
            const <CustomerEntity>[
              CustomerEntity(
                dataAreaId: 'mm',
                customerAccount: '20-10002',
                name: 'شركة',
              ),
            ],
            skip: 30,
          ),
        );
      });
    },
    build: build,
    act: (CustomerPickerCubit cubit) async {
      await cubit.load('mm');
      await cubit.loadMore();
    },
    verify: (_) {
      verify(
        () => search(company: 'mm', search: '', top: 30, skip: 0),
      ).called(1);
      verify(
        () => search(company: 'mm', search: '', top: 30, skip: 30),
      ).called(1);
    },
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'paginates search results and exposes totalCount',
    setUp: () {
      var calls = 0;
      when(
        () => search(
          company: any(named: 'company'),
          search: any(named: 'search'),
          top: any(named: 'top'),
          skip: any(named: 'skip'),
        ),
      ).thenAnswer((Invocation inv) async {
        calls += 1;
        final String? term = inv.namedArguments[#search] as String?;
        final int skip = inv.namedArguments[#skip] as int? ?? 0;
        if (term == null || term.isEmpty) {
          return Right<Failure, CustomerPageResult>(
            pageOf(const <CustomerEntity>[mms021]),
          );
        }
        if (skip == 0) {
          return Right<Failure, CustomerPageResult>(
            pageOf(
              const <CustomerEntity>[mms021],
              hasMore: true,
              totalCount: 2,
            ),
          );
        }
        return Right<Failure, CustomerPageResult>(
          pageOf(
            const <CustomerEntity>[
              CustomerEntity(
                dataAreaId: 'mm',
                customerAccount: '20-10002',
                name: 'شركة الشرقية الدولية',
              ),
            ],
            skip: 30,
            totalCount: 2,
          ),
        );
      });
    },
    build: build,
    act: (CustomerPickerCubit cubit) async {
      await cubit.load('mm');
      cubit.search('الشرقية');
      await Future<void>.delayed(debounce * 4);
      await cubit.loadMore();
    },
    verify: (_) {
      verify(
        () => search(company: 'mm', search: 'الشرقية', top: 30, skip: 0),
      ).called(1);
      verify(
        () => search(company: 'mm', search: 'الشرقية', top: 30, skip: 30),
      ).called(1);
    },
    expect: () => <Matcher>[
      isA<CustomerPickerLoading>(),
      isA<CustomerPickerLoaded>(),
      isA<CustomerPickerLoaded>(),
      predicate<CustomerPickerLoaded>(
        (CustomerPickerLoaded state) =>
            state.query == 'الشرقية' &&
            state.totalCount == 2 &&
            state.customers.length == 1 &&
            state.hasMore,
      ),
      isA<CustomerPickerLoaded>(),
      predicate<CustomerPickerLoaded>(
        (CustomerPickerLoaded state) =>
            state.customers.length == 2 &&
            state.totalCount == 2,
      ),
    ],
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'merges local browse-cache hits when the server returns empty',
    setUp: () {
      when(
        () => search(
          company: any(named: 'company'),
          search: any(named: 'search'),
          top: any(named: 'top'),
          skip: any(named: 'skip'),
        ),
      ).thenAnswer((Invocation inv) async {
        final String? term = inv.namedArguments[#search] as String?;
        if (term == null || term.isEmpty) {
          return Right<Failure, CustomerPageResult>(
            pageOf(
              const <CustomerEntity>[
                CustomerEntity(
                  dataAreaId: 'mm',
                  customerAccount: '20-10002',
                  name: 'شركة الشرقية الدولية',
                ),
              ],
            ),
          );
        }
        return Right<Failure, CustomerPageResult>(
          pageOf(const <CustomerEntity>[]),
        );
      });
    },
    build: build,
    act: (CustomerPickerCubit cubit) async {
      await cubit.load('mm');
      cubit.search('الشرقية');
      await Future<void>.delayed(debounce * 4);
    },
    expect: () => <Matcher>[
      isA<CustomerPickerLoading>(),
      isA<CustomerPickerLoaded>(),
      isA<CustomerPickerLoaded>(),
      predicate<CustomerPickerLoaded>(
        (CustomerPickerLoaded state) =>
            state.query == 'الشرقية' &&
            state.customers.length == 1 &&
            state.customers.first.customerAccount == '20-10002',
      ),
    ],
  );

  blocTest<CustomerPickerCubit, CustomerPickerState>(
    'emits the failure state when the search cannot run',
    setUp: () {
      when(
        () => search(
          company: any(named: 'company'),
          search: any(named: 'search'),
          top: any(named: 'top'),
          skip: any(named: 'skip'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, CustomerPageResult>(
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
    setUp: () => stubResult(pageOf(<CustomerEntity>[])),
    build: build,
    act: (CustomerPickerCubit cubit) => cubit.load('mm'),
    expect: () => <CustomerPickerState>[
      const CustomerPickerLoading(),
      const CustomerPickerLoaded(customers: <CustomerEntity>[]),
    ],
  );
}
