import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Unified validation / form error caption (danger color).
class AppValidationText extends StatelessWidget {
  const AppValidationText(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.spaceXs),
      child: Text(
        message!,
        style: context.textTheme.labelSmall?.copyWith(color: AppColors.danger),
      ),
    );
  }
}
