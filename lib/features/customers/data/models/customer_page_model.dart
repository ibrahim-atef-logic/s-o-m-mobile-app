import '../../../../core/utils/json_map.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_page_result.dart';
import 'customer_model.dart';

/// Parses paginated `data` object, with dual-parse for legacy bare arrays.
class CustomerPageModel {
  const CustomerPageModel({
    required this.items,
    required this.top,
    required this.skip,
    required this.count,
    required this.hasMore,
    this.totalCount,
  });

  final List<CustomerModel> items;
  final int top;
  final int skip;
  final int count;
  final bool hasMore;
  final int? totalCount;

  factory CustomerPageModel.fromData(
    Object? data, {
    required int requestedTop,
    required int requestedSkip,
  }) {
    if (data is List<dynamic>) {
      final List<CustomerModel> items = _parseItems(data);
      return CustomerPageModel(
        items: items,
        top: requestedTop,
        skip: requestedSkip,
        count: items.length,
        hasMore: items.length >= requestedTop,
      );
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? rawItems = JsonMap.value(map, 'items') ?? map['Items'];
      final List<CustomerModel> items = rawItems is List<dynamic>
          ? _parseItems(rawItems)
          : <CustomerModel>[];
      final int top = JsonMap.integerOrNull(map, 'top') ?? requestedTop;
      final int skip = JsonMap.integerOrNull(map, 'skip') ?? requestedSkip;
      final int count = JsonMap.integerOrNull(map, 'count') ?? items.length;
      final bool? hasMoreFlag = JsonMap.flagOrNull(map, 'hasMore');
      return CustomerPageModel(
        items: items,
        top: top,
        skip: skip,
        count: count,
        hasMore: hasMoreFlag ?? items.length >= top,
        totalCount: JsonMap.integerOrNull(map, 'totalCount'),
      );
    }
    return CustomerPageModel(
      items: const <CustomerModel>[],
      top: requestedTop,
      skip: requestedSkip,
      count: 0,
      hasMore: false,
    );
  }

  static List<CustomerModel> _parseItems(List<dynamic> rows) {
    return <CustomerModel>[
      for (final Object? row in rows)
        if (row is Map)
          CustomerModel.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  CustomerPageResult toEntity() {
    return CustomerPageResult(
      items: <CustomerEntity>[
        for (final CustomerModel model in items)
          if (model.customerAccount.isNotEmpty) model.toEntity(),
      ],
      top: top,
      skip: skip,
      count: count,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }
}
