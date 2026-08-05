part of 'sales_orders_bloc.dart';

sealed class SalesOrdersEvent extends Equatable {
  const SalesOrdersEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class SalesOrdersRequested extends SalesOrdersEvent {
  const SalesOrdersRequested(this.company);

  final String company;

  @override
  List<Object?> get props => <Object?>[company];
}
