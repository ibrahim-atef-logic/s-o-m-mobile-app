import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/context_row.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sales_order_header_entity.dart';

/// Order summary: customer/warehouse, status, lines count, total, refresh.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    required this.order,
    required this.onRefresh,
    this.refreshing = false,
    this.fallbackLineCount,
    this.fallbackTotal,
    super.key,
  });

  final SalesOrderHeaderEntity order;
  final VoidCallback onRefresh;
  final bool refreshing;
  final int? fallbackLineCount;
  final num? fallbackTotal;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int? lines = order.lineCount ?? fallbackLineCount;
    final num? total = order.orderTotal ?? fallbackTotal;
    final String status = order.resolvedSalesStatusLabel.trim().isEmpty
        ? AppFormat.dash
        : order.resolvedSalesStatusLabel;
    final String docStatus = order.resolvedDocumentStatusLabel.trim().isEmpty
        ? AppFormat.dash
        : order.resolvedDocumentStatusLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppSectionHeader(
          title: l10n.orderSummary,
          trailing: IconButton(
            tooltip: l10n.refresh,
            onPressed: refreshing ? null : onRefresh,
            icon: refreshing
                ? const SizedBox(
                    width: AppDimensions.spinnerSm,
                    height: AppDimensions.spinnerSm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd,
            vertical: AppDimensions.spaceSm,
          ),
          child: Column(
            children: <Widget>[
              ContextRow(
                icon: Icons.storefront_outlined,
                label: l10n.customer,
                value: order.resolvedCustomerLabel,
                maxValueLines: 4,
              ),
              const Divider(height: AppDimensions.spaceMd),
              ContextRow(
                icon: Icons.warehouse_outlined,
                label: l10n.warehouse,
                value: order.resolvedWarehouseLabel,
              ),
              const Divider(height: AppDimensions.spaceMd),
              ContextRow(
                icon: Icons.sell_outlined,
                label: l10n.priceGroup,
                value: order.priceGroupId.isEmpty
                    ? AppFormat.dash
                    : order.priceGroupId,
              ),
              const Divider(height: AppDimensions.spaceMd),
              ContextRow(
                icon: Icons.flag_outlined,
                label: l10n.salesStatus,
                value: status,
              ),
              const Divider(height: AppDimensions.spaceMd),
              ContextRow(
                icon: Icons.description_outlined,
                label: l10n.documentStatus,
                value: docStatus,
              ),
              const Divider(height: AppDimensions.spaceMd),
              ContextRow(
                icon: Icons.view_list_outlined,
                label: l10n.linesCountLabel,
                value: lines == null ? AppFormat.dash : '$lines',
              ),
              const Divider(height: AppDimensions.spaceMd),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      l10n.orderTotal,
                      style: context.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    total == null ? AppFormat.dash : AppFormat.price(total),
                    style: context.numericStyle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
