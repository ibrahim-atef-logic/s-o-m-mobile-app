import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';
import '../app_text_styles.dart';

/// AppBar, card, chip, dialog, snackBar, and related surface themes.
abstract final class SurfacesTheme {
  static AppBarTheme appBar() {
    return const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textInverse,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textInverse,
      ),
    );
  }

  static CardThemeData card() {
    return CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    );
  }

  static ListTileThemeData listTile() {
    return const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
    );
  }

  static ChipThemeData chip() {
    return ChipThemeData(
      backgroundColor: AppColors.surfaceMuted,
      selectedColor: AppColors.primaryContainer,
      disabledColor: AppColors.neutral100,
      labelStyle: AppTextStyles.caption.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSm,
        vertical: AppDimensions.spaceXs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      side: BorderSide.none,
    );
  }

  static DialogThemeData dialog() {
    return DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      titleTextStyle: AppTextStyles.titleLg,
      contentTextStyle: AppTextStyles.body,
    );
  }

  static BottomSheetThemeData bottomSheet() {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      showDragHandle: true,
    );
  }

  static SnackBarThemeData snackBar() {
    return SnackBarThemeData(
      backgroundColor: AppColors.neutral800,
      contentTextStyle: AppTextStyles.bodySm.copyWith(
        color: AppColors.textInverse,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      elevation: 0,
    );
  }

  static DividerThemeData divider() {
    return const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    );
  }

  static ProgressIndicatorThemeData progress() {
    return const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.neutral100,
      circularTrackColor: AppColors.neutral100,
    );
  }
}
