import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'app_card.dart';
import 'app_icon_badge.dart';
import 'app_list_tile.dart';

/// Card-shaped navigation row: tonal icon badge, title, subtitle, chevron.
class AppActionTile extends StatelessWidget {
  const AppActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.color = AppColors.primary,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: AppDimensions.space12),
      child: AppListTile(
        title: title,
        subtitle: subtitle,
        leading: AppIconBadge(icon: icon, color: color),
        trailing: trailing,
        showChevron: true,
        onTap: onTap,
      ),
    );
  }
}
