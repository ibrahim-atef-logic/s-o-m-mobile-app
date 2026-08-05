import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/skeletons/line_tile_skeleton.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sales_orders/domain/entities/sales_order_line_entity.dart';
import '../cubit/so_lines_cubit.dart';

class SoLinesPage extends StatelessWidget {
  const SoLinesPage({required this.salesId, required this.company, super.key});

  final String salesId;
  final String company;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocProvider<SoLinesCubit>(
      create: (_) =>
          sl<SoLinesCubit>()..load(salesId: salesId, company: company),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.linesTitle(salesId))),
        body: BlocBuilder<SoLinesCubit, SoLinesState>(
          builder: (BuildContext context, SoLinesState state) {
            return switch (state) {
              SoLinesInitial() || SoLinesLoading() => ListSkeleton(
                itemCount: 8,
                itemBuilder: (_, int index) => const LineTileSkeleton(),
              ),
              SoLinesFailure(:final failure) => AppErrorView(
                title: failure.localizedTitle(l10n),
                message: failure.localizedMessage(l10n),
                details: failure.technicalDetails,
                onRetry: () => context.read<SoLinesCubit>().load(
                  salesId: salesId,
                  company: company,
                ),
              ),
              SoLinesLoaded(:final lines) =>
                lines.isEmpty
                    ? AppEmptyView(
                        title: l10n.noLines,
                        icon: Icons.view_list_outlined,
                      )
                    : Column(
                        children: <Widget>[
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => context
                                  .read<SoLinesCubit>()
                                  .load(salesId: salesId, company: company),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(
                                  AppDimensions.spaceMd,
                                ),
                                itemCount: lines.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final SalesOrderLineEntity line =
                                      lines[index];
                                  return AppCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          line.itemId,
                                          style: AppTextStyles.titleMd,
                                        ),
                                        if (line
                                            .productName
                                            .isNotEmpty) ...<Widget>[
                                          const SizedBox(
                                            height: AppDimensions.spaceXs,
                                          ),
                                          Text(
                                            line.productName,
                                            style: AppTextStyles.bodySm,
                                          ),
                                        ],
                                        const SizedBox(
                                          height: AppDimensions.space12,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              '${l10n.qtyLabel}: ',
                                              style: AppTextStyles.bodySm,
                                            ),
                                            Text(
                                              '${AppFormat.quantity(line.salesQty)} ${line.salesUnit}',
                                              style: AppTextStyles.numeric,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsetsDirectional.only(
                              start: AppDimensions.spaceMd,
                              end: AppDimensions.spaceMd,
                              top: AppDimensions.spaceMd,
                              bottom:
                                  MediaQuery.paddingOf(context).bottom +
                                  AppDimensions.spaceMd,
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: Text(
                              l10n.linesSummary(lines.length),
                              style: AppTextStyles.titleMd,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
            };
          },
        ),
      ),
    );
  }
}
