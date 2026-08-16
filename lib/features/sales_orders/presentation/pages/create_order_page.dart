import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user_session_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../domain/entities/sales_order_header_entity.dart';
import '../cubit/create_order_cubit.dart';
import '../widgets/create_order_form.dart';

/// New sales order: confirm session context, pick the customer, create in D365.
///
/// Pops the created [SalesOrderHeaderEntity] so the list can refresh and open
/// it.
class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final UserSessionEntity? session = _sessionOf(context);
    if (session == null || session.orderDataArea.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newSalesOrder)),
        body: AppErrorView(
          title: l10n.errorValidation,
          message: l10n.errorCompanyRequired,
        ),
      );
    }
    return BlocProvider<CreateOrderCubit>(
      create: (_) => sl<CreateOrderCubit>()..start(session),
      child: const _CreateOrderView(),
    );
  }
}

UserSessionEntity? _sessionOf(BuildContext context) {
  final AuthState auth = context.read<AuthBloc>().state;
  return auth is AuthAuthenticated ? auth.session : null;
}

class _CreateOrderView extends StatelessWidget {
  const _CreateOrderView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newSalesOrder)),
      body: BlocConsumer<CreateOrderCubit, CreateOrderState>(
        listener: _onStateChanged,
        builder: (BuildContext context, CreateOrderState state) {
          return Column(
            children: <Widget>[
              if (state.submitting) const LinearProgressIndicator(),
              Expanded(
                child: CreateOrderForm(
                  company: state.company,
                  warehouse: state.warehouse,
                  currency: state.currency,
                  customer: state.customer,
                  resolvingCustomer: state.resolvingCustomer,
                  customerError: state.customerError == null
                      ? null
                      : l10n.errorCustomerRequired,
                  onPickCustomer: () => _pickCustomer(context, state),
                ),
              ),
              _submitBar(context, state, l10n),
            ],
          );
        },
      ),
    );
  }

  Widget _submitBar(
    BuildContext context,
    CreateOrderState state,
    AppLocalizations l10n,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: SizedBox(
          height: AppDimensions.primaryButtonHeight,
          child: FilledButton.icon(
            onPressed: state.canSubmit
                ? () => context.read<CreateOrderCubit>().submit()
                : null,
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: Text(l10n.createOrder),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomer(
    BuildContext context,
    CreateOrderState state,
  ) async {
    final CreateOrderCubit cubit = context.read<CreateOrderCubit>();
    final CustomerEntity? picked = await context.push<CustomerEntity>(
      '/orders/new/customer?company=${Uri.encodeComponent(state.company)}'
      '&account=${Uri.encodeComponent(state.customer?.customerAccount ?? '')}',
    );
    if (picked != null) {
      cubit.selectCustomer(picked);
    }
  }

  void _onStateChanged(BuildContext context, CreateOrderState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (state.failure != null) {
      showFailureSnackBar(context, state.failure!, l10n: l10n);
      return;
    }
    if (state.warehouseRequired) {
      _pickWarehouse(context);
      return;
    }
    final SalesOrderHeaderEntity? created = state.createdOrder;
    if (created == null) {
      return;
    }
    showAppSnackBar(
      context,
      message: l10n.orderCreated(created.salesId),
      type: AppSnackBarType.success,
    );
    context.pop<SalesOrderHeaderEntity>(created);
  }

  Future<void> _pickWarehouse(BuildContext context) async {
    final CreateOrderCubit cubit = context.read<CreateOrderCubit>();
    final AuthBloc authBloc = context.read<AuthBloc>();
    await context.push('/warehouse?change=1');
    final AuthState auth = authBloc.state;
    if (auth is AuthAuthenticated) {
      await cubit.start(auth.session);
    }
  }
}
