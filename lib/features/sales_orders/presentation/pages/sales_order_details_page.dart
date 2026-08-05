import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sales_order_header_entity.dart';

class SalesOrderDetailsPage extends StatelessWidget {
  const SalesOrderDetailsPage({required this.order, super.key});

  final SalesOrderHeaderEntity order;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(order.salesId)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        children: <Widget>[
          SectionLabel(l10n.orderSummary),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (order.salesName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.space12,
                    ),
                    child: Text(order.salesName, style: AppTextStyles.titleMd),
                  ),
                KeyValueRow(label: l10n.customer, value: order.custAccount),
                KeyValueRow(
                  label: l10n.warehouse,
                  value: order.inventLocationId,
                ),
                KeyValueRow(label: l10n.priceGroup, value: order.priceGroupId),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.space12,
            crossAxisSpacing: AppDimensions.space12,
            childAspectRatio: 1.15,
            children: <Widget>[
              _ActionTile(
                icon: Icons.view_list_outlined,
                title: l10n.viewLines,
                description: l10n.viewLinesDesc,
                onTap: () => context.push(
                  '/orders/${order.salesId}/lines?company=${order.dataArea}',
                ),
              ),
              _ActionTile(
                icon: Icons.playlist_add_check_outlined,
                title: l10n.fullAdd,
                description: l10n.fullAddDesc,
                onTap: () => context.push(
                  '/orders/${order.salesId}/full-add',
                  extra: order,
                ),
              ),
              _ActionTile(
                icon: Icons.flash_on_outlined,
                title: l10n.quickAdd,
                description: l10n.quickAddDesc,
                onTap: () => context.push(
                  '/orders/${order.salesId}/quick-add',
                  extra: order,
                ),
              ),
              _ActionTile(
                icon: Icons.error_outline,
                title: l10n.failedLines,
                description: l10n.failedLinesDesc,
                onTap: () => context.push(
                  '/orders/${order.salesId}/failed-lines'
                  '?company=${order.dataArea}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.titleMd),
          const SizedBox(height: AppDimensions.spaceXs),
          Text(
            description,
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
