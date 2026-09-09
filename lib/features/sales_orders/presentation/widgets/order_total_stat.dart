import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_hero_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../so_lines/domain/so_lines_math.dart';
import '../../../so_lines/presentation/cubit/so_lines_cubit.dart';

/// Order total shown inside the details hero, driven by the lines cubit.
class OrderTotalStat extends StatelessWidget {
  const OrderTotalStat({
    required this.salesId,
    required this.company,
    super.key,
  });

  final String salesId;
  final String company;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<SoLinesCubit, SoLinesState>(
      builder: (BuildContext context, SoLinesState state) {
        final (String value, bool failed) = switch (state) {
          SoLinesLoaded(:final lines) => (
            AppFormat.price(SoLinesMath.totalNetAmount(lines)),
            false,
          ),
          SoLinesFailure() => (AppFormat.dash, true),
          SoLinesInitial() || SoLinesLoading() => (AppFormat.pending, false),
        };
        return Row(
          children: <Widget>[
            Expanded(
              child: AppHeroStat(
                label: l10n.orderTotal,
                value: value,
                icon: Icons.payments_outlined,
              ),
            ),
            if (failed)
              IconButton(
                tooltip: l10n.retry,
                color: AppColors.textInverse,
                iconSize: AppDimensions.iconMd,
                onPressed: () => context.read<SoLinesCubit>().load(
                  salesId: salesId,
                  company: company,
                ),
                icon: const Icon(Icons.refresh),
              ),
          ],
        );
      },
    );
  }
}
