import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/theme_context.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/skeletons/failed_line_skeleton.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/failed_line_entity.dart';
import '../cubit/failed_lines_cubit.dart';

class FailedLinesPage extends StatelessWidget {
  const FailedLinesPage({
    required this.salesId,
    required this.company,
    this.mode,
    super.key,
  });

  final String salesId;
  final String company;
  final String? mode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String localeCode = Localizations.localeOf(context).languageCode;
    return BlocProvider<FailedLinesCubit>(
      create: (_) =>
          sl<FailedLinesCubit>()
            ..load(salesId: salesId, company: company, mode: mode),
      child: Scaffold(
        appBar: AppGradientAppBar(title: Text(l10n.failedLines)),
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.pageWash),
          child: BlocBuilder<FailedLinesCubit, FailedLinesState>(
            builder: (BuildContext context, FailedLinesState state) {
              return switch (state) {
                FailedLinesInitial() || FailedLinesLoading() => ListSkeleton(
                  itemCount: 6,
                  itemBuilder: (_, int index) => const FailedLineSkeleton(),
                ),
                FailedLinesFailure(:final failure) => AppErrorView(
                  title: failure.localizedTitle(l10n),
                  message: failure.localizedMessage(l10n),
                  details: failure.technicalDetails,
                  onRetry: () => context.read<FailedLinesCubit>().load(
                    salesId: salesId,
                    company: company,
                    mode: mode,
                  ),
                ),
                FailedLinesLoaded(:final lines) =>
                  lines.isEmpty
                      ? AppEmptyView(
                          title: l10n.failedLinesEmpty,
                          icon: Icons.check_circle_outline,
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              context.read<FailedLinesCubit>().load(
                                salesId: salesId,
                                company: company,
                                mode: mode,
                              ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(
                              AppDimensions.spaceMd,
                            ),
                            itemCount: lines.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _FailedLineTile(
                                line: lines[index],
                                localeCode: localeCode,
                              );
                            },
                          ),
                        ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _FailedLineTile extends StatelessWidget {
  const _FailedLineTile({required this.line, required this.localeCode});

  final FailedLineEntity line;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String title = line.itemNumber ?? line.barcode ?? line.id;
    return AppCard(
      accentColor: AppColors.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AppIconBadge(
                icon: Icons.error_outline,
                color: AppColors.danger,
                size: AppIconBadgeSize.sm,
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusChip.danger(label: l10n.failureReason),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          KeyValueRow(
            label: l10n.quantity,
            value: AppFormat.quantity(line.quantity),
            numeric: true,
          ),
          if (line.barcode != null && line.barcode!.isNotEmpty)
            KeyValueRow(label: l10n.barcode, value: line.barcode!),
          const SizedBox(height: AppDimensions.spaceSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.dangerContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Text(
              line.commentForLocale(localeCode),
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.onDangerContainer,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
