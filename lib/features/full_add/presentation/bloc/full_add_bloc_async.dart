part of 'full_add_bloc.dart';

extension _FullAddBlocAsync on FullAddBloc {
  Future<void> _onLookup(
    FullAddLookupRequested event,
    Emitter<FullAddState> emit,
  ) async {
    if (state.barcode.trim().isEmpty) {
      emit(state.copyWith(validation: FullAddValidation.barcodeRequired));
      return;
    }
    emit(
      state.copyWith(
        lookingUp: true,
        clearError: true,
        validation: FullAddValidation.none,
        clearItem: true,
        clearPrice: true,
        clearOnHand: true,
      ),
    );
    final Either<Failure, BarcodeItemEntity> lookup = await _actions.lookup(
      barcode: state.barcode,
      company: state.order.dataArea,
    );
    await lookup.fold(
      (Failure f) async => emit(state.copyWith(lookingUp: false, failure: f)),
      (BarcodeItemEntity item) async {
        emit(state.copyWith(lookingUp: false, item: item, quantityText: '1'));
        await _resolvePrice(emit);
        await _fetchOnHand(emit);
      },
    );
  }

  Future<void> _resolvePrice(Emitter<FullAddState> emit) async {
    final BarcodeItemEntity? item = state.item;
    if (item == null) return;
    final Either<Failure, PriceInfoEntity> result = await _actions.resolvePrice(
      item: item,
      order: state.order,
    );
    result.fold(
      (Failure _) => emit(
        state.copyWith(clearPrice: true, validation: FullAddValidation.noPrice),
      ),
      (PriceInfoEntity price) => emit(
        state.copyWith(price: price, validation: FullAddValidation.none),
      ),
    );
  }

  Future<void> _fetchOnHand(Emitter<FullAddState> emit) async {
    final BarcodeItemEntity? item = state.item;
    if (item == null) return;
    emit(state.copyWith(fetchingQty: true, clearError: true));
    final Either<Failure, WarehouseOnHandEntity> result = await _actions
        .getOnHand(item: item, order: state.order);
    result.fold(
      (Failure _) => emit(
        state.copyWith(
          fetchingQty: false,
          clearOnHand: true,
          validation: FullAddValidation.noStock,
        ),
      ),
      (WarehouseOnHandEntity onHand) => emit(
        state.copyWith(
          fetchingQty: false,
          onHand: onHand,
          validation: FullAddValidation.none,
        ),
      ),
    );
  }

  Future<void> _onGetQty(
    FullAddGetQtyRequested event,
    Emitter<FullAddState> emit,
  ) async {
    // Kept for compatibility; UI no longer exposes Get Quantity.
    await _fetchOnHand(emit);
  }

  Future<void> _onSubmit(
    FullAddSubmitRequested event,
    Emitter<FullAddState> emit,
  ) async {
    final FullAddValidation? invalid = _validateBeforeSubmit();
    if (invalid != null) {
      emit(state.copyWith(validation: invalid));
      return;
    }
    final BarcodeItemEntity item = state.item!;
    final int qty = int.parse(state.quantityText.trim());
    emit(state.copyWith(submitting: true, clearError: true));
    final Either<Failure, LineSubmitResultEntity> result = await _actions
        .submit(order: state.order, itemNumber: item.itemNumber, quantity: qty);
    result.fold(
      (Failure f) => emit(state.copyWith(submitting: false, failure: f)),
      (LineSubmitResultEntity submit) =>
          _emitSubmitResult(emit, item, qty, submit),
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
    final List<FullCartItemEntity> next =
        List<FullCartItemEntity>.from(state.cart)..add(
          _actions.toCartItem(
            item: item,
            qty: qty,
            submit: submit,
            price: state.price,
          ),
        );
    emit(FullAddState(order: state.order, cart: next, submitSucceeded: true));
  }

  FullAddValidation? _validateBeforeSubmit() {
    if (state.item == null) return FullAddValidation.lookupRequired;
    if (state.price == null) return FullAddValidation.noPrice;
    if (state.onHand == null) return FullAddValidation.noStock;
    final String? qtyError = FullAddQtyRules.validate(
      quantityText: state.quantityText,
      availableSalesQuantity: state.onHand!.availableSalesQuantity,
    );
    if (qtyError == 'qtyInvalid') return FullAddValidation.qtyInvalid;
    if (qtyError == 'qtyExceeds') return FullAddValidation.qtyExceeds;
    return null;
  }
}
