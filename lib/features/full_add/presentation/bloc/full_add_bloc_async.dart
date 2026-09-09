part of 'full_add_bloc.dart';

extension _FullAddBlocAsync on FullAddBloc {
  Future<void> _onLookup(
    FullAddLookupRequested event,
    Emitter<FullAddState> emit,
  ) async {
    if (ScanCode.isBlank(state.barcode)) {
      emit(state.copyWith(validation: FullAddValidation.barcodeRequired));
      return;
    }
    emit(
      state.copyWith(
        lookingUp: true,
        fetchingPrice: false,
        clearError: true,
        validation: FullAddValidation.none,
        clearItem: true,
        clearPrice: true,
        clearOnHand: true,
      ),
    );
    final bool byItem = event.byItem ?? state.lookupByItem;
    final Either<Failure, BarcodeItemEntity> lookup = await _actions.lookup(
      barcode: state.barcode,
      company: state.order.dataArea,
      byItem: byItem,
    );
    await lookup.fold(
      (Failure f) async => emit(
        state.copyWith(lookingUp: false, fetchingPrice: false, failure: f),
      ),
      (BarcodeItemEntity item) async {
        emit(
          state.copyWith(
            lookingUp: false,
            item: item,
            quantityText: '',
            fetchingQty: true,
            clearPrice: true,
          ),
        );
        await _fetchOnHandOnly(emit);
      },
    );
  }

  /// Inventory only — never calls item-price until qty Enter / Add.
  Future<void> _fetchOnHandOnly(Emitter<FullAddState> emit) async {
    final BarcodeItemEntity? item = state.item;
    if (item == null) {
      return;
    }
    final Either<Failure, WarehouseOnHandEntity> stock = await _actions
        .getOnHand(item: item, order: state.order);
    stock.fold(
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

  Future<void> _resolvePrice(Emitter<FullAddState> emit) async {
    final BarcodeItemEntity? item = state.item;
    if (item == null) {
      return;
    }
    emit(state.copyWith(fetchingPrice: true, clearError: true));
    final Either<Failure, PriceInfoEntity> result = await _actions.resolvePrice(
      item: item,
      order: state.order,
      inventoryUnit: state.onHand?.unit,
    );
    result.fold(
      (Failure f) => emit(
        state.copyWith(
          fetchingPrice: false,
          clearPrice: true,
          validation: (f.isNoPrice || f.isItemNotFound)
              ? FullAddValidation.noPrice
              : state.validation,
          failure: (f.isNoPrice || f.isItemNotFound) ? null : f,
        ),
      ),
      (PriceInfoEntity price) => emit(
        state.copyWith(
          fetchingPrice: false,
          price: price,
          validation: state.onHand == null
              ? FullAddValidation.noStock
              : FullAddValidation.none,
        ),
      ),
    );
  }

  Future<void> _fetchOnHand(Emitter<FullAddState> emit) async {
    final BarcodeItemEntity? item = state.item;
    if (item == null) {
      return;
    }
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
    await _fetchOnHand(emit);
  }
}
