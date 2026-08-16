import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/domain/entities/customer_entity.dart';

/// Read-only session context plus the customer chooser.
class CreateOrderForm extends StatelessWidget {
  const CreateOrderForm({
    required this.company,
    required this.onPickCustomer,
    this.warehouse,
    this.currency,
    this.customer,
    this.resolvingCustomer = false,
    this.customerError,
    super.key,
  });

  final String company;
  final VoidCallback onPickCustomer;
  final String? warehouse;
  final String? currency;
  final CustomerEntity? customer;
  final bool resolvingCustomer;
  final String? customerError;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: <Widget>[
        AppCard(
          child: Column(
            children: <Widget>[
              KeyValueRow(label: l10n.profileActiveCompany, value: company),
              KeyValueRow(
                label: l10n.warehouse,
                value: warehouse?.trim().isNotEmpty == true ? warehouse! : '—',
              ),
              if (currency?.trim().isNotEmpty == true)
                KeyValueRow(label: l10n.profileCurrency, value: currency!),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        Text(l10n.customer, style: AppTextStyles.titleMd),
        const SizedBox(height: AppDimensions.spaceSm),
        _CustomerField(
          customer: customer,
          resolving: resolvingCustomer,
          onTap: onPickCustomer,
        ),
        if (customerError != null) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceXs),
          Text(
            customerError!,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

class _CustomerField extends StatelessWidget {
  const _CustomerField({
    required this.resolving,
    required this.onTap,
    this.customer,
  });

  final CustomerEntity? customer;
  final bool resolving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CustomerEntity? picked = customer;
    return Semantics(
      button: true,
      label: l10n.selectCustomer,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            const Icon(Icons.storefront_outlined, color: AppColors.primary),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: picked == null
                  ? Text(l10n.selectCustomer, style: AppTextStyles.body)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(picked.displayName, style: AppTextStyles.titleMd),
                        const SizedBox(height: AppDimensions.spaceXs),
                        Text(
                          picked.customerAccount,
                          style: AppTextStyles.bodySm,
                        ),
                      ],
                    ),
            ),
            if (resolving)
              const SizedBox(
                width: AppDimensions.iconMd,
                height: AppDimensions.iconMd,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.neutral300),
          ],
        ),
      ),
    );
  }
}
