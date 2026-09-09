import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../error/failures.dart';
import '../l10n/failure_l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Full readable failure dialog (raw API text, selectable + copy).
Future<void> showFailureDetailsDialog(
  BuildContext context,
  Failure failure, {
  AppLocalizations? l10n,
}) {
  final AppLocalizations loc = l10n ?? AppLocalizations.of(context);
  final String title = failure.localizedTitle(loc);
  final String summary = failure.localizedMessage(loc);
  final String raw = failure.message.trim().isEmpty
      ? summary
      : failure.message.trim();

  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (summary != title && summary != raw) ...<Widget>[
                  Text(summary, style: Theme.of(ctx).textTheme.bodyMedium),
                  const SizedBox(height: AppDimensions.spaceMd),
                ],
                SelectableText(
                  raw,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: raw));
              if (!ctx.mounted) {
                return;
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(loc.errorCopied)));
            },
            child: Text(loc.copyError),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.close),
          ),
        ],
      );
    },
  );
}
