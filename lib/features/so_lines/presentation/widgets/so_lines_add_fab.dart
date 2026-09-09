import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/raised_fab.dart';
import '../../../../l10n/app_localizations.dart';

/// Browse: extended “Add item”. Adding: icon-only close (hides the add CTA).
class SoLinesAddFab extends StatelessWidget {
  const SoLinesAddFab({
    required this.adding,
    required this.onPressed,
    super.key,
  });

  final bool adding;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return RaisedFab(
      child: adding ? _closeFab(l10n) : _addFab(l10n),
    );
  }

  Widget _closeFab(AppLocalizations l10n) {
    return Semantics(
      button: true,
      label: l10n.close,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: l10n.close,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        child: const Icon(Icons.close),
      ),
    );
  }

  Widget _addFab(AppLocalizations l10n) {
    return Semantics(
      button: true,
      label: l10n.addItem,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: l10n.addItem,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add),
        label: Text(l10n.addItem),
      ),
    );
  }
}
