import 'package:equatable/equatable.dart';

/// Customer that a sales order can be created for.
class CustomerEntity extends Equatable {
  const CustomerEntity({
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

  String get displayName => name.trim().isEmpty ? customerAccount : name.trim();

  /// Account plus whatever contact details the backend returned.
  String get displayDetails {
    final List<String> parts = <String>[
      customerAccount,
      ...<String?>[addressCity, primaryPhone]
          .where((String? v) => v != null && v.trim().isNotEmpty)
          .map((String? v) => v!.trim()),
    ];
    return parts.join(' · ');
  }

  bool matches(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return true;
    }
    return customerAccount.toLowerCase().contains(needle) ||
        name.toLowerCase().contains(needle);
  }

  @override
  List<Object?> get props => <Object?>[
    dataAreaId,
    customerAccount,
    name,
    customerGroupId,
    salesCurrencyCode,
    primaryPhone,
    addressCity,
  ];
}
