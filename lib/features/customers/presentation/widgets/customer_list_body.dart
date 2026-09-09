import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_selectable_tile.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/customer_entity.dart';

/// Result list of the server-side customer search with optional load-more.
class CustomerListBody extends StatelessWidget {
  const CustomerListBody({
    required this.customers,
    required this.onSelected,
    this.selectedAccount,
    this.hasMore = false,
    this.loadingMore = false,
    this.onLoadMore,
    super.key,
  });

  final List<CustomerEntity> customers;
  final ValueChanged<CustomerEntity> onSelected;
  final String? selectedAccount;
  final bool hasMore;
  final bool loadingMore;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (customers.isEmpty) {
      return AppEmptyView(
        title: l10n.noCustomers,
        icon: Icons.person_off_outlined,
      );
    }
    final int trailing = hasMore || loadingMore ? 1 : 0;
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification n) {
        if (onLoadMore == null || !hasMore || loadingMore) {
          return false;
        }
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        itemCount: customers.length + trailing,
        itemBuilder: (BuildContext context, int index) {
          if (index >= customers.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceMd),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final CustomerEntity customer = customers[index];
          return AppSelectableTile(
            title: customer.displayName,
            subtitle: customer.displayDetails,
            leadingIcon: Icons.storefront_outlined,
            selected: customer.customerAccount == selectedAccount,
            onTap: () => onSelected(customer),
          );
        },
      ),
    );
  }
}
