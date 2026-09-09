import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/presentation/widgets/order_action_grid.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_app.dart';

void main() {
  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: Fixtures.salesId,
    custAccount: Fixtures.custAccount,
    salesName: 'Trial Customer',
    dataArea: Fixtures.legalEntity,
    priceGroupId: 'RETAIL',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MM',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  testWidgets('order details shows View lines and not Add items', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      home: const Scaffold(body: OrderActionGrid(order: order)),
    );

    expect(find.text('View lines'), findsOneWidget);
    expect(find.text('Add items'), findsNothing);
    expect(find.text('Add item'), findsNothing);
  });

  testWidgets('Arabic details keeps view lines only', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      locale: const Locale('ar'),
      home: const Scaffold(body: OrderActionGrid(order: order)),
    );

    expect(find.text('عرض الأسطر'), findsOneWidget);
    expect(find.text('إضافة أصناف'), findsNothing);
  });
}
