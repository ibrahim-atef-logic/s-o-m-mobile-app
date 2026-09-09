import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_dimensions.dart';

/// Label / value row for order details and cart summaries.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    required this.label,
    required this.value,
    this.numeric = false,
    super.key,
  });

  final String label;
  final String value;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: AppDimensions.kvLabelFlex,
            child: Text(
              label,
              style: context.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: AppDimensions.kvValueFlex,
            child: Text(
              value,
              style: numeric
                  ? context.numericStyle
                  : context.textTheme.bodyMedium,
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
