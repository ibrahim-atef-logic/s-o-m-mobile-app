import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_session_entity.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthProfileOpened());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState state) {
          if (state is! AuthAuthenticated) {
            return const SizedBox.shrink();
          }
          final UserSessionEntity s = state.session;
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            children: <Widget>[
              AppCard(
                child: Column(
                  children: <Widget>[
                    _row(l10n.profileName, s.displayOrDash(s.name)),
                    _row(l10n.profileUserId, s.displayOrDash(s.userId)),
                    _row(l10n.personnelNumber, s.displayOrDash(s.personnelNumber)),
                    _row(l10n.profileActiveCompany, s.displayOrDash(s.operatingCompany)),
                    _row(l10n.profileDefaultWarehouse, s.displayOrDash(s.resolvedWarehouse)),
                    _row(l10n.profileChannel, s.displayOrDash(s.retailChannelId)),
                    _row(l10n.profileCurrency, s.displayOrDash(s.currency)),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              OutlinedButton.icon(
                onPressed: () => context.push('/warehouse?change=1'),
                icon: const Icon(Icons.warehouse_outlined),
                label: Text(l10n.changeWarehouse),
              ),
              const SizedBox(height: AppDimensions.spaceSm),
              OutlinedButton.icon(
                onPressed: () => context.push('/profile/change-password'),
                icon: const Icon(Icons.lock_reset_outlined),
                label: Text(l10n.changePassword),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(label, style: AppTextStyles.bodySm)),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.titleLg.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
