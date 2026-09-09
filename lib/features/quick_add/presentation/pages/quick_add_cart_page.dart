import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/sticky_action_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../bloc/quick_add_bloc.dart';
import '../widgets/quick_add_cart_list.dart';
import '../widgets/quick_add_result_sheet.dart';

class QuickAddCartPage extends StatelessWidget {
  const QuickAddCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppGradientAppBar(title: Text(l10n.quickAdd)),
      body: BlocConsumer<QuickAddBloc, QuickAddState>(
        listenWhen: (QuickAddState p, QuickAddState c) =>
            (c.lastResult != null && c.lastResult != p.lastResult) ||
            (c.failure != null && c.failure != p.failure),
        listener: (BuildContext context, QuickAddState state) {
          if (state.failure != null) {
            showFailureSnackBar(context, state.failure!);
            context.read<QuickAddBloc>().add(const QuickAddMessageCleared());
            return;
          }
          final LineSubmitResultEntity? result = state.lastResult;
          if (result == null) return;
          showQuickAddResultSheet(context, l10n, result);
        },
        builder: (BuildContext context, QuickAddState state) {
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.pageWash),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: state.lines.isEmpty
                      ? AppEmptyView(
                          title: l10n.cartEmpty,
                          icon: Icons.shopping_cart_outlined,
                          actionLabel: l10n.addItem,
                          onAction: () => _openScan(context),
                        )
                      : QuickAddCartList(lines: state.lines),
                ),
                if (state.lines.isNotEmpty)
                  StickyActionBar(
                    summary: l10n.cartItemCount(state.lines.length),
                    actionLabel: l10n.submitBatch,
                    isLoading: state.submitting,
                    onAction: () => context.read<QuickAddBloc>().add(
                      const QuickAddSubmitRequested(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Semantics(
        button: true,
        label: l10n.addItem,
        child: FloatingActionButton.extended(
          onPressed: () => _openScan(context),
          tooltip: l10n.addItem,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(l10n.addItem),
        ),
      ),
    );
  }

  void _openScan(BuildContext context) {
    final QuickAddBloc bloc = context.read<QuickAddBloc>();
    bloc.add(const QuickAddScanReset());
    context.push(
      '/orders/${bloc.state.order.salesId}/quick-add/scan',
      extra: bloc,
    );
  }
}
