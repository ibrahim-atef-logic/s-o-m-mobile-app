part of 'quick_add_bloc.dart';

sealed class QuickAddEvent extends Equatable {
  const QuickAddEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class QuickAddBarcodeChanged extends QuickAddEvent {
  const QuickAddBarcodeChanged(this.barcode);

  final String barcode;

  @override
  List<Object?> get props => <Object?>[barcode];
}

final class QuickAddQuantityChanged extends QuickAddEvent {
  const QuickAddQuantityChanged(this.quantity);

  final String quantity;

  @override
  List<Object?> get props => <Object?>[quantity];
}

final class QuickAddLineAdded extends QuickAddEvent {
  const QuickAddLineAdded();
}

final class QuickAddLineRemoved extends QuickAddEvent {
  const QuickAddLineRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => <Object?>[index];
}

final class QuickAddSubmitRequested extends QuickAddEvent {
  const QuickAddSubmitRequested();
}

final class QuickAddScanReset extends QuickAddEvent {
  const QuickAddScanReset();
}

final class QuickAddMessageCleared extends QuickAddEvent {
  const QuickAddMessageCleared();
}
