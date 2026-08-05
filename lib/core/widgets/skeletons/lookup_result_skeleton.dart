import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import 'shimmer_box.dart';

/// Skeleton matching the full-add lookup result card.
class LookupResultSkeleton extends StatelessWidget {
  const LookupResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ShimmerBox(width: 180, height: 18),
          SizedBox(height: AppDimensions.spaceMd),
          ShimmerBox(height: 14),
          SizedBox(height: AppDimensions.spaceSm),
          ShimmerBox(width: 120, height: 14),
          SizedBox(height: AppDimensions.spaceSm),
          ShimmerBox(width: 90, height: 24),
        ],
      ),
    );
  }
}
