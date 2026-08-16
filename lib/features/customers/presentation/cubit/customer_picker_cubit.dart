import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/search_customers_usecase.dart';

part 'customer_picker_state.dart';

/// Server-side customer search with a typing debounce.
class CustomerPickerCubit extends Cubit<CustomerPickerState> {
  CustomerPickerCubit({
    required SearchCustomersUseCase searchCustomersUseCase,
    Duration debounce = const Duration(milliseconds: 400),
  }) : _searchCustomersUseCase = searchCustomersUseCase,
       _debounce = debounce,
       super(const CustomerPickerLoading());

  final SearchCustomersUseCase _searchCustomersUseCase;
  final Duration _debounce;

  Timer? _timer;
  String _company = '';
  String _query = '';

  Future<void> load(String company) {
    _company = company;
    _query = '';
    emit(const CustomerPickerLoading());
    return _fetch();
  }

  /// Debounced so typing does not fire a request per keystroke.
  void search(String term) {
    _query = term;
    final CustomerPickerState current = state;
    if (current is CustomerPickerLoaded) {
      emit(current.copyWith(query: term, searching: true));
    }
    _timer?.cancel();
    _timer = Timer(_debounce, _fetch);
  }

  Future<void> retry() {
    emit(const CustomerPickerLoading());
    return _fetch();
  }

  Future<void> _fetch() async {
    final String query = _query;
    final Either<Failure, List<CustomerEntity>> result =
        await _searchCustomersUseCase(company: _company, search: query);
    if (isClosed || query != _query) {
      return;
    }
    result.fold(
      (Failure f) => emit(CustomerPickerFailure(f)),
      (List<CustomerEntity> customers) =>
          emit(CustomerPickerLoaded(customers: customers, query: query)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
