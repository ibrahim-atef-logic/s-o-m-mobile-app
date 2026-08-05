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
  static const double radiusPill = 999;

  // Icons
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // Touch / buttons
  static const double minTouchTarget = 48;
  static const double primaryButtonHeight = 56;

  // Motion (ms)
  static const int durationFastMs = 150;
  static const int durationBaseMs = 250;
  static const int durationSlowMs = 400;
  static const int durationShimmerMs = 1400;

  static const Duration durationFast = Duration(milliseconds: durationFastMs);
  static const Duration durationBase = Duration(milliseconds: durationBaseMs);
  static const Duration durationSlow = Duration(milliseconds: durationSlowMs);
  static const Duration durationShimmer = Duration(
    milliseconds: durationShimmerMs,
  );
}
