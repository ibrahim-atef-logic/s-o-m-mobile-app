import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_validation_text.dart';
import '../../../../core/widgets/context_row.dart';
import '../../../../core/widgets/directional_chevron.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/domain/entities/customer_entity.dart';

/// Read-only session context plus the customer chooser.
class CreateOrderForm extends StatelessWidget {
  const CreateOrderForm({
    required this.company,
    required this.onPickCustomer,
    this.warehouse,
    this.customer,
    this.resolvingCustomer = false,
    this.customerError,
    this.onPickWarehouse,
    super.key,
  });

  final String company;
  final VoidCallback onPickCustomer;
  final String? warehouse;
  final CustomerEntity? customer;
  final bool resolvingCustomer;
  final String? customerError;
  final VoidCallback? onPickWarehouse;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? code = warehouse?.trim();
    final bool missingWarehouse = code == null || code.isEmpty;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: <Widget>[
        AppSectionHeader(title: l10n.profileTitle),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd,
            vertical: AppDimensions.spaceSm,
          ),
          child: Column(
            children: <Widget>[
              ContextRow(
                icon: Icons.apartment_outlined,
                label: l10n.profileActiveCompany,
                value: company,
              ),
              const Divider(height: AppDimensions.spaceMd),
              ContextRow(
                icon: Icons.warehouse_outlined,
                label: l10n.warehouse,
                value: missingWarehouse
                    ? (onPickWarehouse == null
                          ? AppFormat.dash
                          : l10n.selectWarehouse)
                    : code,
                highlight: missingWarehouse,
                onTap: onPickWarehouse,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        AppSectionHeader(title: l10n.customer),
        _CustomerField(
          customer: customer,
          resolving: resolvingCustomer,
          onTap: onPickCustomer,
        ),
        AppValidationText(customerError),
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
    return AppCard(
      semanticsLabel: l10n.selectCustomer,
      variant: picked == null ? AppCardVariant.surface : AppCardVariant.tonal,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          AppIconBadge(
            icon: Icons.storefront_outlined,
            color: picked == null ? AppColors.primary : AppColors.success,
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: picked == null
                ? Text(l10n.selectCustomer, style: context.textTheme.bodyMedium)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        picked.displayName,
                        style: context.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.space2),
                      Text(
                        picked.customerAccount,
                        style: context.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          if (resolving)
            const SizedBox(
              width: AppDimensions.spinnerMd,
              height: AppDimensions.spinnerMd,
              child: CircularProgressIndicator(
                strokeWidth: AppDimensions.spinnerStroke,
              ),
            )
          else
            const DirectionalChevron(),
        ],
      ),
    );
  }
}
