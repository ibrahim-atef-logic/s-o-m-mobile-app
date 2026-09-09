import 'entities/sales_order_header_entity.dart';

/// Newest-first list order for the sales-orders screen.
///
/// Dates win when the API sent any `createdDateTime`. Otherwise the list is
/// ordered by sales order number.
abstract final class SalesOrdersSort {
  static List<SalesOrderHeaderEntity> apply(
    List<SalesOrderHeaderEntity> orders,
  ) {
    final List<SalesOrderHeaderEntity> next = List<SalesOrderHeaderEntity>.of(
      orders,
    );
    final bool hasDate = next.any(
      (SalesOrderHeaderEntity order) => _dateOf(order) != null,
    );
    next.sort((SalesOrderHeaderEntity a, SalesOrderHeaderEntity b) {
      if (hasDate) {
        final DateTime? dateA = _dateOf(a);
        final DateTime? dateB = _dateOf(b);
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA);
        }
        if (dateA != null) {
          return -1;
        }
        if (dateB != null) {
          return 1;
        }
      }
      return _compareSalesId(b.salesId, a.salesId);
    });
    return next;
  }

  static DateTime? _dateOf(SalesOrderHeaderEntity order) {
    final String? raw = order.createdDateTime?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  static int _compareSalesId(String left, String right) {
    return left.toLowerCase().compareTo(right.toLowerCase());
  }
}
