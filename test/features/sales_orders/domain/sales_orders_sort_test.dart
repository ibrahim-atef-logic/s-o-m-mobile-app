import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/sales_orders_sort.dart';

void main() {
  SalesOrderHeaderEntity order({
    required String salesId,
    String? createdDateTime,
  }) {
    return SalesOrderHeaderEntity(
      salesId: salesId,
      custAccount: 'C',
      salesName: 'N',
      dataArea: 'mm',
      priceGroupId: '',
      inventLocationId: '',
      inventSiteId: '',
      salesStatus: '',
      documentStatus: '',
      createdDateTime: createdDateTime,
    );
  }

  test('sorts by createdDateTime newest first when any row has a date', () {
    final List<SalesOrderHeaderEntity> sorted =
        SalesOrdersSort.apply(<SalesOrderHeaderEntity>[
          order(salesId: 'MM-1', createdDateTime: '2026-01-01T00:00:00Z'),
          order(salesId: 'MM-3', createdDateTime: '2026-08-16T13:31:11Z'),
          order(salesId: 'MM-2', createdDateTime: '2026-03-01T00:00:00Z'),
        ]);

    expect(
      sorted.map((SalesOrderHeaderEntity o) => o.salesId).toList(),
      <String>['MM-3', 'MM-2', 'MM-1'],
    );
  });

  test('sorts by sales order number when no dates are present', () {
    final List<SalesOrderHeaderEntity> sorted =
        SalesOrdersSort.apply(<SalesOrderHeaderEntity>[
          order(salesId: 'MM-245265'),
          order(salesId: 'MM-245492'),
          order(salesId: 'MM-245402'),
        ]);

    expect(
      sorted.map((SalesOrderHeaderEntity o) => o.salesId).toList(),
      <String>['MM-245492', 'MM-245402', 'MM-245265'],
    );
  });
}
