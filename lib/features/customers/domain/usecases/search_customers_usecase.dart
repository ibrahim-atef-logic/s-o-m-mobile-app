import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Searches customers of the operating DataArea by account number or name.
class SearchCustomersUseCase {
  const SearchCustomersUseCase(this._repository);

  static const int defaultTop = 50;

  final CustomerRepository _repository;

  Future<Either<Failure, List<CustomerEntity>>> call({
    required String company,
    String? search,
    int top = defaultTop,
  }) {
    final String dataArea = company.trim();
    if (dataArea.isEmpty) {
      return Future<Either<Failure, List<CustomerEntity>>>.value(
        const Left<Failure, List<CustomerEntity>>(
          ValidationFailure('COMPANY_REQUIRED'),
        ),
      );
    }
    return _repository.searchCustomers(
      company: dataArea,
      search: search,
      top: top,
    );
  }
}
