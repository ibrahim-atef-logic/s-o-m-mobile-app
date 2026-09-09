import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/api_error_code.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/scan_code.dart';
import '../../../catalog/domain/entities/barcode_item_entity.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../../../catalog/domain/entities/price_info_entity.dart';
import '../../../catalog/domain/entities/warehouse_on_hand_entity.dart';
import '../../../catalog/domain/usecases/get_on_hand_usecase.dart';
import '../../../catalog/domain/usecases/lookup_barcode_usecase.dart';
import '../../../catalog/domain/usecases/lookup_item_usecase.dart';
import '../../../catalog/domain/usecases/resolve_price_usecase.dart';
import '../../../catalog/domain/usecases/submit_full_line_usecase.dart';
import '../../../catalog/domain/usecases/submit_quick_batch_usecase.dart';
import '../../../sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../domain/entities/full_cart_item_entity.dart';
import '../../domain/full_add_qty_rules.dart';
import 'full_add_catalog_actions.dart';

part 'full_add_event.dart';
part 'full_add_state.dart';
part 'full_add_bloc_async.dart';
part 'full_add_bloc_submit.dart';

/// Full-add flow: lookup → price → on-hand → validate qty → Auto/Manual submit.
class FullAddBloc extends Bloc<FullAddEvent, FullAddState> {
  FullAddBloc({
    required SalesOrderHeaderEntity order,
    required LookupBarcodeUseCase lookupBarcodeUseCase,
    required LookupItemUseCase lookupItemUseCase,
    required ResolvePriceUseCase resolvePriceUseCase,
    required GetOnHandUseCase getOnHandUseCase,
    required SubmitFullLineUseCase submitFullLineUseCase,
    required SubmitQuickBatchUseCase submitQuickBatchUseCase,
    String? sessionWarehouse,
    int? sessionChannelRecId,
    String? sessionCurrency,
  }) : _actions = FullAddCatalogActions(
         lookupBarcodeUseCase: lookupBarcodeUseCase,
         lookupItemUseCase: lookupItemUseCase,
         resolvePriceUseCase: resolvePriceUseCase,
         getOnHandUseCase: getOnHandUseCase,
         submitFullLineUseCase: submitFullLineUseCase,
         sessionWarehouse: sessionWarehouse,
         sessionChannelRecId: sessionChannelRecId,
         sessionCurrency: sessionCurrency,
       ),
       _submitQuickBatchUseCase = submitQuickBatchUseCase,
       super(FullAddState(order: order)) {
    on<FullAddBarcodeChanged>(_onBarcodeChanged);
    on<FullAddLookupByItemChanged>(_onLookupByItemChanged);
    on<FullAddLookupRequested>(_onLookup);
    on<FullAddGetQtyRequested>(_onGetQty);
    on<FullAddQuantityChanged>(_onQuantityChanged);
    on<FullAddSubmitRequested>(_onSubmit);
    on<FullAddModeChanged>(_onModeChanged);
    on<FullAddBatchSubmitRequested>(_onBatchSubmit);
    on<FullAddScanReset>(_onScanReset);
    on<FullAddMessageCleared>(_onMessageCleared);
  }

  final FullAddCatalogActions _actions;
  final SubmitQuickBatchUseCase _submitQuickBatchUseCase;

  void _onLookupByItemChanged(
    FullAddLookupByItemChanged event,
    Emitter<FullAddState> emit,
  ) {
    emit(state.copyWith(lookupByItem: event.byItem));
  }

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
        fetchingPrice: false,
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
        clearPrice: true,
        fetchingPrice: false,
        validation: FullAddValidation.none,
        clearError: true,
      ),
    );
  }

  void _onModeChanged(FullAddModeChanged event, Emitter<FullAddState> emit) {
    emit(state.copyWith(autoMode: event.autoMode, clearError: true));
  }

  void _onScanReset(FullAddScanReset event, Emitter<FullAddState> emit) {
    emit(
      FullAddState(
        order: state.order,
        cart: state.cart,
        autoMode: state.autoMode,
        lookupByItem: state.lookupByItem,
      ),
    );
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
        batchSucceeded: false,
      ),
    );
  }
}
