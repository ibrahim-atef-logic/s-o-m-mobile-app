import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// RTL-safe forward navigation chevron (mirrors in RTL).
class DirectionalChevron extends StatelessWidget {
  const DirectionalChevron({
    this.size = AppDimensions.iconSm,
    this.color = AppColors.neutral300,
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final Icon icon = Icon(Icons.chevron_right, size: size, color: color);
    if (!isRtl) {
      return icon;
    }
    return Transform.flip(flipX: true, child: icon);
  }
}
