import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Primary action button: brand gradient, tight lift, built-in loading spinner.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool inactive = onPressed == null || isLoading;
    return Container(
      width: double.infinity,
      height: AppDimensions.primaryButtonHeight,
      decoration: BoxDecoration(
        gradient: inactive ? null : AppGradients.brandVivid,
        color: inactive ? AppColors.neutral200 : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: inactive ? null : AppShadows.brand,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.textInverse,
          disabledForegroundColor: AppColors.neutral600,
          elevation: 0,
          textStyle: AppTextStyles.label.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: AppDimensions.spinnerMd,
                width: AppDimensions.spinnerMd,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimensions.spinnerStroke,
                  color: AppColors.textInverse,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: AppDimensions.iconMd),
                    const SizedBox(width: AppDimensions.spaceSm),
                  ],
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}
