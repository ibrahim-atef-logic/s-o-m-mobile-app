import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';

/// Visual treatment of an [AppCard].
enum AppCardVariant {
  /// White surface with a soft shadow. Default for content cards.
  surface,

  /// Brand-tinted surface for highlighted or selected content.
  tonal,

  /// Flat bordered surface with no shadow, for nested groups.
  outlined,
}

/// Surface card with soft shadow, optional accent edge, and optional tap ink.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.semanticsLabel,
    this.semanticsSelected,
    this.variant = AppCardVariant.surface,
    this.accentColor,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? semanticsLabel;
  final bool? semanticsSelected;
  final AppCardVariant variant;

  /// Draws a colored rail on the leading edge to signal status or category.
  final Color? accentColor;

  BorderRadius get _radius => BorderRadius.circular(AppDimensions.radiusXl);

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMd),
      child: child,
    );

    if (accentColor != null) {
      content = Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppDimensions.spaceXs,
            ),
            child: content,
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: AppDimensions.spaceXs,
            child: ColoredBox(color: accentColor!),
          ),
        ],
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppDimensions.space12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: variant == AppCardVariant.tonal ? null : AppColors.surface,
        gradient: variant == AppCardVariant.tonal
            ? AppGradients.brandTint
            : null,
        borderRadius: _radius,
        border: Border.all(
          color: switch (variant) {
            AppCardVariant.surface => AppColors.borderSoft,
            AppCardVariant.tonal => AppColors.primary.withValues(alpha: 0.18),
            AppCardVariant.outlined => AppColors.border,
          },
          width: AppDimensions.strokeHairline,
        ),
        boxShadow: variant == AppCardVariant.outlined
            ? null
            : AppShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: _radius,
        child: onTap == null
            ? content
            : Semantics(
                button: true,
                label: semanticsLabel,
                selected: semanticsSelected,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: _radius,
                  child: content,
                ),
              ),
      ),
    );
  }
}
