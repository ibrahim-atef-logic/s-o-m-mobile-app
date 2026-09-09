import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_page_result.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_page_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._remote);

  final CustomerRemoteDataSource _remote;

  @override
  Future<Either<Failure, CustomerPageResult>> searchCustomers({
    required String company,
    String? search,
    int top = CustomerRemoteDataSourceImpl.defaultTop,
    int skip = 0,
  }) async {
    try {
      final CustomerPageModel page = await _remote.searchCustomers(
        company: company,
        search: search,
        top: top,
        skip: skip,
      );
      return Right<Failure, CustomerPageResult>(page.toEntity());
    } on AuthException catch (e) {
      return Left<Failure, CustomerPageResult>(AuthFailure(e.message));
    } on NetworkException {
      return const Left<Failure, CustomerPageResult>(NetworkFailure());
    } on ServerException catch (e) {
      return Left<Failure, CustomerPageResult>(ServerFailure(e.message));
    }
  }
}
