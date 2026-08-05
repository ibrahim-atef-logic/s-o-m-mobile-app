import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

/// Elevated / filled / outlined / text / icon button themes.
abstract final class ButtonsTheme {
  static ElevatedButtonThemeData elevated() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimensions.primaryButtonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        disabledBackgroundColor: AppColors.neutral200,
        disabledForegroundColor: AppColors.textTertiary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        textStyle: AppTextStyles.label.copyWith(fontSize: 15),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLg,
          vertical: AppDimensions.spaceMd,
        ),
      ),
    );
  }

  static FilledButtonThemeData filled() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimensions.primaryButtonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        textStyle: AppTextStyles.label.copyWith(fontSize: 15),
      ),
    );
  }

  static OutlinedButtonThemeData outlined() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimensions.primaryButtonHeight),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        textStyle: AppTextStyles.label.copyWith(fontSize: 15),
      ),
    );
  }

  static TextButtonThemeData text() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(
          AppDimensions.minTouchTarget,
          AppDimensions.minTouchTarget,
        ),
        textStyle: AppTextStyles.label,
      ),
    );
  }

  static IconButtonThemeData icon() {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(
          AppDimensions.minTouchTarget,
          AppDimensions.minTouchTarget,
        ),
      ),
    );
  }
}
