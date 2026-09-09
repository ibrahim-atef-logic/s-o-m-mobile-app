import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_page_result.dart';
import '../../domain/usecases/search_customers_usecase.dart';

part 'customer_picker_state.dart';

/// Server-side customer search with debounce and skip/top load-more.
class CustomerPickerCubit extends Cubit<CustomerPickerState> {
  CustomerPickerCubit({
    required SearchCustomersUseCase searchCustomersUseCase,
    Duration debounce = const Duration(milliseconds: 300),
  }) : _searchCustomersUseCase = searchCustomersUseCase,
       _debounce = debounce,
       super(const CustomerPickerLoading());

  final SearchCustomersUseCase _searchCustomersUseCase;
  final Duration _debounce;

  Timer? _timer;
  String _company = '';
  String _query = '';
  int _requestId = 0;
  final List<CustomerEntity> _browseCache = <CustomerEntity>[];

  Future<void> load(String company) {
    _company = company;
    _query = '';
    _browseCache.clear();
    emit(const CustomerPickerLoading());
    return _fetch(reset: true);
  }

  void search(String term) {
    _query = term;
    final CustomerPickerState current = state;
    if (current is CustomerPickerLoaded) {
      emit(current.copyWith(query: term, searching: true));
    }
    _timer?.cancel();
    _timer = Timer(_debounce, () => _fetch(reset: true));
  }

  Future<void> loadMore() async {
    final CustomerPickerState current = state;
    if (current is! CustomerPickerLoaded) {
      return;
    }
    if (!current.hasMore || current.loadingMore || current.searching) {
      return;
    }
    emit(current.copyWith(loadingMore: true));
    await _fetch(reset: false);
  }

  Future<void> retry() {
    emit(const CustomerPickerLoading());
    return _fetch(reset: true);
  }

  Future<void> _fetch({required bool reset}) async {
    final int requestId = ++_requestId;
    final String query = _query;
    final CustomerPickerState prior = state;
    final int skip = reset
        ? 0
        : (prior is CustomerPickerLoaded ? prior.skip + prior.top : 0);
    final int top = prior is CustomerPickerLoaded
        ? prior.top
        : SearchCustomersUseCase.defaultTop;

    final Either<Failure, CustomerPageResult> result =
        await _searchCustomersUseCase(
          company: _company,
          search: query,
          top: top,
          skip: skip,
        );
    if (isClosed || requestId != _requestId || query != _query) {
      return;
    }
    result.fold(
      (Failure f) {
        if (reset) {
          emit(CustomerPickerFailure(f));
        } else if (prior is CustomerPickerLoaded) {
          emit(prior.copyWith(loadingMore: false));
        }
      },
      (CustomerPageResult page) {
        final List<CustomerEntity> merged = reset
            ? page.items
            : <CustomerEntity>[
                if (prior is CustomerPickerLoaded) ...prior.customers,
                ...page.items,
              ];
        if (query.isEmpty) {
          _syncBrowseCache(merged, reset: reset);
        }
        final List<CustomerEntity> visible = query.isEmpty
            ? merged
            : reset
            ? _mergeCustomers(_localMatches(query), page.items)
            : merged;
        emit(
          CustomerPickerLoaded(
            customers: visible,
            query: query,
            hasMore: page.hasMore,
            skip: page.skip,
            top: page.top,
            totalCount: query.isEmpty ? null : page.totalCount,
          ),
        );
      },
    );
  }

  List<CustomerEntity> _localMatches(String query) {
    final String needle = query.trim();
    if (needle.isEmpty) {
      return const <CustomerEntity>[];
    }
    return _browseCache
        .where((CustomerEntity customer) => customer.matches(needle))
        .toList(growable: false);
  }

  void _syncBrowseCache(List<CustomerEntity> pageItems, {required bool reset}) {
    if (reset) {
      _browseCache
        ..clear()
        ..addAll(pageItems);
      return;
    }
    _browseCache.addAll(
      pageItems.where(
        (CustomerEntity item) => !_browseCache.any(
          (CustomerEntity cached) =>
              cached.customerAccount == item.customerAccount,
        ),
      ),
    );
  }

  List<CustomerEntity> _mergeCustomers(
    List<CustomerEntity> local,
    List<CustomerEntity> remote,
  ) {
    if (local.isEmpty) {
      return remote;
    }
    if (remote.isEmpty) {
      return local;
    }
    final List<CustomerEntity> merged = List<CustomerEntity>.from(remote);
    for (final CustomerEntity customer in local) {
      final bool exists = merged.any(
        (CustomerEntity row) =>
            row.customerAccount == customer.customerAccount,
      );
      if (!exists) {
        merged.add(customer);
      }
    }
    return merged;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
