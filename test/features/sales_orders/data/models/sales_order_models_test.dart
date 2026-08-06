import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/models/sales_order_header_model.dart';
import 'package:logic_retail_mobile/features/sales_orders/data/models/sales_order_line_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('SalesOrderHeaderModel maps header pricing/warehouse fields', () {
    final SalesOrderHeaderModel model =
        SalesOrderHeaderModel.fromJson(Fixtures.sampleOrderHeaderJson);

    expect(model.salesId, Fixtures.salesId);
    expect(model.custAccount, Fixtures.custAccount);
    expect(model.priceGroupId, 'RETAIL');
    expect(model.inventLocationId, Fixtures.warehouse);
    expect(model.dataArea, Fixtures.legalEntity);

    final entity = model.toEntity();
    expect(entity.custAccount, Fixtures.custAccount);
    expect(entity.inventLocationId, Fixtures.warehouse);
  });

  test('SalesOrderLineModel maps line fields', () {
    final SalesOrderLineModel model =
        SalesOrderLineModel.fromJson(Fixtures.sampleOrderLineJson);

    expect(model.salesId, Fixtures.salesId);
    expect(model.itemId, Fixtures.itemNumber);
    expect(model.salesQty, 2);
    expect(model.toEntity().salesUnit, 'pcs');
  });
}
