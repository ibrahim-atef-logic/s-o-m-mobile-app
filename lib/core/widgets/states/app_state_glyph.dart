import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import '../../theme/app_gradients.dart';

/// Large circular tonal glyph used by empty and error states.
class AppStateGlyph extends StatelessWidget {
  const AppStateGlyph({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.heroAvatar + AppDimensions.spaceLg,
      height: AppDimensions.heroAvatar + AppDimensions.spaceLg,
      decoration: BoxDecoration(
        gradient: AppGradients.tonal(color),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.16),
          width: AppDimensions.strokeHairline,
        ),
      ),
      child: Icon(icon, size: AppDimensions.iconDisplay, color: color),
    );
  }
}
