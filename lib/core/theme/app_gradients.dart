import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand gradients used by headers, hero surfaces, and primary CTAs.
abstract final class AppGradients {
  /// Deep teal → accent cyan, used for app headers and hero panels.
  static const LinearGradient brand = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[AppColors.primaryDark, AppColors.primary],
  );

  /// Primary CTA fill: vertical, high-contrast so white labels stay crisp
  /// (both stops keep >= 5:1 contrast against [AppColors.textInverse]).
  static const LinearGradient brandVivid = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.primaryLight, AppColors.primaryDeep],
  );

  /// Very light tint for tonal cards on white backgrounds.
  static const LinearGradient brandTint = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: <Color>[AppColors.primaryContainer, AppColors.surface],
  );

  /// Subtle page background wash.
  static const LinearGradient pageWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.brandWash, AppColors.background],
  );

  static LinearGradient tonal(Color color) {
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: <Color>[
        color.withValues(alpha: 0.16),
        color.withValues(alpha: 0.04),
      ],
    );
  }
}
