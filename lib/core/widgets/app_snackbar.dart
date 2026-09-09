import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../error/failures.dart';
import '../l10n/failure_l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

enum AppSnackBarType { success, error, info }

/// Shows a floating, RTL-safe snackbar with tone icon.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackBarType type = AppSnackBarType.info,
  Duration? duration,
}) {
  final (Color bg, IconData icon) = switch (type) {
    AppSnackBarType.success => (AppColors.success, Icons.check_circle_outline),
    AppSnackBarType.error => (AppColors.danger, Icons.error_outline),
    AppSnackBarType.info => (AppColors.neutral800, Icons.info_outline),
  };

  final int lines = '\n'.allMatches(message).length + 1;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration:
            duration ??
            (type == AppSnackBarType.error
                ? AppDimensions.snackBarLong
                : AppDimensions.snackBarShort),
        margin: const EdgeInsetsDirectional.all(AppDimensions.spaceMd),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: AppDimensions.space2,
              ),
              child: Icon(
                icon,
                color: AppColors.textInverse,
                size: AppDimensions.iconMd,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Text(
                message,
                maxLines: lines.clamp(1, 4),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textInverse),
              ),
            ),
          ],
        ),
      ),
    );
}

/// Error snackbar using localized failure title + API/detail message.
void showFailureSnackBar(
  BuildContext context,
  Failure failure, {
  AppLocalizations? l10n,
}) {
  final AppLocalizations loc = l10n ?? AppLocalizations.of(context);
  showAppSnackBar(
    context,
    message: failure.snackBarMessage(loc),
    type: AppSnackBarType.error,
  );
}
