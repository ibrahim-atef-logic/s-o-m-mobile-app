import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// RTL-aware shimmer primitive used by all skeletons.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height = AppDimensions.shimmerLineMd,
    this.borderRadius,
    super.key,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      direction: isRtl ? ShimmerDirection.rtl : ShimmerDirection.ltr,
      period: AppDimensions.durationShimmer,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
    );
  }
}
