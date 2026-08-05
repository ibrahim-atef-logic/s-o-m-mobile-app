import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';

/// Bottom sticky bar with summary text and primary action.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({
    required this.summary,
    required this.actionLabel,
    required this.onAction,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  });

  final String summary;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: AppDimensions.spaceMd,
        end: AppDimensions.spaceMd,
        top: AppDimensions.spaceMd,
        bottom: MediaQuery.paddingOf(context).bottom + AppDimensions.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.stickyBarShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            summary,
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space12),
          PrimaryButton(
            label: actionLabel,
            onPressed: enabled ? onAction : null,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
