import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class WarehouseMissingBanner extends StatelessWidget {
  const WarehouseMissingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.warningContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.warehouse_outlined, color: AppColors.warning),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Text(
                l10n.warehouseNotAssignedBanner,
                style: AppTextStyles.bodySm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
