import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/line_item_result_entity.dart';
import '../../../catalog/domain/entities/line_submit_result_entity.dart';
import '../bloc/quick_add_bloc.dart';

/// Bottom sheet summarising a batch submit: per-line success / failure.
void showQuickAddResultSheet(
  BuildContext context,
  AppLocalizations l10n,
  LineSubmitResultEntity result,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (BuildContext innerContext, ScrollController controller) {
          return _ResultSheetBody(
            controller: controller,
            l10n: l10n,
            result: result,
            onClose: () {
              Navigator.of(sheetContext).pop();
              context.read<QuickAddBloc>().add(const QuickAddMessageCleared());
            },
          );
        },
      );
    },
  );
}

class _ResultSheetBody extends StatelessWidget {
  const _ResultSheetBody({
    required this.controller,
    required this.l10n,
    required this.result,
    required this.onClose,
  });

  final ScrollController controller;
  final AppLocalizations l10n;
  final LineSubmitResultEntity result;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final int okCount = result.items
        .where((LineItemResultEntity i) => !i.isFailed)
        .length;
    final int failedCount = result.items.length - okCount;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: ListView(
        controller: controller,
        children: <Widget>[
          Text(l10n.submitResultTitle, style: context.textTheme.headlineSmall),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: <Widget>[
              StatusChip.success(label: l10n.succeededCount(okCount)),
              const SizedBox(width: AppDimensions.spaceSm),
              StatusChip.danger(label: l10n.failedCount(failedCount)),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          ...result.items.map((LineItemResultEntity item) {
            return AppCard(
              accentColor: item.isFailed ? AppColors.danger : AppColors.success,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.barcode ?? item.itemNumber ?? item.id,
                      style: context.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSm),
                  item.isFailed
                      ? StatusChip.danger(label: item.commentEn ?? item.status)
                      : StatusChip.success(label: item.status),
                ],
              ),
            );
          }),
          SecondaryButton(label: l10n.close, onPressed: onClose),
        ],
      ),
    );
  }
}
