import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

/// InputDecorationTheme for text fields.
abstract final class InputsTheme {
  static InputDecorationTheme build() {
    final OutlineInputBorder base = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceMd,
      ),
      border: base,
      enabledBorder: base,
      focusedBorder: base.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: base.copyWith(
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: base.copyWith(
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      disabledBorder: base.copyWith(
        borderSide: const BorderSide(color: AppColors.neutral200),
      ),
      labelStyle: AppTextStyles.bodySm,
      hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
      helperStyle: AppTextStyles.caption,
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    );
  }
}
