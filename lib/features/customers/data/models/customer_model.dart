import '../../../../core/utils/json_map.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerModel {
  const CustomerModel({
    required this.dataAreaId,
    required this.customerAccount,
    required this.name,
    this.customerGroupId,
    this.salesCurrencyCode,
    this.primaryPhone,
    this.addressCity,
  });

  final String dataAreaId;
  final String customerAccount;
  final String name;
  final String? customerGroupId;
  final String? salesCurrencyCode;
  final String? primaryPhone;
  final String? addressCity;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final String account = JsonMap.stringAny(json, <String>[
      'customerAccount',
      'CustomerAccount',
      'custAccount',
      'accountNum',
    ]);
    final String label = JsonMap.stringAny(json, <String>[
      'name',
      'Name',
      'customerName',
      'organizationName',
    ]);
    return CustomerModel(
      dataAreaId: JsonMap.stringAny(json, <String>['dataAreaId', 'company']),
      customerAccount: account,
      name: label.isEmpty ? account : label,
      customerGroupId: JsonMap.stringOrNull(json, 'customerGroupId'),
      salesCurrencyCode: JsonMap.stringOrNull(json, 'salesCurrencyCode'),
      primaryPhone: JsonMap.stringOrNull(json, 'primaryPhone'),
      addressCity: JsonMap.stringOrNull(json, 'addressCity'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'dataAreaId': dataAreaId,
    'customerAccount': customerAccount,
    'name': name,
    'customerGroupId': customerGroupId,
    'salesCurrencyCode': salesCurrencyCode,
    'primaryPhone': primaryPhone,
    'addressCity': addressCity,
  };

  CustomerEntity toEntity() => CustomerEntity(
    dataAreaId: dataAreaId,
    customerAccount: customerAccount,
    name: name,
    customerGroupId: customerGroupId,
    salesCurrencyCode: salesCurrencyCode,
    primaryPhone: primaryPhone,
    addressCity: addressCity,
  );
}
