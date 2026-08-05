import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'component_themes/buttons_theme.dart';
import 'component_themes/inputs_theme.dart';
import 'component_themes/surfaces_theme.dart';

/// Assembles the light ThemeData from design tokens.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTextStyles.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.textInverse,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
      onError: AppColors.textInverse,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayLg,
      displaySmall: AppTextStyles.displaySm,
      headlineSmall: AppTextStyles.headline,
      titleLarge: AppTextStyles.titleLg,
      titleMedium: AppTextStyles.titleMd,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodySm,
      labelLarge: AppTextStyles.label,
      labelSmall: AppTextStyles.caption,
    ),
    appBarTheme: SurfacesTheme.appBar(),
    cardTheme: SurfacesTheme.card(),
    listTileTheme: SurfacesTheme.listTile(),
    chipTheme: SurfacesTheme.chip(),
    dialogTheme: SurfacesTheme.dialog(),
    bottomSheetTheme: SurfacesTheme.bottomSheet(),
    snackBarTheme: SurfacesTheme.snackBar(),
    dividerTheme: SurfacesTheme.divider(),
    progressIndicatorTheme: SurfacesTheme.progress(),
    inputDecorationTheme: InputsTheme.build(),
    elevatedButtonTheme: ButtonsTheme.elevated(),
    filledButtonTheme: ButtonsTheme.filled(),
    outlinedButtonTheme: ButtonsTheme.outlined(),
    textButtonTheme: ButtonsTheme.text(),
    iconButtonTheme: ButtonsTheme.icon(),
  );
}
