part of 'create_order_cubit.dart';

/// Form state of the create-sales-order screen.
///
/// [copyWith] intentionally clears [failure], [customerError] and
/// [warehouseRequired] unless they are passed again, so a new attempt never
/// shows the previous error.
final class CreateOrderState extends Equatable {
  const CreateOrderState({
    this.company = '',
    this.companyDisplayName = '',
    this.warehouse,
    this.customer,
    this.resolvingCustomer = false,
    this.submitting = false,
    this.failure,
    this.customerError,
    this.warehouseRequired = false,
    this.createdOrder,
  });

  /// DataArea code for APIs — never send the display name.
  final String company;

  /// Human label for UI (falls back to [company] when D365 names are null).
  final String companyDisplayName;
  final String? warehouse;
  final CustomerEntity? customer;
  final bool resolvingCustomer;
  final bool submitting;
  final Failure? failure;
  final String? customerError;

  /// True when the user has no warehouse yet, or the backend asked for one.
  final bool warehouseRequired;

  /// Set once the order exists in D365; the screen then navigates to it.
  final SalesOrderHeaderEntity? createdOrder;

  String get companyLabel =>
      companyDisplayName.trim().isEmpty ? company : companyDisplayName;

  bool get canSubmit =>
      !submitting &&
      company.isNotEmpty &&
      (warehouse?.trim().isNotEmpty ?? false) &&
      (customer?.customerAccount.isNotEmpty ?? false);

  CreateOrderState copyWith({
    String? company,
    String? companyDisplayName,
    String? warehouse,
    CustomerEntity? customer,
    bool? resolvingCustomer,
    bool? submitting,
    Failure? failure,
    String? customerError,
    bool warehouseRequired = false,
    SalesOrderHeaderEntity? createdOrder,
  }) {
    return CreateOrderState(
      company: company ?? this.company,
      companyDisplayName: companyDisplayName ?? this.companyDisplayName,
      warehouse: warehouse ?? this.warehouse,
      customer: customer ?? this.customer,
      resolvingCustomer: resolvingCustomer ?? this.resolvingCustomer,
      submitting: submitting ?? this.submitting,
      failure: failure,
      customerError: customerError,
      warehouseRequired: warehouseRequired,
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    company,
    companyDisplayName,
    warehouse,
    customer,
    resolvingCustomer,
    submitting,
    failure,
    customerError,
    warehouseRequired,
    createdOrder,
  ];
}
