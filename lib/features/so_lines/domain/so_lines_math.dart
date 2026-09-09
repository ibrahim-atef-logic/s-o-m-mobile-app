import '../../sales_orders/domain/entities/sales_order_line_entity.dart';

/// Sorting + totals for SO lines (netAmount from D365 only).
abstract final class SoLinesMath {
  static List<SalesOrderLineEntity> sortedByLineNum(
    List<SalesOrderLineEntity> lines,
  ) {
    final List<SalesOrderLineEntity> next = List<SalesOrderLineEntity>.from(
      lines,
    );
    next.sort(
      (SalesOrderLineEntity a, SalesOrderLineEntity b) =>
          a.lineNum.compareTo(b.lineNum),
    );
    return next;
  }

  /// Sum of D365 [SalesOrderLineEntity.netAmount]. Missing values count as 0.
  static num totalNetAmount(Iterable<SalesOrderLineEntity> lines) {
    num total = 0;
    for (final SalesOrderLineEntity line in lines) {
      total += line.netAmount ?? 0;
    }
    return total;
  }
}
