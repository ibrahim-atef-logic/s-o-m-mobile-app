import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Auto vs manual submit, with a one-line hint of the difference.
class FullAddModeToggle extends StatelessWidget {
  const FullAddModeToggle({
    required this.autoMode,
    required this.onChanged,
    super.key,
  });

  final bool autoMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SegmentedButton<bool>(
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: true,
              label: Text(l10n.submitModeAuto),
              icon: const Icon(Icons.bolt_outlined),
            ),
            ButtonSegment<bool>(
              value: false,
              label: Text(l10n.submitModeManual),
              icon: const Icon(Icons.playlist_add_outlined),
            ),
          ],
          selected: <bool>{autoMode},
          onSelectionChanged: (Set<bool> next) => onChanged(next.first),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        Text(
          autoMode ? l10n.submitModeAutoHint : l10n.submitModeManualHint,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
