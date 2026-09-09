import 'package:flutter/material.dart';

/// Semantic color tokens for the light design system.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF0B5F7D);
  static const Color primaryDark = Color(0xFF073B52);

  /// Upper/lower stops of the primary CTA gradient. Both stay dark enough for
  /// white text to remain legible (WCAG AA at 15sp).
  static const Color primaryLight = Color(0xFF0E7595);
  static const Color primaryDeep = Color(0xFF0A5470);
  static const Color primaryContainer = Color(0xFFDCEFF6);
  static const Color accent = Color(0xFF00A6CE);

  // Semantic
  static const Color success = Color(0xFF12805C);
  static const Color successContainer = Color(0xFFDCF5EA);
  static const Color warning = Color(0xFFB26A00);
  static const Color warningContainer = Color(0xFFFFF1DC);
  static const Color danger = Color(0xFFC0281F);
  static const Color dangerContainer = Color(0xFFFDE7E5);
  static const Color info = Color(0xFF1A6FB5);
  static const Color infoContainer = Color(0xFFE3F0FB);

  // Neutrals
  static const Color neutral50 = Color(0xFFF6F8FA);
  static const Color neutral100 = Color(0xFFEDF1F5);
  static const Color neutral200 = Color(0xFFD7E0E5);
  static const Color neutral300 = Color(0xFFB8C4CD);
  static const Color neutral400 = Color(0xFF8A9AA6);
  static const Color neutral500 = Color(0xFF6B7A87);
  static const Color neutral600 = Color(0xFF4B5A66);
  static const Color neutral700 = Color(0xFF36424C);
  static const Color neutral800 = Color(0xFF24303A);
  static const Color neutral900 = Color(0xFF121A21);

  // Surfaces
  static const Color background = Color(0xFFF1F5F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF6F8FA);
  static const Color surfaceSunken = Color(0xFFE9EFF4);
  static const Color border = Color(0xFFD7E0E5);
  static const Color borderSoft = Color(0xFFE6EDF2);
  static const Color divider = Color(0xFFE8EEF2);

  /// Faint brand-tinted wash used at the top of scrollable pages.
  static const Color brandWash = Color(0xFFE7F1F6);
  static const Color accentContainer = Color(0xFFD9F1F9);

  // Text
  static const Color textPrimary = Color(0xFF1F2A33);
  static const Color textSecondary = Color(0xFF4B5A66);
  static const Color textTertiary = Color(0xFF6B7A87);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Text on semantic containers
  static const Color onPrimaryContainer = primaryDark;
  static const Color onSuccessContainer = Color(0xFF0A4D38);
  static const Color onWarningContainer = Color(0xFF6B3F00);
  static const Color onDangerContainer = Color(0xFF7A1812);
  static const Color onInfoContainer = Color(0xFF0E456F);

  // Legacy aliases used by existing screens
  static const Color error = danger;

  // Shimmer
  static const Color shimmerBase = Color(0xFFEDF1F5);
  static const Color shimmerHighlight = Color(0xFFF9FBFC);
}
