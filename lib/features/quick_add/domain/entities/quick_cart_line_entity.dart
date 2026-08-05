import 'package:equatable/equatable.dart';

class QuickCartLineEntity extends Equatable {
  const QuickCartLineEntity({required this.barcode, required this.quantity});

  final String barcode;
  final int quantity;

  @override
  List<Object?> get props => <Object?>[barcode, quantity];
}
