import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/theme_context.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/skeletons/company_tile_skeleton.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../cubit/warehouse_picker_cubit.dart';
import '../widgets/warehouse_list_body.dart';

/// Standard warehouse selection for create-sales-order.
class WarehousePickerPage extends StatelessWidget {
  const WarehousePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.session.operatingCompany.isEmpty) {
      return Scaffold(
        appBar: AppGradientAppBar(title: Text(l10n.selectWarehouse)),
        body: AppErrorView(
          title: l10n.errorValidation,
          message: l10n.errorCompanyRequired,
        ),
      );
    }
    return BlocProvider<WarehousePickerCubit>(
      create: (_) =>
          sl<WarehousePickerCubit>()..load(auth.session.operatingCompany),
      child: _WarehousePickerView(
        company: auth.session.operatingCompany,
        companyLabel: auth.session.resolvedDisplayCompanyName.isEmpty
            ? auth.session.operatingCompany
            : auth.session.resolvedDisplayCompanyName,
        currentWarehouse: auth.session.resolvedWarehouse,
      ),
    );
  }
}

class _WarehousePickerView extends StatefulWidget {
  const _WarehousePickerView({
    required this.company,
    required this.companyLabel,
    this.currentWarehouse,
  });

  final String company;
  final String companyLabel;
  final String? currentWarehouse;

  @override
  State<_WarehousePickerView> createState() => _WarehousePickerViewState();
}

class _WarehousePickerViewState extends State<_WarehousePickerView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppGradientAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.selectWarehouse),
            Text(
              widget.companyLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textInverse.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<WarehousePickerCubit, WarehousePickerState>(
        listener: _onStateChanged,
        builder: (BuildContext context, WarehousePickerState state) {
          return switch (state) {
            WarehousePickerLoading() || WarehousePickerSaved() => ListSkeleton(
              itemBuilder: (_, int index) => const CompanyTileSkeleton(),
            ),
            WarehousePickerFailure(:final failure) => AppErrorView(
              title: l10n.errorWarehousesLoadFailed,
              message: failure.localizedMessage(l10n),
              details: failure.technicalDetails,
              onRetry: () =>
                  context.read<WarehousePickerCubit>().load(widget.company),
            ),
            WarehousePickerLoaded() => _body(context, state, l10n),
          };
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WarehousePickerLoaded state,
    AppLocalizations l10n,
  ) {
    return Column(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(AppDimensions.radius2Xl),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceMd,
            AppDimensions.spaceSm,
            AppDimensions.spaceMd,
            AppDimensions.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.selectWarehouseHint,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.86),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSm),
              AppSearchField(
                hintText: l10n.searchWarehouses,
                onChanged: (String value) => setState(() => _query = value),
              ),
            ],
          ),
        ),
        if (state.saving) const LinearProgressIndicator(),
        Expanded(
          child: WarehouseListBody(
            warehouses: state.warehouses,
            query: _query,
            selectedCode: widget.currentWarehouse,
            enabled: !state.saving,
            onSelected: (WarehouseEntity warehouse) =>
                context.read<WarehousePickerCubit>().select(warehouse),
          ),
        ),
      ],
    );
  }

  void _onStateChanged(BuildContext context, WarehousePickerState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (state is WarehousePickerLoaded && state.saveFailure != null) {
      showFailureSnackBar(context, state.saveFailure!, l10n: l10n);
      return;
    }
    if (state is! WarehousePickerSaved) {
      return;
    }
    context.read<AuthBloc>().add(AuthSessionUpdated(state.session));
    showAppSnackBar(
      context,
      message: l10n.warehouseSelected,
      type: AppSnackBarType.success,
    );
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/orders');
  }
}
