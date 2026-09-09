import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_shadows.dart';

/// White credentials sheet that docks under the brand hero.
class LoginSheet extends StatelessWidget {
  const LoginSheet({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius3Xl),
        ),
        boxShadow: AppShadows.raisedShadow,
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: AppDimensions.space12),
          const _SheetHandle(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppDimensions.space40,
        height: AppDimensions.spaceXs,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
      ),
    );
  }
}
