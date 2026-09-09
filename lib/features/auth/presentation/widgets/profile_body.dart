import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_action_tile.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_hero_header.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_session_entity.dart';

/// Signed-in profile: identity hero + session display names from `/auth/me`.
class ProfileBody extends StatelessWidget {
  const ProfileBody({required this.session, required this.l10n, super.key});

  final UserSessionEntity session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final String? channel = session.profileChannelLabel;
    final String? currency = session.profileCurrencyLabel;
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        AppHeroHeader(
          title: session.profileDisplayName,
          subtitle: session.displayOrDash(session.personnelNumber),
          icon: Icons.person_outline,
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppSectionHeader(title: l10n.profileTitle),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    KeyValueRow(
                      label: l10n.profileActiveCompany,
                      value: session.displayOrDash(
                        session.resolvedDisplayCompanyName,
                      ),
                    ),
                    if (session.needsWarehouseSelection != true)
                      KeyValueRow(
                        label: l10n.profileWarehouse,
                        value: session.displayOrDash(
                          session.resolvedDisplayWarehouseName,
                        ),
                      ),
                    if (channel != null)
                      KeyValueRow(label: l10n.profileChannel, value: channel),
                    if (currency != null)
                      KeyValueRow(label: l10n.profileCurrency, value: currency),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSm),
              AppSectionHeader(title: l10n.changePassword),
              AppActionTile(
                title: l10n.changePassword,
                icon: Icons.lock_reset_outlined,
                onTap: () => context.push('/profile/change-password'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
