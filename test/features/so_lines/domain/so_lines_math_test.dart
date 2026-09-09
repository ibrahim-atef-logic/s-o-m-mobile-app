import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_line_entity.dart';
import 'package:logic_retail_mobile/features/so_lines/domain/so_lines_math.dart';

void main() {
  const SalesOrderLineEntity a = SalesOrderLineEntity(
    recordId: 1,
    salesId: 'SO-1',
    itemId: 'A',
    productName: '',
    salesQty: 1,
    salesUnit: 'pcs',
    lineNum: 3,
    dataArea: 'mm',
    netAmount: 10,
  );
  const SalesOrderLineEntity b = SalesOrderLineEntity(
    recordId: 2,
    salesId: 'SO-1',
    itemId: 'B',
    productName: '',
    salesQty: 2,
    salesUnit: 'pcs',
    lineNum: 1,
    dataArea: 'mm',
    unitPrice: 5,
    netAmount: 20,
  );
  const SalesOrderLineEntity c = SalesOrderLineEntity(
    recordId: 3,
    salesId: 'SO-1',
    itemId: 'C',
    productName: '',
    salesQty: 1,
    salesUnit: 'pcs',
    lineNum: 2,
    dataArea: 'mm',
  );

  test('sortedByLineNum orders ascending by lineNum', () {
    final List<SalesOrderLineEntity> sorted = SoLinesMath.sortedByLineNum(
      <SalesOrderLineEntity>[a, b, c],
    );
    expect(sorted.map((SalesOrderLineEntity e) => e.lineNum).toList(), <num>[
      1,
      2,
      3,
    ]);
  });

  test('totalNetAmount sums netAmount and treats null as zero', () {
    expect(SoLinesMath.totalNetAmount(<SalesOrderLineEntity>[a, b, c]), 30);
  });
}
