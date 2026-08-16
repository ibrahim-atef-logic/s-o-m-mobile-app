import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/customers/data/models/customer_model.dart';
import 'package:logic_retail_mobile/features/customers/domain/entities/customer_entity.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('parses the customer row and keeps the Arabic name', () {
    final CustomerEntity customer = CustomerModel.fromJson(
      Fixtures.sampleCustomersJson.first,
    ).toEntity();

    expect(customer.dataAreaId, 'mm');
    expect(customer.customerAccount, 'MMS021');
    expect(customer.name, 'عميل نقدي ميرا مارت جدة 01');
    expect(customer.customerGroupId, '20');
    expect(customer.salesCurrencyCode, 'SAR');
    expect(customer.primaryPhone, isNull);
    expect(customer.displayDetails, 'MMS021');
  });

  test('falls back to the account when the name is missing', () {
    final CustomerEntity customer = CustomerModel.fromJson(<String, dynamic>{
      'dataAreaId': 'mm',
      'customerAccount': '20-10004',
    }).toEntity();

    expect(customer.displayName, '20-10004');
  });

  test('accepts D365 casing and alias keys', () {
    final CustomerEntity customer = CustomerModel.fromJson(<String, dynamic>{
      'company': 'PLTR',
      'CustomerAccount': ' PL-001 ',
      'Name': ' Trial Store ',
      'addressCity': 'Riyadh',
      'primaryPhone': '0555',
    }).toEntity();

    expect(customer.dataAreaId, 'PLTR');
    expect(customer.customerAccount, 'PL-001');
    expect(customer.name, 'Trial Store');
    expect(customer.displayDetails, 'PL-001 · Riyadh · 0555');
  });

  test('matches on account or name for local filtering', () {
    final CustomerEntity customer = CustomerModel.fromJson(
      Fixtures.sampleCustomersJson.last,
    ).toEntity();

    expect(customer.matches('10-100'), isTrue);
    expect(customer.matches('trial'), isTrue);
    expect(customer.matches('nope'), isFalse);
  });
}
