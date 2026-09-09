import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';

/// Standard page body padding with optional sticky bottom widget.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.stickyFooter,
    this.padding = const EdgeInsets.all(AppDimensions.pagePadding),
    this.useSafeArea = true,
    this.washBackground = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? stickyFooter;
  final EdgeInsetsGeometry padding;
  final bool useSafeArea;

  /// Paints the subtle brand wash behind the body content.
  final bool washBackground;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);
    if (useSafeArea) {
      content = SafeArea(child: content);
    }
    Widget page = stickyFooter == null
        ? content
        : Column(
            children: <Widget>[
              Expanded(child: content),
              stickyFooter!,
            ],
          );
    if (washBackground) {
      page = DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.pageWash),
        child: page,
      );
    }
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: page,
    );
  }
}
