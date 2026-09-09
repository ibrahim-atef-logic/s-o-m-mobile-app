/// Spacing, radius, icon, and motion tokens.
abstract final class AppDimensions {
  // Spacing
  static const double space2 = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double space12 = 12;
  static const double spaceMd = 16;
  static const double space20 = 20;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2Xl = 24;
  static const double radius3Xl = 28;
  static const double radiusPill = 999;

  // Hero / header
  static const double heroHeaderMinHeight = 132;
  static const double heroAvatar = 72;
  static const double badgeSm = 32;
  static const double badgeMd = 44;
  static const double badgeLg = 56;

  // Icons
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;
  static const double iconHero = 56;
  static const double iconDisplay = 64;

  // Stroke / focus
  static const double strokeHairline = 0.5;
  static const double strokeThin = 1;
  static const double strokeFocus = 2;
  static const double spinnerStroke = 2.5;
  static const double spinnerSm = 16;
  static const double spinnerMd = 22;

  // Key-value row flex
  static const int kvLabelFlex = 2;
  static const int kvValueFlex = 3;

  // Scanner
  static const double scannerViewportHeight = 200;
  static const double scanLineThickness = 2;
  static const double scanLineAlpha = 0.85;
  static const double reticleStroke = 3;
  static const double reticleArm = 28;
  static const double reticleInset = 36;

  // Shimmer
  static const double shimmerLineSm = 12;
  static const double shimmerLineMd = 14;
  static const double shimmerLineLg = 18;
  static const double shimmerTitleWidth = 140;
  static const double shimmerSubtitleWidth = 180;
  static const double shimmerChipWidth = 80;
  static const double shimmerChipHeight = 20;
  static const double shimmerAvatar = 40;

  // Touch / buttons
  static const double minTouchTarget = 48;
  static const double primaryButtonHeight = 56;
  static const double pagePadding = spaceMd;
  static const double fabAboveSticky = 88;

  /// Bottom scroll / composer clearance so content sits above the FAB.
  static const double fabScrollClearance = 200;

  // Motion (ms)
  static const int durationFastMs = 150;
  static const int durationBaseMs = 250;
  static const int durationSlowMs = 400;
  static const int durationShimmerMs = 1400;
  static const int durationScanLoopMs = 1800;

  static const Duration durationFast = Duration(milliseconds: durationFastMs);
  static const Duration durationBase = Duration(milliseconds: durationBaseMs);
  static const Duration durationSlow = Duration(milliseconds: durationSlowMs);
  static const Duration durationShimmer = Duration(
    milliseconds: durationShimmerMs,
  );
  static const Duration durationScanLoop = Duration(
    milliseconds: durationScanLoopMs,
  );
  static const Duration snackBarShort = Duration(seconds: 3);
  static const Duration snackBarLong = Duration(seconds: 5);
}
