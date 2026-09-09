import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Shared step progress chrome for Full-add / Quick-add scan flows.
class AddFlowStepHeader extends StatelessWidget {
  const AddFlowStepHeader({
    required this.labels,
    required this.activeIndex,
    super.key,
  });

  final List<String> labels;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final TextStyle? caption = context.textTheme.labelSmall;
    return AnimatedSwitcher(
      duration: AppDimensions.durationBase,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Row(
        key: ValueKey<int>(activeIndex),
        children: <Widget>[
          for (int i = 0; i < labels.length; i++) ...<Widget>[
            if (i > 0) const Expanded(child: Divider(color: AppColors.border)),
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: AppDimensions.iconSm - 2,
                  backgroundColor: i <= activeIndex
                      ? AppColors.primary
                      : AppColors.neutral200,
                  foregroundColor: i <= activeIndex
                      ? AppColors.textInverse
                      : AppColors.textSecondary,
                  child: Text(
                    '${i + 1}',
                    style: caption?.copyWith(
                      color: i <= activeIndex
                          ? AppColors.textInverse
                          : AppColors.textSecondary,
                      fontWeight: i == activeIndex
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXs),
                Text(
                  labels[i],
                  style: caption?.copyWith(
                    color: i == activeIndex
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: i == activeIndex
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
