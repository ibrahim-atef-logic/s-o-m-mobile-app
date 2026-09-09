import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Lifts a FAB above [StickyActionBar] so it does not cover the order total.
class RaisedFab extends StatelessWidget {
  const RaisedFab({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.fabAboveSticky),
      child: child,
    );
  }
}
