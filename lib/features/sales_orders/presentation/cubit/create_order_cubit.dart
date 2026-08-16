import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/api_error_code.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_session_entity.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/domain/usecases/search_customers_usecase.dart';
import '../../domain/entities/created_order_entity.dart';
import '../../domain/entities/sales_order_header_entity.dart';
import '../../domain/usecases/create_sales_order_usecase.dart';
import '../../domain/usecases/get_sales_order_usecase.dart';

part 'create_order_state.dart';

/// Drives the create-sales-order screen: company, warehouse, customer, submit.
class CreateOrderCubit extends Cubit<CreateOrderState> {
  CreateOrderCubit({
    required CreateSalesOrderUseCase createSalesOrderUseCase,
    required GetSalesOrderUseCase getSalesOrderUseCase,
    required SearchCustomersUseCase searchCustomersUseCase,
  }) : _createSalesOrderUseCase = createSalesOrderUseCase,
       _getSalesOrderUseCase = getSalesOrderUseCase,
       _searchCustomersUseCase = searchCustomersUseCase,
       super(const CreateOrderState());

  final CreateSalesOrderUseCase _createSalesOrderUseCase;
  final GetSalesOrderUseCase _getSalesOrderUseCase;
  final SearchCustomersUseCase _searchCustomersUseCase;

  /// Seeds the form from the in-memory session and preselects its customer.
  Future<void> start(UserSessionEntity session) async {
    final String company = session.orderDataArea;
    final String account = session.defaultCustAccount?.trim() ?? '';
    emit(
      CreateOrderState(
        company: company,
        warehouse: session.resolvedWarehouse,
        currency: session.currency,
        customer: account.isEmpty
            ? null
            : CustomerEntity(
                dataAreaId: company,
                customerAccount: account,
                name: '',
              ),
        resolvingCustomer: account.isNotEmpty,
      ),
    );
    if (account.isEmpty) {
      return;
    }
    await _resolveDefaultCustomer(company: company, account: account);
  }

  void selectCustomer(CustomerEntity customer) {
    emit(state.copyWith(customer: customer, resolvingCustomer: false));
  }

  Future<void> submit() async {
    if (state.submitting) {
      return;
    }
    final CustomerEntity? customer = state.customer;
    if (customer == null || customer.customerAccount.trim().isEmpty) {
      emit(state.copyWith(customerError: 'CUSTOMER_REQUIRED'));
      return;
    }
    emit(state.copyWith(submitting: true));
    final Either<Failure, CreatedOrderEntity> result =
        await _createSalesOrderUseCase(
          company: state.company,
          custAccount: customer.customerAccount,
          inventLocationId: state.warehouse,
          currencyCode: state.currency,
        );
    if (isClosed) {
      return;
    }
    await result.fold(_onCreateFailed, (CreatedOrderEntity created) {
      return _onCreated(created, customer);
    });
  }

  Future<void> _onCreateFailed(Failure failure) async {
    if (failure.isWarehouseRequired) {
      emit(state.copyWith(submitting: false, warehouseRequired: true));
      return;
    }
    if (failure.isValidationCode || failure is ValidationFailure) {
      emit(state.copyWith(submitting: false, customerError: failure.message));
      return;
    }
    emit(state.copyWith(submitting: false, failure: failure));
  }

  /// Re-reads the header so price group and status come from D365, not guesses.
  Future<void> _onCreated(
    CreatedOrderEntity created,
    CustomerEntity customer,
  ) async {
    final Either<Failure, SalesOrderHeaderEntity> header =
        await _getSalesOrderUseCase(
          salesId: created.salesOrderNumber,
          company: created.dataAreaId.isEmpty
              ? state.company
              : created.dataAreaId,
        );
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        submitting: false,
        createdOrder: header.getOrElse(
          (_) => created.toHeader(salesName: customer.displayName),
        ),
      ),
    );
  }

  Future<void> _resolveDefaultCustomer({
    required String company,
    required String account,
  }) async {
    final Either<Failure, List<CustomerEntity>> result =
        await _searchCustomersUseCase(
          company: company,
          search: account,
          top: 10,
        );
    if (isClosed) {
      return;
    }
    final List<CustomerEntity> matches = result
        .getOrElse((_) => const <CustomerEntity>[])
        .where((CustomerEntity c) => c.customerAccount == account)
        .toList();
    emit(
      state.copyWith(
        customer: matches.isEmpty ? null : matches.first,
        resolvingCustomer: false,
      ),
    );
  }
}
