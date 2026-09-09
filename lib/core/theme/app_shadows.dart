import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Soft elevation shadows (avoid harsh Material elevation).
///
/// Elevation scale: [card] → [raised] → [sticky] → [modal].
abstract final class AppShadows {
  static List<BoxShadow> get card => cardShadow;
  static List<BoxShadow> get raised => raisedShadow;
  static List<BoxShadow> get sticky => stickyBarShadow;
  static List<BoxShadow> get modal => raisedShadow;

  static List<BoxShadow> get cardShadow => <BoxShadow>[
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get raisedShadow => <BoxShadow>[
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// Tight lift under brand-gradient CTAs.
  ///
  /// Kept small on purpose: a wide colored glow reads as a blurred edge on
  /// low-density screens instead of elevation.
  static List<BoxShadow> get brand => <BoxShadow>[
    BoxShadow(
      color: AppColors.primaryDark.withValues(alpha: 0.24),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get stickyBarShadow => <BoxShadow>[
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];
}
