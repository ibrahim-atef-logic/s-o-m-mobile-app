import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/directional_chevron.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sales_order_header_entity.dart';

class OrdersListBody extends StatelessWidget {
  const OrdersListBody({
    required this.orders,
    required this.query,
    required this.onQueryChanged,
    required this.onRefresh,
    this.onCreateOrder,
    super.key,
  });

  final List<SalesOrderHeaderEntity> orders;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onRefresh;
  final VoidCallback? onCreateOrder;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (orders.isEmpty) {
      return AppEmptyView(
        title: l10n.noOrders,
        icon: Icons.receipt_long_outlined,
        actionLabel: onCreateOrder != null ? l10n.createOrder : l10n.refresh,
        onAction: onCreateOrder ?? onRefresh,
      );
    }
    final String q = query.toLowerCase();
    final List<SalesOrderHeaderEntity> filtered = orders.where((
      SalesOrderHeaderEntity o,
    ) {
      if (q.isEmpty) return true;
      return o.salesId.toLowerCase().contains(q) ||
          o.salesName.toLowerCase().contains(q) ||
          o.custAccount.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: <Widget>[
        _OrdersSearchHeader(
          hintText: l10n.searchOrders,
          countLabel: l10n.ordersCount(filtered.length),
          onQueryChanged: onQueryChanged,
        ),
        Expanded(
          child: filtered.isEmpty
              ? AppEmptyView(title: l10n.noOrdersMatchSearch)
              : RefreshIndicator(
                  onRefresh: () async => onRefresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    itemCount: filtered.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _OrderTile(order: filtered[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrdersSearchHeader extends StatelessWidget {
  const _OrdersSearchHeader({
    required this.hintText,
    required this.countLabel,
    required this.onQueryChanged,
  });

  final String hintText;
  final String countLabel;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          AppSearchField(hintText: hintText, onChanged: onQueryChanged),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            countLabel,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final SalesOrderHeaderEntity order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      semanticsLabel: order.salesId,
      accentColor: AppColors.primary,
      onTap: () => context.push('/orders/${order.salesId}', extra: order),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppIconBadge(icon: Icons.receipt_long_outlined),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.salesId,
                  style: context.numericStyle.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (order.salesName.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppDimensions.space2),
                  Text(
                    order.salesName,
                    style: context.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppDimensions.spaceSm),
                Wrap(
                  spacing: AppDimensions.spaceSm,
                  runSpacing: AppDimensions.spaceXs,
                  children: <Widget>[
                    StatusChip.info(label: order.custAccount),
                    if (order.inventLocationId.isNotEmpty)
                      StatusChip.neutral(label: order.inventLocationId),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceXs),
          const Padding(
            padding: EdgeInsets.only(top: AppDimensions.space12),
            child: DirectionalChevron(
              size: AppDimensions.iconSm,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
