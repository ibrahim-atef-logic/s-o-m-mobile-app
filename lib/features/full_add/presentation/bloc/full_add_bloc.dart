import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/barcode_item_entity.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../../../catalog/domain/entities/price_info_entity.dart';
import '../../../catalog/domain/entities/warehouse_on_hand_entity.dart';
import '../../../catalog/domain/usecases/get_on_hand_usecase.dart';
import '../../../catalog/domain/usecases/lookup_barcode_usecase.dart';
import '../../../catalog/domain/usecases/resolve_price_usecase.dart';
import '../../../catalog/domain/usecases/submit_full_line_usecase.dart';
import '../../../sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../domain/entities/full_cart_item_entity.dart';
import '../../domain/full_add_qty_rules.dart';
import 'full_add_catalog_actions.dart';

part 'full_add_event.dart';
part 'full_add_state.dart';
part 'full_add_bloc_async.dart';

/// Full-add flow: lookup → price → on-hand → validate qty → submit.
class FullAddBloc extends Bloc<FullAddEvent, FullAddState> {
  FullAddBloc({
    required SalesOrderHeaderEntity order,
    required LookupBarcodeUseCase lookupBarcodeUseCase,
    required ResolvePriceUseCase resolvePriceUseCase,
    required GetOnHandUseCase getOnHandUseCase,
    required SubmitFullLineUseCase submitFullLineUseCase,
  }) : _actions = FullAddCatalogActions(
         lookupBarcodeUseCase: lookupBarcodeUseCase,
         resolvePriceUseCase: resolvePriceUseCase,
         getOnHandUseCase: getOnHandUseCase,
         submitFullLineUseCase: submitFullLineUseCase,
       ),
       super(FullAddState(order: order)) {
    on<FullAddBarcodeChanged>(_onBarcodeChanged);
    on<FullAddLookupRequested>(_onLookup);
    on<FullAddGetQtyRequested>(_onGetQty);
    on<FullAddQuantityChanged>(_onQuantityChanged);
    on<FullAddSubmitRequested>(_onSubmit);
    on<FullAddScanReset>(_onScanReset);
    on<FullAddMessageCleared>(_onMessageCleared);
  }

  final FullAddCatalogActions _actions;

  void _onBarcodeChanged(
    FullAddBarcodeChanged event,
    Emitter<FullAddState> emit,
  ) {
    emit(
      state.copyWith(
        barcode: event.barcode,
        clearItem: true,
        clearPrice: true,
        clearOnHand: true,
        validation: FullAddValidation.none,
        clearError: true,
        submitSucceeded: false,
      ),
    );
  }

  void _onQuantityChanged(
    FullAddQuantityChanged event,
    Emitter<FullAddState> emit,
  ) {
    emit(
      state.copyWith(
        quantityText: event.quantity,
        validation: FullAddValidation.none,
        clearError: true,
      ),
    );
  }

  void _onScanReset(FullAddScanReset event, Emitter<FullAddState> emit) {
    emit(FullAddState(order: state.order, cart: state.cart));
  }

  void _onMessageCleared(
    FullAddMessageCleared event,
    Emitter<FullAddState> emit,
  ) {
    emit(
      state.copyWith(
        clearError: true,
        validation: FullAddValidation.none,
        submitSucceeded: false,
      ),
    );
  }
}
