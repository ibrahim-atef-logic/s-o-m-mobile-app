import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../../../../l10n/app_localizations.dart';

/// Branded login header: back, language, mark, and welcome copy.
class LoginHero extends StatelessWidget {
  const LoginHero({required this.compact, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(child: _LoginHeroGlow()),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceMd,
              AppDimensions.spaceXs,
              AppDimensions.spaceMd,
              compact ? AppDimensions.spaceMd : AppDimensions.spaceXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _LoginTopBar(),
                SizedBox(
                  height: compact
                      ? AppDimensions.spaceSm
                      : AppDimensions.spaceLg,
                ),
                _LoginWelcomeCopy(compact: compact),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: l10n.back,
          child: IconButton(
            tooltip: l10n.back,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/hello');
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textInverse,
          ),
        ),
        const Spacer(),
        const LanguageSwitcher(onDark: true),
      ],
    );
  }
}

class _LoginWelcomeCopy extends StatelessWidget {
  const _LoginWelcomeCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _BrandMark(),
        SizedBox(
          height: compact ? AppDimensions.spaceSm : AppDimensions.spaceMd,
        ),
        Text(
          l10n.loginWelcome,
          style: context.textTheme.headlineMedium?.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (!compact) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            l10n.loginSubtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.88),
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoginHeroGlow extends StatelessWidget {
  const _LoginHeroGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.brand),
        child: Stack(
          children: <Widget>[
            PositionedDirectional(
              end: -AppDimensions.space48,
              top: -AppDimensions.spaceXl,
              child: _GlowOrb(
                size: AppDimensions.iconDisplay * 2.4,
                color: AppColors.accent.withValues(alpha: 0.22),
              ),
            ),
            PositionedDirectional(
              start: -AppDimensions.spaceXl,
              bottom: AppDimensions.space12,
              child: _GlowOrb(
                size: AppDimensions.iconDisplay * 1.6,
                color: AppColors.textInverse.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.badgeLg,
      height: AppDimensions.badgeLg,
      decoration: BoxDecoration(
        color: AppColors.textInverse,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.brand,
      ),
      child: const Icon(
        Icons.storefront_rounded,
        color: AppColors.primaryDark,
        size: AppDimensions.iconLg,
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
