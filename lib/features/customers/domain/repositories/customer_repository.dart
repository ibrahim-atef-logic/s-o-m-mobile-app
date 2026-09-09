import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer_page_result.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerPageResult>> searchCustomers({
    required String company,
    String? search,
    int top,
    int skip,
  });
}
