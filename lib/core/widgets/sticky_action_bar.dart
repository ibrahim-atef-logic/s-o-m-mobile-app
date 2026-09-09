import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
import 'primary_button.dart';

/// Bottom sticky bar with summary text and optional primary action.
class StickyActionBar extends StatelessWidget {
  /// Summary line + primary CTA button.
  const StickyActionBar({
    required this.summary,
    required this.actionLabel,
    required this.onAction,
    this.secondarySummary,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  }) : _summaryOnly = false;

  /// Summary-only footer (no button) — used by SO lines / full-add cart.
  const StickyActionBar.summary({
    required this.summary,
    this.secondarySummary,
    super.key,
  }) : actionLabel = '',
       onAction = null,
       isLoading = false,
       enabled = true,
       _summaryOnly = true;

  final String summary;
  final String? secondarySummary;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final bool enabled;
  final bool _summaryOnly;

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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius2Xl),
        ),
        boxShadow: AppShadows.stickyBarShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            summary,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (secondarySummary != null &&
              secondarySummary!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimensions.spaceXs),
            Text(
              secondarySummary!,
              style: context.numericStyle.copyWith(
                fontSize: 18,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (!_summaryOnly) ...<Widget>[
            const SizedBox(height: AppDimensions.space12),
            PrimaryButton(
              label: actionLabel,
              onPressed: enabled ? onAction : null,
              isLoading: isLoading,
            ),
          ],
        ],
      ),
    );
  }
}
