import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';

/// Full-bleed gradient panel that opens a screen.
///
/// Sits directly under the app bar (or replaces it when [safeAreaTop] is true)
/// and hosts a title, supporting line, an optional icon, and an optional
/// [child] slot for chips or stats.
class AppHeroHeader extends StatelessWidget {
  const AppHeroHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.child,
    this.safeAreaTop = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget? child;
  final bool safeAreaTop;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.spaceLg,
        AppDimensions.pagePadding,
        AppDimensions.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                _HeroGlyph(icon: icon!),
                const SizedBox(width: AppDimensions.space12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        subtitle!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppDimensions.spaceSm),
                trailing!,
              ],
            ],
          ),
          if (child != null) ...<Widget>[
            const SizedBox(height: AppDimensions.spaceLg),
            child!,
          ],
        ],
      ),
    );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: AppDimensions.heroHeaderMinHeight,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radius2Xl),
        ),
      ),
      child: safeAreaTop ? SafeArea(bottom: false, child: content) : content,
    );
  }
}

class _HeroGlyph extends StatelessWidget {
  const _HeroGlyph({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.badgeLg,
      height: AppDimensions.badgeLg,
      decoration: BoxDecoration(
        color: AppColors.textInverse.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.textInverse.withValues(alpha: 0.24),
          width: AppDimensions.strokeHairline,
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.textInverse,
        size: AppDimensions.iconLg,
      ),
    );
  }
}

/// Compact metric shown inside an [AppHeroHeader] child slot.
class AppHeroStat extends StatelessWidget {
  const AppHeroStat({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.textInverse.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: AppDimensions.iconSm,
              color: AppColors.textInverse.withValues(alpha: 0.9),
            ),
            const SizedBox(width: AppDimensions.spaceXs),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  value,
                  style: context.numericStyle.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tonal metric card for on-surface summaries.
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget body = Padding(
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: AppDimensions.iconSm, color: color),
              const SizedBox(width: AppDimensions.spaceXs),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.borderSoft,
          width: AppDimensions.strokeHairline,
        ),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: onTap == null
            ? body
            : InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: body,
              ),
      ),
    );
  }
}
