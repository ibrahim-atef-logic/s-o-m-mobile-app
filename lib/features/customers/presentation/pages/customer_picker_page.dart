import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skeletons/company_tile_skeleton.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/customer_entity.dart';
import '../cubit/customer_picker_cubit.dart';
import '../widgets/customer_list_body.dart';

/// Searchable customer list; pops the picked [CustomerEntity].
class CustomerPickerPage extends StatelessWidget {
  const CustomerPickerPage({
    required this.company,
    this.selectedAccount,
    super.key,
  });

  final String company;
  final String? selectedAccount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomerPickerCubit>(
      create: (_) => sl<CustomerPickerCubit>()..load(company),
      child: _CustomerPickerView(
        company: company,
        selectedAccount: selectedAccount,
      ),
    );
  }
}

class _CustomerPickerView extends StatelessWidget {
  const _CustomerPickerView({required this.company, this.selectedAccount});

  final String company;
  final String? selectedAccount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.selectCustomer),
            Text(company, style: AppTextStyles.bodySm),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.searchCustomers,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (String value) =>
                  context.read<CustomerPickerCubit>().search(value),
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerPickerCubit, CustomerPickerState>(
              builder: (BuildContext context, CustomerPickerState state) {
                return switch (state) {
                  CustomerPickerLoading() => ListSkeleton(
                    itemBuilder: (_, int index) => const CompanyTileSkeleton(),
                  ),
                  CustomerPickerFailure(:final Failure failure) => AppErrorView(
                    title: l10n.errorCustomersLoadFailed,
                    message: failure.localizedMessage(l10n),
                    details: failure.technicalDetails,
                    onRetry: () => context.read<CustomerPickerCubit>().retry(),
                  ),
                  CustomerPickerLoaded() => _results(context, state),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _results(BuildContext context, CustomerPickerLoaded state) {
    return Column(
      children: <Widget>[
        if (state.searching) const LinearProgressIndicator(),
        Expanded(
          child: CustomerListBody(
            customers: state.customers,
            selectedAccount: selectedAccount,
            onSelected: (CustomerEntity customer) =>
                context.pop<CustomerEntity>(customer),
          ),
        ),
      ],
    );
  }
}
