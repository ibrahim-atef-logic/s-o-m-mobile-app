part of 'sales_orders_bloc.dart';

sealed class SalesOrdersState extends Equatable {
  const SalesOrdersState();

  @override
  List<Object?> get props => <Object?>[];
}

final class SalesOrdersInitial extends SalesOrdersState {
  const SalesOrdersInitial();
}

final class SalesOrdersLoading extends SalesOrdersState {
  const SalesOrdersLoading();
}

final class SalesOrdersLoaded extends SalesOrdersState {
  const SalesOrdersLoaded(this.orders);

  final List<SalesOrderHeaderEntity> orders;

  @override
  List<Object?> get props => <Object?>[orders];
}

final class SalesOrdersFailure extends SalesOrdersState {
  const SalesOrdersFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
