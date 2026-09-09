import 'package:equatable/equatable.dart';

import 'customer_entity.dart';

/// Paginated customer search page from `GET /api/v1/customers`.
class CustomerPageResult extends Equatable {
  const CustomerPageResult({
    required this.items,
    required this.top,
    required this.skip,
    required this.count,
    required this.hasMore,
    this.totalCount,
  });

  final List<CustomerEntity> items;
  final int top;
  final int skip;
  final int count;
  final bool hasMore;
  final int? totalCount;

  @override
  List<Object?> get props => <Object?>[
    items,
    top,
    skip,
    count,
    hasMore,
    totalCount,
  ];
}
