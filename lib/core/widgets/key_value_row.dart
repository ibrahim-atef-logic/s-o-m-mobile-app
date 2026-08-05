import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

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
          Expanded(flex: 2, child: Text(label, style: AppTextStyles.bodySm)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: numeric ? AppTextStyles.numeric : AppTextStyles.body,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
