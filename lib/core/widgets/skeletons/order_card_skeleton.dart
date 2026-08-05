import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import 'shimmer_box.dart';

/// Skeleton matching an order card row.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

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
          ShimmerBox(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(width: 120, height: 16),
                SizedBox(height: AppDimensions.spaceSm),
                ShimmerBox(width: 180, height: 12),
                SizedBox(height: AppDimensions.spaceSm),
                ShimmerBox(width: 80, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
