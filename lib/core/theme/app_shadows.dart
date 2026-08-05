import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Soft elevation shadows (avoid harsh Material elevation).
abstract final class AppShadows {
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

  static List<BoxShadow> get stickyBarShadow => <BoxShadow>[
    BoxShadow(
      color: AppColors.neutral900.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];
}
