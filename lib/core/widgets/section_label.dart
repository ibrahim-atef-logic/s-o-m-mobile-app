import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Small group heading above a section of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spaceSm,
        top: AppDimensions.spaceXs,
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(letterSpacing: 0.4),
      ),
    );
  }
}
