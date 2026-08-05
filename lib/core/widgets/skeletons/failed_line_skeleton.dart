import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import 'shimmer_box.dart';

/// Skeleton matching a failed-line list row.
class FailedLineSkeleton extends StatelessWidget {
  const FailedLineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ShimmerBox(width: 140, height: 16),
          SizedBox(height: AppDimensions.spaceSm),
          ShimmerBox(height: 12),
          SizedBox(height: AppDimensions.spaceXs),
          ShimmerBox(width: 200, height: 12),
        ],
      ),
    );
  }
}
