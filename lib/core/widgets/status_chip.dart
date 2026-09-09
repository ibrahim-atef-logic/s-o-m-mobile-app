import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

enum StatusChipTone { success, warning, danger, info, neutral }

/// Compact status pill for stock, line status, and failure reasons.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    this.tone = StatusChipTone.neutral,
    super.key,
  });

  const StatusChip.success({required this.label, super.key})
    : tone = StatusChipTone.success;

  const StatusChip.warning({required this.label, super.key})
    : tone = StatusChipTone.warning;

  const StatusChip.danger({required this.label, super.key})
    : tone = StatusChipTone.danger;

  const StatusChip.info({required this.label, super.key})
    : tone = StatusChipTone.info;

  const StatusChip.neutral({required this.label, super.key})
    : tone = StatusChipTone.neutral;

  final String label;
  final StatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = switch (tone) {
      StatusChipTone.success => (AppColors.success, AppColors.successContainer),
      StatusChipTone.warning => (AppColors.warning, AppColors.warningContainer),
      StatusChipTone.danger => (AppColors.danger, AppColors.dangerContainer),
      StatusChipTone.info => (AppColors.info, AppColors.infoContainer),
      StatusChipTone.neutral => (
        AppColors.textSecondary,
        AppColors.surfaceMuted,
      ),
    };

    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: AppDimensions.spaceSm,
        end: AppDimensions.space12,
        top: AppDimensions.spaceXs,
        bottom: AppDimensions.spaceXs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(
          color: fg.withValues(alpha: 0.18),
          width: AppDimensions.strokeHairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: AppDimensions.spaceSm,
            height: AppDimensions.spaceSm,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.spaceXs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
