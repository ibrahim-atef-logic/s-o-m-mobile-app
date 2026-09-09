import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/api_error_code.dart';
import '../../../../core/error/failures.dart';
import '../../../sales_orders/domain/entities/sales_order_line_entity.dart';
import '../../../sales_orders/domain/usecases/delete_sales_order_line_usecase.dart';
import '../../../sales_orders/domain/usecases/get_sales_order_lines_usecase.dart';
import '../../domain/so_lines_math.dart';

/// Loads Dynamics lines for one sales order and deletes by RecId.
class SoLinesCubit extends Cubit<SoLinesState> {
  SoLinesCubit({
    required GetSalesOrderLinesUseCase getSalesOrderLinesUseCase,
    required DeleteSalesOrderLineUseCase deleteSalesOrderLineUseCase,
  }) : _getSalesOrderLinesUseCase = getSalesOrderLinesUseCase,
       _deleteSalesOrderLineUseCase = deleteSalesOrderLineUseCase,
       super(const SoLinesInitial());

  final GetSalesOrderLinesUseCase _getSalesOrderLinesUseCase;
  final DeleteSalesOrderLineUseCase _deleteSalesOrderLineUseCase;

  Future<void> load({required String salesId, required String company}) async {
    emit(const SoLinesLoading());
    final Either<Failure, List<SalesOrderLineEntity>> result =
        await _getSalesOrderLinesUseCase(salesId: salesId, company: company);
    result.fold(
      (Failure f) => emit(SoLinesFailure(f)),
      (List<SalesOrderLineEntity> lines) =>
          emit(SoLinesLoaded(SoLinesMath.sortedByLineNum(lines))),
    );
  }

  Future<void> deleteLine({
    required String salesId,
    required String company,
    required int recordId,
  }) async {
    final SoLinesState current = state;
    if (current is! SoLinesLoaded) {
      return;
    }
    final Either<Failure, void> result = await _deleteSalesOrderLineUseCase(
      salesId: salesId,
      company: company,
      recordId: recordId,
    );
    result.fold((Failure f) {
      if (f.isLineNotFound) {
        emit(SoLinesLoaded(_without(current.lines, recordId)));
        return;
      }
      emit(SoLinesLoaded(current.lines, actionFailure: f));
    }, (_) => emit(SoLinesLoaded(_without(current.lines, recordId))));
  }

  void clearActionFailure() {
    final SoLinesState current = state;
    if (current is SoLinesLoaded && current.actionFailure != null) {
      emit(SoLinesLoaded(current.lines));
    }
  }

  List<SalesOrderLineEntity> _without(
    List<SalesOrderLineEntity> lines,
    int recordId,
  ) {
    return lines
        .where((SalesOrderLineEntity line) => line.recordId != recordId)
        .toList();
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
  const SoLinesLoaded(this.lines, {this.actionFailure});

  final List<SalesOrderLineEntity> lines;
  final Failure? actionFailure;

  @override
  List<Object?> get props => <Object?>[lines, actionFailure];
}

final class SoLinesFailure extends SoLinesState {
  const SoLinesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
