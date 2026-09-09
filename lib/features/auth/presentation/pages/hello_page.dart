import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';

/// Landing gate: Continue → login (or orders if already signed in).
/// Logout is shown only when a session exists.
class HelloPage extends StatelessWidget {
  const HelloPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState authState) {
          final bool hasSession = authState is AuthAuthenticated;
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              gradient: AppGradients.brand,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceLg),
                      child: Column(
                        children: <Widget>[
                          const Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: LanguageSwitcher(onDark: true),
                          ),
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: _HelloBrand(l10n: l10n),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _HelloActions(hasSession: hasSession, l10n: l10n),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HelloBrand extends StatelessWidget {
  const _HelloBrand({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          l10n.helloTitle,
          style: context.textTheme.displaySmall?.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        Container(
          width: AppDimensions.space48,
          height: AppDimensions.strokeFocus,
          decoration: BoxDecoration(
            color: AppColors.textInverse,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        Text(
          l10n.helloSubtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            color: AppColors.textInverse.withValues(alpha: 0.92),
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HelloActions extends StatelessWidget {
  const _HelloActions({required this.hasSession, required this.l10n});

  final bool hasSession;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius3Xl),
        ),
        boxShadow: AppShadows.raisedShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceLg,
            AppDimensions.spaceXl,
            AppDimensions.spaceLg,
            AppDimensions.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PrimaryButton(
                label: l10n.continueLabel,
                icon: Icons.arrow_forward,
                onPressed: () {
                  context.go(hasSession ? '/orders' : '/login');
                },
              ),
              if (hasSession) ...<Widget>[
                const SizedBox(height: AppDimensions.spaceSm),
                TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  icon: const Icon(
                    Icons.logout,
                    size: AppDimensions.iconSm,
                    color: AppColors.danger,
                  ),
                  label: Text(
                    l10n.logout,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
