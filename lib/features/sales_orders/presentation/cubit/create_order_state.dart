part of 'create_order_cubit.dart';

/// Form state of the create-sales-order screen.
///
/// [copyWith] intentionally clears [failure], [customerError] and
/// [warehouseRequired] unless they are passed again, so a new attempt never
/// shows the previous error.
final class CreateOrderState extends Equatable {
  const CreateOrderState({
    this.company = '',
    this.warehouse,
    this.currency,
    this.customer,
    this.resolvingCustomer = false,
    this.submitting = false,
    this.failure,
    this.customerError,
    this.warehouseRequired = false,
    this.createdOrder,
  });

  final String company;
  final String? warehouse;
  final String? currency;
  final CustomerEntity? customer;
  final bool resolvingCustomer;
  final bool submitting;
  final Failure? failure;
  final String? customerError;

  /// Backend answered `WAREHOUSE_REQUIRED`; the picker has to run first.
  final bool warehouseRequired;

  /// Set once the order exists in D365; the screen then navigates to it.
  final SalesOrderHeaderEntity? createdOrder;

  bool get canSubmit =>
      !submitting &&
      company.isNotEmpty &&
      (customer?.customerAccount.isNotEmpty ?? false);

  CreateOrderState copyWith({
    String? company,
    String? warehouse,
    String? currency,
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
      warehouse: warehouse ?? this.warehouse,
      currency: currency ?? this.currency,
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
    warehouse,
    currency,
    customer,
    resolvingCustomer,
    submitting,
    failure,
    customerError,
    warehouseRequired,
    createdOrder,
  ];
}
