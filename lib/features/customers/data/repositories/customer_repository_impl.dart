import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._remote);

  final CustomerRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CustomerEntity>>> searchCustomers({
    required String company,
    String? search,
    int top = 50,
  }) async {
    try {
      final List<CustomerModel> models = await _remote.searchCustomers(
        company: company,
        search: search,
        top: top,
      );
      return Right<Failure, List<CustomerEntity>>(<CustomerEntity>[
        for (final CustomerModel model in models)
          if (model.customerAccount.isNotEmpty) model.toEntity(),
      ]);
    } on AuthException catch (e) {
      return Left<Failure, List<CustomerEntity>>(AuthFailure(e.message));
    } on NetworkException {
      return const Left<Failure, List<CustomerEntity>>(NetworkFailure());
    } on ServerException catch (e) {
      return Left<Failure, List<CustomerEntity>>(ServerFailure(e.message));
    }
  }
}
