import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';

void main() {
  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: 'MM-245492',
    custAccount: 'MMS021',
    salesName: 'Cash Customer',
    dataArea: 'mm',
    priceGroupId: 'RETAIL',
    inventLocationId: 'MMS000WH',
    inventSiteId: 'MMS000',
    salesStatus: 'Backorder',
    documentStatus: 'None',
    custDisplayName: 'عميل نقدي ميرا مارت جدة 01',
    inventLocationName: 'Main warehouse',
    salesStatusLabel: 'طلب معلق',
    documentStatusLabel: 'بدون مستند',
    lineCount: 3,
    orderTotal: 210,
  );

  test('resolvedCustomerLabel prefers custDisplayName', () {
    expect(order.resolvedCustomerLabel, 'عميل نقدي ميرا مارت جدة 01');
  });

  test('resolvedWarehouseLabel prefers inventLocationName', () {
    expect(order.resolvedWarehouseLabel, 'Main warehouse');
  });

  test('resolved status labels prefer Arabic API labels', () {
    expect(order.resolvedSalesStatusLabel, 'طلب معلق');
    expect(order.resolvedDocumentStatusLabel, 'بدون مستند');
  });

  test('falls back to codes when display fields null', () {
    const SalesOrderHeaderEntity bare = SalesOrderHeaderEntity(
      salesId: 'SO-1',
      custAccount: 'C001',
      salesName: '',
      dataArea: 'mm',
      priceGroupId: '',
      inventLocationId: 'WH1',
      inventSiteId: '1',
      salesStatus: 'Open',
      documentStatus: 'Draft',
    );
    expect(bare.resolvedCustomerLabel, 'C001');
    expect(bare.resolvedWarehouseLabel, 'WH1');
    expect(bare.resolvedSalesStatusLabel, 'Open');
  });
}
