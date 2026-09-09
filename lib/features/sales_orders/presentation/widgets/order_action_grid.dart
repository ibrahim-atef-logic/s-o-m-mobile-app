import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sales_order_header_entity.dart';

/// Order operations: view lines (add lives on the lines page).
class OrderActionGrid extends StatelessWidget {
  const OrderActionGrid({required this.order, super.key});

  final SalesOrderHeaderEntity order;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _ActionTile(
      icon: Icons.view_list_outlined,
      title: l10n.viewLines,
      description: l10n.viewLinesDesc,
      onTap: () => context.push(
        '/orders/${order.salesId}/lines?company=${order.dataArea}',
        extra: order,
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
      semanticsLabel: title,
      accentColor: AppColors.primary,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppIconBadge(icon: icon),
          const SizedBox(height: AppDimensions.spaceLg),
          Text(
            title,
            style: context.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.space2),
          Text(
            description,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
