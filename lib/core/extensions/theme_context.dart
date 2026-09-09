import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Shorthand accessors for theme tokens used across screens.
extension ThemeContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Tabular numeric style (not part of Material [TextTheme]).
  TextStyle get numericStyle => AppTextStyles.numeric;
}
