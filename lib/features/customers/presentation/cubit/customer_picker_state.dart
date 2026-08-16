part of 'customer_picker_cubit.dart';

sealed class CustomerPickerState extends Equatable {
  const CustomerPickerState();

  @override
  List<Object?> get props => <Object?>[];
}

final class CustomerPickerLoading extends CustomerPickerState {
  const CustomerPickerLoading();
}

final class CustomerPickerFailure extends CustomerPickerState {
  const CustomerPickerFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

final class CustomerPickerLoaded extends CustomerPickerState {
  const CustomerPickerLoaded({
    required this.customers,
    this.query = '',
    this.searching = false,
  });

  final List<CustomerEntity> customers;
  final String query;

  /// A debounced search is in flight while the previous results stay visible.
  final bool searching;

  CustomerPickerLoaded copyWith({
    List<CustomerEntity>? customers,
    String? query,
    bool? searching,
  }) {
    return CustomerPickerLoaded(
      customers: customers ?? this.customers,
      query: query ?? this.query,
      searching: searching ?? this.searching,
    );
  }

  @override
  List<Object?> get props => <Object?>[customers, query, searching];
}
