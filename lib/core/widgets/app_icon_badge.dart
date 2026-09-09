import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';

/// Size scale for [AppIconBadge].
enum AppIconBadgeSize { sm, md, lg }

/// Rounded tonal container holding a single icon.
///
/// Used as the leading element of list rows, action tiles, and stat cards so
/// every screen shares one visual language for iconography.
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    required this.icon,
    this.color = AppColors.primary,
    this.size = AppIconBadgeSize.md,
    this.filled = false,
    super.key,
  });

  final IconData icon;
  final Color color;
  final AppIconBadgeSize size;

  /// When true the badge uses a solid brand gradient with an inverse icon.
  final bool filled;

  double get _box => switch (size) {
    AppIconBadgeSize.sm => AppDimensions.badgeSm,
    AppIconBadgeSize.md => AppDimensions.badgeMd,
    AppIconBadgeSize.lg => AppDimensions.badgeLg,
  };

  double get _icon => switch (size) {
    AppIconBadgeSize.sm => AppDimensions.iconSm,
    AppIconBadgeSize.md => AppDimensions.iconMd,
    AppIconBadgeSize.lg => AppDimensions.iconLg,
  };

  double get _radius => switch (size) {
    AppIconBadgeSize.sm => AppDimensions.radiusSm,
    AppIconBadgeSize.md => AppDimensions.radiusMd,
    AppIconBadgeSize.lg => AppDimensions.radiusLg,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _box,
      height: _box,
      decoration: BoxDecoration(
        gradient: filled ? AppGradients.brandVivid : AppGradients.tonal(color),
        borderRadius: BorderRadius.circular(_radius),
        border: filled
            ? null
            : Border.all(
                color: color.withValues(alpha: 0.14),
                width: AppDimensions.strokeHairline,
              ),
      ),
      child: Icon(
        icon,
        size: _icon,
        color: filled ? AppColors.textInverse : color,
      ),
    );
  }
}
