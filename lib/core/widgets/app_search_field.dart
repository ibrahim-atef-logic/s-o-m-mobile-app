import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Shared search field used by customer / warehouse pickers.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.controller,
    this.autofocus = false,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      borderSide: const BorderSide(color: AppColors.borderSoft),
    );
    return TextField(
      controller: controller,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        isDense: true,
        border: pill,
        enabledBorder: pill,
        focusedBorder: pill.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.space12,
          horizontal: AppDimensions.spaceMd,
        ),
      ),
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}
