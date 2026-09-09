import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_icon_badge.dart';
import 'directional_chevron.dart';

/// Label / value row with a tonal icon badge and optional tap affordance.
///
/// Used for session context (company, warehouse) and order metadata.
class ContextRow extends StatelessWidget {
  const ContextRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.onTap,
    this.maxValueLines = 1,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final VoidCallback? onTap;
  final int maxValueLines;

  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppIconBadge(icon: icon, size: AppIconBadgeSize.sm),
        const SizedBox(width: AppDimensions.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: context.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.space2),
              Text(
                value,
                style: context.textTheme.titleMedium?.copyWith(
                  color: highlight ? AppColors.primary : AppColors.textPrimary,
                ),
                maxLines: maxValueLines,
                overflow: maxValueLines == 1
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
              ),
            ],
          ),
        ),
        if (onTap != null) ...<Widget>[
          const SizedBox(width: AppDimensions.spaceXs),
          const DirectionalChevron(),
        ],
      ],
    );
    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSm),
        child: row,
      );
    }
    return Semantics(
      button: true,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceSm,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}
