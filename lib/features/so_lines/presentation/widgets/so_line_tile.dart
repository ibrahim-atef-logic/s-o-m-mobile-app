import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/ltr_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sales_orders/domain/entities/sales_order_line_entity.dart';

class SoLineTile extends StatelessWidget {
  const SoLineTile({required this.line, this.onDelete, super.key});

  final SalesOrderLineEntity line;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AppIconBadge(
                icon: Icons.inventory_2_outlined,
                size: AppIconBadgeSize.sm,
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LtrText(
                      line.itemId,
                      style: context.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (line.productName.isNotEmpty)
                      Text(
                        line.productName,
                        style: context.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              StatusChip.info(
                label: '${AppFormat.quantity(line.salesQty)} ${line.salesUnit}',
              ),
              if (onDelete != null) ...<Widget>[
                const SizedBox(width: AppDimensions.spaceXs),
                Semantics(
                  button: true,
                  label: l10n.deleteLine,
                  child: IconButton(
                    tooltip: l10n.deleteLine,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          _MoneyStrip(
            unitPriceLabel: l10n.unitPrice,
            unitPrice: _moneyOrDash(line.unitPrice),
            totalLabel: l10n.lineTotal,
            total: _moneyOrDash(line.netAmount),
          ),
        ],
      ),
    );
  }

  String _moneyOrDash(num? value) {
    if (value == null) {
      return AppFormat.dash;
    }
    return AppFormat.price(value);
  }
}

class _MoneyStrip extends StatelessWidget {
  const _MoneyStrip({
    required this.unitPriceLabel,
    required this.unitPrice,
    required this.totalLabel,
    required this.total,
  });

  final String unitPriceLabel;
  final String unitPrice;
  final String totalLabel;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _MoneyCell(label: unitPriceLabel, value: unitPrice),
          ),
          Container(
            width: AppDimensions.strokeHairline,
            height: AppDimensions.iconLg,
            color: AppColors.border,
          ),
          Expanded(
            child: _MoneyCell(
              label: totalLabel,
              value: total,
              emphasize: true,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyCell extends StatelessWidget {
  const _MoneyCell({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: context.textTheme.labelSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: context.numericStyle.copyWith(
            color: emphasize ? AppColors.primary : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
