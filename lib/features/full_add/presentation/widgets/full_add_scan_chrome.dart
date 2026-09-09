import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Small spinner used while item-price / on-hand loads.
class FullAddInlineLoader extends StatelessWidget {
  const FullAddInlineLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppDimensions.spinnerSm,
      height: AppDimensions.spinnerSm,
      child: CircularProgressIndicator(
        strokeWidth: AppDimensions.strokeThin + 1,
      ),
    );
  }
}

/// Price label with trailing spinner while POST /item-price is in flight.
class FullAddPriceLoadingRow extends StatelessWidget {
  const FullAddPriceLoadingRow({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXs),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: AppDimensions.kvLabelFlex,
            child: Text(l10n.price, style: context.textTheme.bodySmall),
          ),
          const Expanded(
            flex: AppDimensions.kvValueFlex,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FullAddInlineLoader(),
            ),
          ),
        ],
      ),
    );
  }
}
