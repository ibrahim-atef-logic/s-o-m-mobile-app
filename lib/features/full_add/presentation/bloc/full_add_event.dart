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
  const FullAddLookupRequested();
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

final class FullAddScanReset extends FullAddEvent {
  const FullAddScanReset();
}

final class FullAddMessageCleared extends FullAddEvent {
  const FullAddMessageCleared();
}
