import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../sales_orders/domain/entities/sales_order_line_entity.dart';
import '../../../sales_orders/domain/usecases/get_sales_order_lines_usecase.dart';

/// Loads Dynamics lines for one sales order.
class SoLinesCubit extends Cubit<SoLinesState> {
  SoLinesCubit({required GetSalesOrderLinesUseCase getSalesOrderLinesUseCase})
    : _getSalesOrderLinesUseCase = getSalesOrderLinesUseCase,
      super(const SoLinesInitial());

  final GetSalesOrderLinesUseCase _getSalesOrderLinesUseCase;

  Future<void> load({required String salesId, required String company}) async {
    emit(const SoLinesLoading());
    final Either<Failure, List<SalesOrderLineEntity>> result =
        await _getSalesOrderLinesUseCase(salesId: salesId, company: company);
    result.fold(
      (Failure f) => emit(SoLinesFailure(f)),
      (List<SalesOrderLineEntity> lines) => emit(SoLinesLoaded(lines)),
    );
  }
}

sealed class SoLinesState extends Equatable {
  const SoLinesState();

  @override
  List<Object?> get props => <Object?>[];
}

final class SoLinesInitial extends SoLinesState {
  const SoLinesInitial();
}

final class SoLinesLoading extends SoLinesState {
  const SoLinesLoading();
}

final class SoLinesLoaded extends SoLinesState {
  const SoLinesLoaded(this.lines);

  final List<SalesOrderLineEntity> lines;

  @override
  List<Object?> get props => <Object?>[lines];
}

final class SoLinesFailure extends SoLinesState {
  const SoLinesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
