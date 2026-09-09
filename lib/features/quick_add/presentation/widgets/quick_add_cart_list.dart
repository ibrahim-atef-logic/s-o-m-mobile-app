import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/quick_cart_line_entity.dart';
import '../bloc/quick_add_bloc.dart';

/// Swipe-to-remove list of scanned barcodes queued for batch submit.
class QuickAddCartList extends StatelessWidget {
  const QuickAddCartList({required this.lines, super.key});

  final List<QuickCartLineEntity> lines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      itemCount: lines.length,
      itemBuilder: (BuildContext context, int index) {
        final QuickCartLineEntity line = lines[index];
        return Dismissible(
          key: ValueKey<String>('${line.barcode}-$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            margin: const EdgeInsets.only(bottom: AppDimensions.space12),
            padding: const EdgeInsetsDirectional.only(
              end: AppDimensions.spaceMd,
            ),
            decoration: BoxDecoration(
              color: AppColors.dangerContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
          onDismissed: (_) =>
              context.read<QuickAddBloc>().add(QuickAddLineRemoved(index)),
          child: _QuickCartTile(line: line, index: index),
        );
      },
    );
  }
}

class _QuickCartTile extends StatelessWidget {
  const _QuickCartTile({required this.line, required this.index});

  final QuickCartLineEntity line;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      accentColor: AppColors.accent,
      child: Row(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.qr_code_2_outlined,
            size: AppIconBadgeSize.sm,
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  line.barcode,
                  style: context.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.quantity}: ${AppFormat.quantity(line.quantity)}',
                  style: context.numericStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Semantics(
            label: l10n.removeFromCart,
            button: true,
            child: IconButton(
              tooltip: l10n.removeFromCart,
              color: AppColors.danger,
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  context.read<QuickAddBloc>().add(QuickAddLineRemoved(index)),
            ),
          ),
        ],
      ),
    );
  }
}
