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
    this.loadingMore = false,
    this.hasMore = false,
    this.skip = 0,
    this.top = SearchCustomersUseCase.defaultTop,
    this.totalCount,
  });

  final List<CustomerEntity> customers;
  final String query;
  final bool searching;
  final bool loadingMore;
  final bool hasMore;
  final int skip;
  final int top;
  final int? totalCount;

  CustomerPickerLoaded copyWith({
    List<CustomerEntity>? customers,
    String? query,
    bool? searching,
    bool? loadingMore,
    bool? hasMore,
    int? skip,
    int? top,
    int? totalCount,
    bool clearTotalCount = false,
  }) {
    return CustomerPickerLoaded(
      customers: customers ?? this.customers,
      query: query ?? this.query,
      searching: searching ?? this.searching,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      skip: skip ?? this.skip,
      top: top ?? this.top,
      totalCount: clearTotalCount ? null : (totalCount ?? this.totalCount),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    customers,
    query,
    searching,
    loadingMore,
    hasMore,
    skip,
    top,
    totalCount,
  ];
}
