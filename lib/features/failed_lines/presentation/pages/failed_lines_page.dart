import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
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
        appBar: AppBar(title: Text(l10n.failedLines)),
        body: BlocBuilder<FailedLinesCubit, FailedLinesState>(
          builder: (BuildContext context, FailedLinesState state) {
            return switch (state) {
              FailedLinesInitial() || FailedLinesLoading() => ListSkeleton(
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
                        onRefresh: () => context.read<FailedLinesCubit>().load(
                          salesId: salesId,
                          company: company,
                          mode: mode,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.spaceMd),
                          itemCount: lines.length,
                          itemBuilder: (BuildContext context, int index) {
                            final FailedLineEntity line = lines[index];
                            return AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          line.itemNumber ??
                                              line.barcode ??
                                              line.id,
                                          style: AppTextStyles.titleMd,
                                        ),
                                      ),
                                      StatusChip.danger(
                                        label: l10n.failureReason,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppDimensions.spaceSm),
                                  Text(
                                    '${l10n.quantity}: ${AppFormat.quantity(line.quantity)}',
                                    style: AppTextStyles.numeric,
                                  ),
                                  const SizedBox(height: AppDimensions.spaceSm),
                                  Text(
                                    line.commentForLocale(localeCode),
                                    style: AppTextStyles.bodySm,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
            };
          },
        ),
      ),
    );
  }
}
