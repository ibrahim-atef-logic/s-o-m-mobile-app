import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';

/// AppBar painted with the brand gradient over a solid primary fallback.
///
/// The solid [AppColors.primary] background keeps white titles readable even
/// when Impeller fails to rasterize the gradient (common on older GLES GPUs).
class AppGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppGradientAppBar({
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textInverse,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: AppColors.textInverse),
      actionsIconTheme: const IconThemeData(color: AppColors.textInverse),
      titleTextStyle: AppTextStyles.titleLg.copyWith(
        color: AppColors.textInverse,
      ),
      flexibleSpace: const SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            gradient: AppGradients.brand,
          ),
        ),
      ),
    );
  }
}
