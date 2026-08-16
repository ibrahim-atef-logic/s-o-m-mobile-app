import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
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
    super.key,
  });

  final List<SalesOrderHeaderEntity> orders;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (orders.isEmpty) {
      return AppEmptyView(
        title: l10n.noOrders,
        icon: Icons.receipt_long_outlined,
        actionLabel: l10n.refresh,
        onAction: onRefresh,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceMd,
            AppDimensions.spaceMd,
            AppDimensions.spaceMd,
            AppDimensions.spaceSm,
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchOrders,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: onQueryChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l10n.ordersCount(filtered.length), style: AppTextStyles.bodySm),
          ),
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

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final SalesOrderHeaderEntity order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/orders/${order.salesId}', extra: order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(order.salesId, style: AppTextStyles.titleLg)),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          if (order.salesName.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimensions.spaceXs),
            Text(order.salesName, style: AppTextStyles.bodySm),
          ],
          const SizedBox(height: AppDimensions.space12),
          Wrap(
            spacing: AppDimensions.spaceSm,
            runSpacing: AppDimensions.spaceSm,
            children: <Widget>[
              StatusChip.info(label: order.custAccount),
              if (order.inventLocationId.isNotEmpty)
                StatusChip.neutral(label: order.inventLocationId),
            ],
          ),
        ],
      ),
    );
  }
}
