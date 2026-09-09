import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import 'shimmer_box.dart';

/// Skeleton matching a company selection tile.
class CompanyTileSkeleton extends StatelessWidget {
  const CompanyTileSkeleton({super.key});

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
      child: const Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(
                  width: AppDimensions.shimmerTitleWidth,
                  height: AppDimensions.iconSm,
                ),
                SizedBox(height: AppDimensions.spaceSm),
                ShimmerBox(width: 72, height: AppDimensions.shimmerLineSm),
              ],
            ),
          ),
          ShimmerBox(
            width: AppDimensions.iconMd,
            height: AppDimensions.iconMd,
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.radiusMd),
            ),
          ),
        ],
      ),
    );
  }
}
