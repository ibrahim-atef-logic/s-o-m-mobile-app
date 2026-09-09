import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../extensions/theme_context.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../primary_button.dart';
import '../secondary_button.dart';
import 'app_state_glyph.dart';

/// Error state with localized title, detail message, retry, optional tech dump.
class AppErrorView extends StatefulWidget {
  const AppErrorView({
    required this.title,
    this.message,
    this.details,
    this.onRetry,
    super.key,
  });

  final String title;

  /// User-facing explanation (API message). Shown under [title] when different.
  final String? message;
  final String? details;
  final VoidCallback? onRetry;

  @override
  State<AppErrorView> createState() => _AppErrorViewState();
}

class _AppErrorViewState extends State<AppErrorView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? subtitle =
        widget.message?.trim().isNotEmpty == true &&
            widget.message != widget.title
        ? widget.message
        : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AppStateGlyph(
              icon: Icons.cloud_off_outlined,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            Text(
              widget.title,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AppDimensions.spaceSm),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.onRetry != null) ...<Widget>[
              const SizedBox(height: AppDimensions.spaceLg),
              PrimaryButton(
                label: l10n.retry,
                onPressed: widget.onRetry,
                icon: Icons.refresh,
              ),
            ],
            if (widget.details != null &&
                widget.details!.isNotEmpty &&
                widget.details != subtitle) ...<Widget>[
              const SizedBox(height: AppDimensions.spaceMd),
              SecondaryButton(
                label: _expanded ? l10n.close : l10n.details,
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
              if (_expanded) ...<Widget>[
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  widget.details!,
                  style: context.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
