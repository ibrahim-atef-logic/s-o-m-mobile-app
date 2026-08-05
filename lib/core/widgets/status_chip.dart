import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.spaceXs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
