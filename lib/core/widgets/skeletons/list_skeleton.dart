import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';

/// Builder helper for list shimmer placeholders.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    required this.itemBuilder,
    this.itemCount = 6,
    this.padding,
    super.key,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMd),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
