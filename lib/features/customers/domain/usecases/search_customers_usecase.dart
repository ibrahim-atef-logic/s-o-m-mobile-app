import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer_page_result.dart';
import '../repositories/customer_repository.dart';

/// Searches customers of the operating DataArea (account, prefix, name, phone, city).
class SearchCustomersUseCase {
  const SearchCustomersUseCase(this._repository);

  static const int defaultTop = 30;

  final CustomerRepository _repository;

  Future<Either<Failure, CustomerPageResult>> call({
    required String company,
    String? search,
    int top = defaultTop,
    int skip = 0,
  }) {
    final String dataArea = company.trim();
    if (dataArea.isEmpty) {
      return Future<Either<Failure, CustomerPageResult>>.value(
        const Left<Failure, CustomerPageResult>(
          ValidationFailure('COMPANY_REQUIRED'),
        ),
      );
    }
    return _repository.searchCustomers(
      company: dataArea,
      search: search,
      top: top,
      skip: skip,
    );
  }
}
