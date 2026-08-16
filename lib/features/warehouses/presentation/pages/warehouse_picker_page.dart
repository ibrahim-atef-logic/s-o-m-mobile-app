import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/skeletons/company_tile_skeleton.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../cubit/warehouse_picker_cubit.dart';
import '../widgets/warehouse_list_body.dart';

/// Standard warehouse selection.
///
/// Opened as a blocking gate when the cached session has no warehouse, or from
/// the profile ([isChange] = true) to overwrite the current one.
class WarehousePickerPage extends StatelessWidget {
  const WarehousePickerPage({this.isChange = false, super.key});

  final bool isChange;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.session.operatingCompany.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.selectWarehouse)),
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
        currentWarehouse: auth.session.resolvedWarehouse,
        isChange: isChange,
      ),
    );
  }
}

class _WarehousePickerView extends StatelessWidget {
  const _WarehousePickerView({
    required this.company,
    required this.isChange,
    this.currentWarehouse,
  });

  final String company;
  final String? currentWarehouse;
  final bool isChange;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: isChange,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: isChange,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.selectWarehouse),
              Text(company, style: AppTextStyles.bodySm),
            ],
          ),
          actions: <Widget>[
            // The gate cannot be dismissed, so signing out is the only exit.
            if (!isChange)
              Semantics(
                label: l10n.logout,
                button: true,
                child: IconButton(
                  tooltip: l10n.logout,
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  icon: const Icon(Icons.logout),
                ),
              ),
          ],
        ),
        body: BlocConsumer<WarehousePickerCubit, WarehousePickerState>(
          listener: _onStateChanged,
          builder: (BuildContext context, WarehousePickerState state) {
            return switch (state) {
              WarehousePickerLoading() ||
              WarehousePickerSaved() => ListSkeleton(
                itemBuilder: (_, int index) => const CompanyTileSkeleton(),
              ),
              WarehousePickerFailure(:final failure) => AppErrorView(
                title: l10n.errorWarehousesLoadFailed,
                message: failure.localizedMessage(l10n),
                details: failure.technicalDetails,
                onRetry: () =>
                    context.read<WarehousePickerCubit>().load(company),
              ),
              WarehousePickerLoaded() => _body(context, state, l10n),
            };
          },
        ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceMd,
            AppDimensions.spaceMd,
            AppDimensions.spaceMd,
            0,
          ),
          child: Text(l10n.selectWarehouseHint, style: AppTextStyles.bodySm),
        ),
        if (state.saving) const LinearProgressIndicator(),
        Expanded(
          child: WarehouseListBody(
            warehouses: state.warehouses,
            selectedCode: currentWarehouse,
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
    if (isChange && context.canPop()) {
      context.pop();
      return;
    }
    context.go('/orders');
  }
}
