import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_card.dart';
import 'app_icon_badge.dart';
import 'app_list_tile.dart';
import 'directional_chevron.dart';

/// Selectable picker row: tonal icon badge, title/subtitle, check or chevron.
class AppSelectableTile extends StatelessWidget {
  const AppSelectableTile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leadingIcon = Icons.circle_outlined,
    this.selected = false,
    this.enabled = true,
    this.semanticsLabel,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      padding: EdgeInsets.zero,
      variant: selected ? AppCardVariant.tonal : AppCardVariant.surface,
      semanticsLabel: semanticsLabel ?? title,
      semanticsSelected: selected,
      onTap: enabled ? onTap : null,
      child: AppListTile(
        title: title,
        subtitle: subtitle,
        leading: AppIconBadge(
          icon: leadingIcon,
          color: selected ? AppColors.success : AppColors.primary,
        ),
        showChevron: false,
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const DirectionalChevron(),
      ),
    );
  }
}
