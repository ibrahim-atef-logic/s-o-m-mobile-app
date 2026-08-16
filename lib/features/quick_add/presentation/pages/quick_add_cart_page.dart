import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/sticky_action_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/line_item_result_entity.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../../domain/entities/quick_cart_line_entity.dart';
import '../bloc/quick_add_bloc.dart';

class QuickAddCartPage extends StatelessWidget {
  const QuickAddCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickAdd),
      ),
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
          _showResultSheet(context, l10n, result);
        },
        builder: (BuildContext context, QuickAddState state) {
          return Column(
            children: <Widget>[
              Expanded(
                child: state.lines.isEmpty
                    ? AppEmptyView(
                        title: l10n.cartEmpty,
                        icon: Icons.shopping_cart_outlined,
                        actionLabel: l10n.addItem,
                        onAction: () => _openScan(context),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.spaceMd),
                        itemCount: state.lines.length,
                        itemBuilder: (BuildContext context, int index) {
                          final QuickCartLineEntity line = state.lines[index];
                          return Dismissible(
                            key: ValueKey<String>('${line.barcode}-$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              padding: const EdgeInsetsDirectional.only(
                                end: AppDimensions.spaceMd,
                              ),
                              color: AppColors.dangerContainer,
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.danger,
                              ),
                            ),
                            onDismissed: (_) => context
                                .read<QuickAddBloc>()
                                .add(QuickAddLineRemoved(index)),
                            child: AppCard(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          line.barcode,
                                          style: AppTextStyles.titleMd,
                                        ),
                                        const SizedBox(
                                          height: AppDimensions.spaceXs,
                                        ),
                                        Text(
                                          '${l10n.quantity}: ${AppFormat.quantity(line.quantity)}',
                                          style: AppTextStyles.numeric,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Semantics(
                                    label: l10n.removeFromCart,
                                    button: true,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => context
                                          .read<QuickAddBloc>()
                                          .add(QuickAddLineRemoved(index)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScan(context),
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(l10n.addItem),
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

  void _showResultSheet(
    BuildContext context,
    AppLocalizations l10n,
    LineSubmitResultEntity result,
  ) {
    final List<LineItemResultEntity> ok = result.items
        .where((LineItemResultEntity i) => !i.isFailed)
        .toList();
    final List<LineItemResultEntity> failed = result.items
        .where((LineItemResultEntity i) => i.isFailed)
        .toList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (BuildContext context, ScrollController controller) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              child: ListView(
                controller: controller,
                children: <Widget>[
                  Text(l10n.submitResultTitle, style: AppTextStyles.headline),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Text(l10n.succeededCount(ok.length)),
                  Text(l10n.failedCount(failed.length)),
                  const SizedBox(height: AppDimensions.spaceMd),
                  ...result.items.map((LineItemResultEntity item) {
                    return AppCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.barcode ?? item.itemNumber ?? item.id,
                              style: AppTextStyles.titleMd,
                            ),
                          ),
                          item.isFailed
                              ? StatusChip.danger(
                                  label: item.commentEn ?? item.status,
                                )
                              : StatusChip.success(label: item.status),
                        ],
                      ),
                    );
                  }),
                  TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.read<QuickAddBloc>().add(
                        const QuickAddMessageCleared(),
                      );
                    },
                    child: Text(l10n.close),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
