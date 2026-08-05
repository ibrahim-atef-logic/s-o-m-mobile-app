import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../../../catalog/domain/usecases/submit_quick_batch_usecase.dart';
import '../../../sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../domain/entities/quick_cart_line_entity.dart';

part 'quick_add_event.dart';
part 'quick_add_state.dart';

/// Quick-add: local barcode+qty lines (max 10), then batch submit.
class QuickAddBloc extends Bloc<QuickAddEvent, QuickAddState> {
  QuickAddBloc({
    required SalesOrderHeaderEntity order,
    required SubmitQuickBatchUseCase submitQuickBatchUseCase,
  }) : _submitQuickBatchUseCase = submitQuickBatchUseCase,
       super(QuickAddState(order: order)) {
    on<QuickAddBarcodeChanged>(_onBarcodeChanged);
    on<QuickAddQuantityChanged>(_onQuantityChanged);
    on<QuickAddLineAdded>(_onLineAdded);
    on<QuickAddLineRemoved>(_onLineRemoved);
    on<QuickAddSubmitRequested>(_onSubmit);
    on<QuickAddScanReset>(_onScanReset);
    on<QuickAddMessageCleared>(_onMessageCleared);
  }

  final SubmitQuickBatchUseCase _submitQuickBatchUseCase;

  void _onBarcodeChanged(
    QuickAddBarcodeChanged event,
    Emitter<QuickAddState> emit,
  ) {
    emit(
      state.copyWith(
        barcode: event.barcode,
        validation: QuickAddValidation.none,
        clearError: true,
      ),
    );
  }

  void _onQuantityChanged(
    QuickAddQuantityChanged event,
    Emitter<QuickAddState> emit,
  ) {
    emit(
      state.copyWith(
        quantityText: event.quantity,
        validation: QuickAddValidation.none,
        clearError: true,
      ),
    );
  }

  void _onLineAdded(QuickAddLineAdded event, Emitter<QuickAddState> emit) {
    final String barcode = state.barcode.trim();
    if (barcode.isEmpty) {
      emit(state.copyWith(validation: QuickAddValidation.barcodeRequired));
      return;
    }
    final int? qty = int.tryParse(state.quantityText.trim());
    if (qty == null || qty < 1) {
      emit(state.copyWith(validation: QuickAddValidation.qtyInvalid));
      return;
    }
    if (state.lines.length >= SubmitQuickBatchUseCase.kMaxLines) {
      emit(state.copyWith(validation: QuickAddValidation.maxLines));
      return;
    }
    final List<QuickCartLineEntity> next = List<QuickCartLineEntity>.from(
      state.lines,
    )..add(QuickCartLineEntity(barcode: barcode, quantity: qty));
    emit(
      state.copyWith(
        lines: next,
        barcode: '',
        quantityText: '',
        validation: QuickAddValidation.none,
        lineAdded: true,
      ),
    );
  }

  void _onLineRemoved(QuickAddLineRemoved event, Emitter<QuickAddState> emit) {
    final List<QuickCartLineEntity> next = List<QuickCartLineEntity>.from(
      state.lines,
    )..removeAt(event.index);
    emit(state.copyWith(lines: next));
  }

  Future<void> _onSubmit(
    QuickAddSubmitRequested event,
    Emitter<QuickAddState> emit,
  ) async {
    if (state.lines.isEmpty) {
      emit(state.copyWith(validation: QuickAddValidation.emptyCart));
      return;
    }
    emit(state.copyWith(submitting: true, clearError: true));
    final Either<Failure, LineSubmitResultEntity> result =
        await _submitQuickBatchUseCase(
          salesId: state.order.salesId,
          company: state.order.dataArea,
          lines: state.lines
              .map(
                (QuickCartLineEntity l) =>
                    (barcode: l.barcode, quantity: l.quantity),
              )
              .toList(),
        );
    result.fold(
      (Failure f) => emit(state.copyWith(submitting: false, failure: f)),
      (LineSubmitResultEntity submit) => emit(
        state.copyWith(
          submitting: false,
          lastResult: submit,
          lines: submit.success ? const <QuickCartLineEntity>[] : state.lines,
        ),
      ),
    );
  }

  void _onScanReset(QuickAddScanReset event, Emitter<QuickAddState> emit) {
    emit(
      state.copyWith(
        barcode: '',
        quantityText: '',
        validation: QuickAddValidation.none,
        clearError: true,
        lineAdded: false,
      ),
    );
  }

  void _onMessageCleared(
    QuickAddMessageCleared event,
    Emitter<QuickAddState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        clearResult: true,
        validation: QuickAddValidation.none,
        lineAdded: false,
      ),
    );
  }
}
