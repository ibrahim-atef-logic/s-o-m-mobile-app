import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/sales_order_header_entity.dart';
import '../../domain/usecases/get_my_sales_orders_usecase.dart';

part 'sales_orders_event.dart';
part 'sales_orders_state.dart';

/// Loads open sales orders for the selected company.
class SalesOrdersBloc extends Bloc<SalesOrdersEvent, SalesOrdersState> {
  SalesOrdersBloc({required GetMySalesOrdersUseCase getMySalesOrdersUseCase})
    : _getMySalesOrdersUseCase = getMySalesOrdersUseCase,
      super(const SalesOrdersInitial()) {
    on<SalesOrdersRequested>(_onRequested);
  }

  final GetMySalesOrdersUseCase _getMySalesOrdersUseCase;

  Future<void> _onRequested(
    SalesOrdersRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    emit(const SalesOrdersLoading());
    final Either<Failure, List<SalesOrderHeaderEntity>> result =
        await _getMySalesOrdersUseCase(company: event.company);
    result.fold(
      (Failure f) => emit(SalesOrdersFailure(f)),
      (List<SalesOrderHeaderEntity> orders) => emit(SalesOrdersLoaded(orders)),
    );
  }
}
