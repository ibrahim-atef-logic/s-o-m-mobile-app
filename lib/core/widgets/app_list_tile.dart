import 'package:flutter/material.dart';

import '../extensions/theme_context.dart';
import '../theme/app_dimensions.dart';
import 'directional_chevron.dart';

/// Shared list row with optional subtitle, leading, and RTL chevron.
class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.dense = false,
    this.backgroundColor = Colors.transparent,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool dense;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTouchTarget,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd,
              vertical: dense ? AppDimensions.spaceSm : AppDimensions.space12,
            ),
            child: Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: AppDimensions.spaceMd),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: context.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimensions.spaceXs),
                        Text(
                          subtitle!,
                          style: context.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: AppDimensions.spaceSm),
                  trailing!,
                ] else if (showChevron && onTap != null) ...<Widget>[
                  const SizedBox(width: AppDimensions.spaceSm),
                  const DirectionalChevron(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
