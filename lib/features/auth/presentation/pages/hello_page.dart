import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (BuildContext context, AuthState authState) {
              final bool hasSession = authState is AuthAuthenticated;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: LanguageSwitcher(),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 88,
                              height: 88,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusXl,
                                ),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 44,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceLg),
                            Text(
                              l10n.helloTitle,
                              style: AppTextStyles.displaySm,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.spaceSm),
                            Text(
                              l10n.helloSubtitle,
                              style: AppTextStyles.bodySm,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PrimaryButton(
                    label: l10n.continueLabel,
                    onPressed: () {
                      if (hasSession) {
                        context.go('/orders');
                        return;
                      }
                      context.go('/login');
                    },
                  ),
                  if (hasSession) ...<Widget>[
                    const SizedBox(height: AppDimensions.spaceMd),
                    TextButton(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthLogoutRequested());
                      },
                      child: Text(l10n.logout),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
