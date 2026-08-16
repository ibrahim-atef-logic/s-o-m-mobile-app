import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';
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

  setUp(() {
    repository = MockCustomerRepository();
    sut = SearchCustomersUseCase(repository);
  });

  test('passes the trimmed DataArea and search term through', () async {
    when(
      () => repository.searchCustomers(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
      ),
    ).thenAnswer(
      (_) async => const Right<Failure, List<CustomerEntity>>(<CustomerEntity>[
        customer,
      ]),
    );

    final Either<Failure, List<CustomerEntity>> result = await sut(
      company: ' mm ',
      search: 'MMS',
    );

    expect(result.toNullable(), <CustomerEntity>[customer]);
    verify(
      () => repository.searchCustomers(company: 'mm', search: 'MMS', top: 50),
    ).called(1);
  });

  test('rejects an empty company before hitting the API', () async {
    final Either<Failure, List<CustomerEntity>> result = await sut(
      company: '  ',
    );

    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    expect(result.getLeft().toNullable()?.message, 'COMPANY_REQUIRED');
    verifyNever(
      () => repository.searchCustomers(
        company: any(named: 'company'),
        search: any(named: 'search'),
        top: any(named: 'top'),
      ),
    );
  });
}
