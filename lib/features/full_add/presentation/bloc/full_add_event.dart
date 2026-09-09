part of 'full_add_bloc.dart';

sealed class FullAddEvent extends Equatable {
  const FullAddEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FullAddBarcodeChanged extends FullAddEvent {
  const FullAddBarcodeChanged(this.barcode);

  final String barcode;

  @override
  List<Object?> get props => <Object?>[barcode];
}

final class FullAddLookupRequested extends FullAddEvent {
  const FullAddLookupRequested({this.byItem});

  /// When set, overrides [FullAddState.lookupByItem] for this request.
  final bool? byItem;

  @override
  List<Object?> get props => <Object?>[byItem];
}

final class FullAddLookupByItemChanged extends FullAddEvent {
  const FullAddLookupByItemChanged(this.byItem);

  final bool byItem;

  @override
  List<Object?> get props => <Object?>[byItem];
}

final class FullAddGetQtyRequested extends FullAddEvent {
  const FullAddGetQtyRequested();
}

final class FullAddQuantityChanged extends FullAddEvent {
  const FullAddQuantityChanged(this.quantity);

  final String quantity;

  @override
  List<Object?> get props => <Object?>[quantity];
}

final class FullAddSubmitRequested extends FullAddEvent {
  const FullAddSubmitRequested();
}

final class FullAddModeChanged extends FullAddEvent {
  const FullAddModeChanged({required this.autoMode});

  final bool autoMode;

  @override
  List<Object?> get props => <Object?>[autoMode];
}

final class FullAddBatchSubmitRequested extends FullAddEvent {
  const FullAddBatchSubmitRequested();
}

final class FullAddScanReset extends FullAddEvent {
  const FullAddScanReset();
}

final class FullAddMessageCleared extends FullAddEvent {
  const FullAddMessageCleared();
}
