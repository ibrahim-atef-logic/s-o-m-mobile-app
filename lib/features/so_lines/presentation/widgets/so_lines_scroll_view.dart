import 'package:flutter/material.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/skeletons/line_tile_skeleton.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../core/widgets/sticky_action_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../full_add/presentation/widgets/full_add_scan_panel.dart';
import '../../../sales_orders/domain/entities/sales_order_line_entity.dart';
import '../../domain/so_lines_math.dart';
import '../cubit/so_lines_cubit.dart';
import 'so_line_tile.dart';
import 'so_lines_scan_bar.dart';

/// Single [CustomScrollView]: header (browse/add) + lines scroll together.
class SoLinesScrollView extends StatelessWidget {
  const SoLinesScrollView({
    required this.adding,
    required this.state,
    required this.itemFilter,
    required this.onItemFilter,
    required this.onEnterAdd,
    required this.onRetry,
    required this.onRefresh,
    required this.onDelete,
    required this.onLineAdded,
    super.key,
  });

  final bool adding;
  final SoLinesState state;
  final String itemFilter;
  final ValueChanged<String> onItemFilter;
  final void Function({required String code, required bool byItem}) onEnterAdd;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final ValueChanged<SalesOrderLineEntity> onDelete;
  final VoidCallback onLineAdded;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<SalesOrderLineEntity>? lines = state is SoLinesLoaded
        ? (state as SoLinesLoaded).lines
        : null;
    final bool showTotal = lines != null && lines.isNotEmpty;
    // Extra end space when browsing under the sticky total + add FAB.
    final double fabClearance = adding
        ? AppDimensions.spaceXl
        : MediaQuery.paddingOf(context).bottom +
              AppDimensions.fabAboveSticky +
              AppDimensions.spaceXl;

    return Column(
      children: <Widget>[
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: <Widget>[
                SliverToBoxAdapter(child: _header()),
                ..._bodySlivers(l10n, lines),
                SliverToBoxAdapter(child: SizedBox(height: fabClearance)),
              ],
            ),
          ),
        ),
        if (showTotal)
          StickyActionBar.summary(
            summary: l10n.linesSummary(lines.length),
            secondarySummary:
                '${l10n.orderTotal}: '
                '${AppFormat.price(SoLinesMath.totalNetAmount(lines))}',
          ),
      ],
    );
  }

  Widget _header() {
    if (adding) {
      return FullAddScanPanel(onLineAdded: onLineAdded);
    }
    return SoLinesScanBar(onItemFilter: onItemFilter, onEnterAdd: onEnterAdd);
  }

  List<Widget> _bodySlivers(
    AppLocalizations l10n,
    List<SalesOrderLineEntity>? lines,
  ) {
    return switch (state) {
      SoLinesInitial() || SoLinesLoading() => <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) => const LineTileSkeleton(),
              childCount: 8,
            ),
          ),
        ),
      ],
      SoLinesFailure(:final failure) => <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorView(
            title: failure.localizedTitle(l10n),
            message: failure.localizedMessage(l10n),
            details: failure.technicalDetails,
            onRetry: onRetry,
          ),
        ),
      ],
      SoLinesLoaded() => _loadedSlivers(l10n, lines ?? const []),
    };
  }

  List<Widget> _loadedSlivers(
    AppLocalizations l10n,
    List<SalesOrderLineEntity> lines,
  ) {
    final String needle = itemFilter.toLowerCase();
    final List<SalesOrderLineEntity> visible = needle.trim().isEmpty
        ? lines
        : lines
              .where(
                (SalesOrderLineEntity line) =>
                    line.itemId.toLowerCase().contains(needle) ||
                    line.productName.toLowerCase().contains(needle),
              )
              .toList();

    if (visible.isEmpty) {
      if (adding) {
        return const <Widget>[SliverToBoxAdapter(child: SizedBox.shrink())];
      }
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyView(
            title: needle.trim().isEmpty
                ? l10n.noLines
                : l10n.noOrdersMatchSearch,
            icon: Icons.view_list_outlined,
          ),
        ),
      ];
    }

    return <Widget>[
      // Bottom FAB clearance is on the scroll view trailing spacer.
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spaceMd,
          AppDimensions.spaceMd,
          AppDimensions.spaceMd,
          AppDimensions.spaceMd,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((
            BuildContext context,
            int index,
          ) {
            final SalesOrderLineEntity line = visible[index];
            return SoLineTile(line: line, onDelete: () => onDelete(line));
          }, childCount: visible.length),
        ),
      ),
    ];
  }
}
