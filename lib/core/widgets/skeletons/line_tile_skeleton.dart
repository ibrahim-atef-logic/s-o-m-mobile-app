import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import 'shimmer_box.dart';

/// Skeleton matching a sales-order line tile.
class LineTileSkeleton extends StatelessWidget {
  const LineTileSkeleton({super.key});

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
          ShimmerBox(width: 160, height: AppDimensions.iconSm),
          SizedBox(height: AppDimensions.spaceSm),
          Row(
            children: <Widget>[
              Expanded(child: ShimmerBox(height: AppDimensions.shimmerLineSm)),
              SizedBox(width: AppDimensions.spaceMd),
              ShimmerBox(width: 64, height: AppDimensions.shimmerLineSm),
            ],
          ),
        ],
      ),
    );
  }
}
