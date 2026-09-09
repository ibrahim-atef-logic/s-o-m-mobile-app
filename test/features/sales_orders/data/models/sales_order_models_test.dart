import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/models/sales_order_header_model.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/models/sales_order_line_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('SalesOrderHeaderModel maps header pricing/warehouse fields', () {
    final SalesOrderHeaderModel model = SalesOrderHeaderModel.fromJson(
      Fixtures.sampleOrderHeaderJson,
    );

    expect(model.salesId, Fixtures.salesId);
    expect(model.custAccount, Fixtures.custAccount);
    expect(model.priceGroupId, 'RETAIL');
    expect(model.inventLocationId, Fixtures.warehouse);
    expect(model.custDisplayName, 'عميل نقدي ميرا مارت جدة 01');
    expect(model.inventLocationName, 'Main warehouse');
    expect(model.salesStatusLabel, 'طلب معلق');
    expect(model.lineCount, 3);
    expect(model.orderTotal, 210.0);
    expect(model.dataArea, Fixtures.legalEntity);

    final entity = model.toEntity();
    expect(entity.custAccount, Fixtures.custAccount);
    expect(entity.inventLocationId, Fixtures.warehouse);
    expect(entity.resolvedCustomerLabel, 'عميل نقدي ميرا مارت جدة 01');
    expect(entity.resolvedWarehouseLabel, 'Main warehouse');
    expect(entity.resolvedSalesStatusLabel, 'طلب معلق');
  });

  test('SalesOrderLineModel maps line fields', () {
    final SalesOrderLineModel model = SalesOrderLineModel.fromJson(
      Fixtures.sampleOrderLineJson,
    );

    expect(model.salesId, Fixtures.salesId);
    expect(model.itemId, Fixtures.itemNumber);
    expect(model.salesQty, 2);
    expect(model.unitPrice, 12.5);
    expect(model.netAmount, 25.0);
    expect(model.toEntity().salesUnit, 'pcs');
    expect(model.toEntity().netAmount, 25.0);
  });

  test('SalesOrderLineModel tolerates missing unitPrice and netAmount', () {
    final SalesOrderLineModel model =
        SalesOrderLineModel.fromJson(<String, dynamic>{
          'recordId': 2,
          'salesId': 'SO-1',
          'itemId': 'X',
          'salesQty': 1,
          'salesUnit': 'pcs',
          'lineNum': 2,
          'dataArea': 'mm',
        });
    expect(model.unitPrice, isNull);
    expect(model.netAmount, isNull);
    expect(model.toEntity().netAmount, isNull);
  });
}
