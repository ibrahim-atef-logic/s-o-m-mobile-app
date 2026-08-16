import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/customer_entity.dart';

/// Result list of the server-side customer search.
class CustomerListBody extends StatelessWidget {
  const CustomerListBody({
    required this.customers,
    required this.onSelected,
    this.selectedAccount,
    super.key,
  });

  final List<CustomerEntity> customers;
  final ValueChanged<CustomerEntity> onSelected;
  final String? selectedAccount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (customers.isEmpty) {
      return AppEmptyView(
        title: l10n.noCustomers,
        icon: Icons.person_off_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd),
      itemCount: customers.length,
      itemBuilder: (BuildContext context, int index) {
        final CustomerEntity customer = customers[index];
        return _CustomerTile(
          customer: customer,
          selected: customer.customerAccount == selectedAccount,
          onTap: () => onSelected(customer),
        );
      },
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
    required this.selected,
    required this.onTap,
  });

  final CustomerEntity customer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: customer.displayName,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            const Icon(Icons.storefront_outlined, color: AppColors.primary),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(customer.displayName, style: AppTextStyles.titleMd),
                  const SizedBox(height: AppDimensions.spaceXs),
                  Text(customer.displayDetails, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: selected ? AppColors.success : AppColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }
}
