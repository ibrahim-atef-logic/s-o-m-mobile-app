import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../primary_button.dart';

/// Empty-state placeholder with optional action.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 64, color: AppColors.neutral300),
            const SizedBox(height: AppDimensions.spaceLg),
            Text(
              title,
              style: AppTextStyles.titleLg,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...<Widget>[
              const SizedBox(height: AppDimensions.spaceSm),
              Text(
                description!,
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppDimensions.spaceLg),
              PrimaryButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
