import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/created_order_entity.dart';
import '../repositories/sales_orders_repository.dart';

/// Creates an empty sales order header for the session's company/warehouse.
///
/// `company` must be the D365 DataArea (e.g. `mm`), never the login registry
/// key. The backend resolves the sales taker from the JWT.
class CreateSalesOrderUseCase {
  const CreateSalesOrderUseCase(this._repository);

  final SalesOrdersRepository _repository;

  Future<Either<Failure, CreatedOrderEntity>> call({
    required String company,
    required String custAccount,
    String? inventLocationId,
    String? inventSiteId,
    String? currencyCode,
  }) {
    final String dataArea = company.trim();
    final String customer = custAccount.trim();
    if (dataArea.isEmpty) {
      return _reject('COMPANY_REQUIRED');
    }
    if (customer.isEmpty) {
      return _reject('CUSTOMER_REQUIRED');
    }
    return _repository.createOrder(
      company: dataArea,
      custAccount: customer,
      inventLocationId: inventLocationId,
      inventSiteId: inventSiteId,
      currencyCode: currencyCode,
    );
  }

  Future<Either<Failure, CreatedOrderEntity>> _reject(String code) {
    return Future<Either<Failure, CreatedOrderEntity>>.value(
      Left<Failure, CreatedOrderEntity>(ValidationFailure(code)),
    );
  }
}
