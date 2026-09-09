part of 'full_add_bloc.dart';

extension _FullAddBlocSubmit on FullAddBloc {
  Future<void> _onSubmit(
    FullAddSubmitRequested event,
    Emitter<FullAddState> emit,
  ) async {
    final FullAddValidation? invalid = _validateBeforePrice();
    if (invalid != null) {
      emit(state.copyWith(validation: invalid));
      return;
    }
    if (state.price == null) {
      await _resolvePrice(emit);
      if (state.price == null) {
        if (state.failure != null) {
          return;
        }
        emit(state.copyWith(validation: FullAddValidation.noPrice));
        return;
      }
    }
    final FullAddValidation? afterPrice = _validateStockAndQty();
    if (afterPrice != null) {
      emit(state.copyWith(validation: afterPrice));
      return;
    }
    final BarcodeItemEntity item = state.item!;
    final int qty = int.parse(
      ScanCode.stripControls(state.quantityText).trim(),
    );
    emit(state.copyWith(submitting: true, clearError: true));
    final Either<Failure, LineSubmitResultEntity> result = await _actions
        .submit(order: state.order, itemNumber: item.itemNumber, quantity: qty);
    result.fold(
      (Failure f) => emit(state.copyWith(submitting: false, failure: f)),
      (LineSubmitResultEntity submit) =>
          _emitSubmitResult(emit, item, qty, submit),
    );
  }

  Future<void> _onBatchSubmit(
    FullAddBatchSubmitRequested event,
    Emitter<FullAddState> emit,
  ) async {
    final List<FullCartItemEntity> pending = state.cart
        .where((FullCartItemEntity row) => !row.posted)
        .toList();
    if (pending.isEmpty) {
      return;
    }
    if (pending.length > SubmitQuickBatchUseCase.kMaxLines) {
      emit(
        state.copyWith(
          failure: const ValidationFailure('Quick add allows max 10 lines'),
        ),
      );
      return;
    }
    emit(state.copyWith(submitting: true, clearError: true));
    final Either<Failure, LineSubmitResultEntity> result =
        await _submitQuickBatchUseCase(
          salesId: state.order.salesId,
          company: state.order.dataArea,
          lines: pending
              .map(
                (FullCartItemEntity row) =>
                    (barcode: row.barcode, quantity: row.quantity),
              )
              .toList(),
        );
    result.fold(
      (Failure f) => emit(state.copyWith(submitting: false, failure: f)),
      (LineSubmitResultEntity submit) {
        if (!submit.success) {
          emit(
            state.copyWith(
              submitting: false,
              failure: ServerFailure(
                submit.item?.commentEn ??
                    (submit.items.isNotEmpty
                        ? submit.items.first.commentEn ?? ''
                        : ''),
              ),
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            submitting: false,
            cart: <FullCartItemEntity>[
              for (final FullCartItemEntity row in state.cart)
                row.posted ? row : row.copyWith(posted: true),
            ],
            batchSucceeded: true,
          ),
        );
      },
    );
  }

  void _emitSubmitResult(
    Emitter<FullAddState> emit,
    BarcodeItemEntity item,
    int qty,
    LineSubmitResultEntity submit,
  ) {
    if (!submit.success) {
      emit(
        state.copyWith(
          submitting: false,
          failure: ServerFailure(submit.item?.commentEn ?? ''),
        ),
      );
      return;
    }
    final FullCartItemEntity added = _actions.toCartItem(
      item: item,
      qty: qty,
      submit: submit,
      price: state.price,
      inventoryUnit: state.onHand?.unit,
    );
    emit(
      FullAddState(
        order: state.order,
        cart: _mergeCart(state.cart, added),
        autoMode: state.autoMode,
        submitSucceeded: true,
      ),
    );
  }

  List<FullCartItemEntity> _mergeCart(
    List<FullCartItemEntity> cart,
    FullCartItemEntity added,
  ) {
    final List<FullCartItemEntity> next = List<FullCartItemEntity>.from(cart);
    final int index = next.indexWhere(
      (FullCartItemEntity row) =>
          row.itemNumber == added.itemNumber && row.posted == added.posted,
    );
    if (index < 0) {
      next.add(added);
    } else {
      next[index] = next[index].addingQuantity(added);
    }
    return next;
  }

  FullAddValidation? _validateBeforePrice() {
    if (state.item == null) {
      return FullAddValidation.lookupRequired;
    }
    final String qtyText = ScanCode.stripControls(state.quantityText);
    if (qtyText.trim().isEmpty) {
      return FullAddValidation.qtyInvalid;
    }
    final int? qty = int.tryParse(qtyText.trim());
    if (qty == null || qty < 1) {
      return FullAddValidation.qtyInvalid;
    }
    return null;
  }

  FullAddValidation? _validateStockAndQty() {
    if (state.onHand == null) {
      return FullAddValidation.noStock;
    }
    final String? qtyError = FullAddQtyRules.validate(
      quantityText: state.quantityText,
      availableSalesQuantity: state.onHand!.availableSalesQuantity,
    );
    if (qtyError == 'qtyInvalid') {
      return FullAddValidation.qtyInvalid;
    }
    if (qtyError == 'qtyExceeds') {
      return FullAddValidation.qtyExceeds;
    }
    return null;
  }
}
