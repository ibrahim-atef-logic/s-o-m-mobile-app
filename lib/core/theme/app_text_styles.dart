import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale. Prefer Theme.of(context).textTheme in widgets.
abstract final class AppTextStyles {
  static const String fontFamily = 'Cairo';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// Tabular figures for quantity/price columns.
  static const TextStyle numeric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  // Legacy aliases
  static const TextStyle display = displaySm;
  static const TextStyle title = titleLg;
}
