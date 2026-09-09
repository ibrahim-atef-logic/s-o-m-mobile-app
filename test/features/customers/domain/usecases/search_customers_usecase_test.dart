import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_page_result.dart';
import 'package:logic_retail_mobile/features/customers/domain/repositories/customer_repository.dart';
import 'package:logic_retail_mobile/features/customers/domain/usecases/search_customers_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late MockCustomerRepository repository;
  late SearchCustomersUseCase sut;

  const CustomerEntity customer = CustomerEntity(
    dataAreaId: 'mm',
    customerAccount: 'MMS021',
    name: 'عميل نقدي',
  );

  const CustomerPageResult page = CustomerPageResult(
    items: <CustomerEntity>[customer],
    top: 30,
    skip: 0,
    count: 1,
    hasMore: false,
  );

  setUp(() {
    repository = MockCustomerRepository();
    sut = SearchCustomersUseCase(repository);
  });

  test('passes the trimmed DataArea, search, top and skip', () async {
    when(
      () => repository.searchCustomers(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => const Right<Failure, CustomerPageResult>(page));

    final Either<Failure, CustomerPageResult> result = await sut(
      company: ' mm ',
      search: 'MMS',
    );

    expect(result.toNullable()?.items, <CustomerEntity>[customer]);
    verify(
      () => repository.searchCustomers(
        company: 'mm',
        search: 'MMS',
        top: 30,
        skip: 0,
      ),
    ).called(1);
  });

  test('rejects an empty company before hitting the API', () async {
    final Either<Failure, CustomerPageResult> result = await sut(
      company: '  ',
    );

    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    expect(result.getLeft().toNullable()?.message, 'COMPANY_REQUIRED');
    verifyNever(
      () => repository.searchCustomers(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
        skip: any(named: 'skip'),
      ),
    );
  });
}
