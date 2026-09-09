import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide State;

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/app_hero_header.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../so_lines/domain/so_lines_math.dart';
import '../../../so_lines/presentation/cubit/so_lines_cubit.dart';
import '../../domain/entities/sales_order_header_entity.dart';
import '../../domain/usecases/refresh_sales_order_usecase.dart';
import '../widgets/order_action_grid.dart';
import '../widgets/order_summary_card.dart';

class SalesOrderDetailsPage extends StatefulWidget {
  const SalesOrderDetailsPage({required this.order, super.key});

  final SalesOrderHeaderEntity order;

  @override
  State<SalesOrderDetailsPage> createState() => _SalesOrderDetailsPageState();
}

class _SalesOrderDetailsPageState extends State<SalesOrderDetailsPage> {
  late SalesOrderHeaderEntity _order;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshHeader());
  }

  Future<void> _refreshHeader() async {
    if (_refreshing) {
      return;
    }
    setState(() => _refreshing = true);
    final Either<Failure, SalesOrderHeaderEntity> result =
        await sl<RefreshSalesOrderUseCase>()(
          salesId: _order.salesId,
          company: _order.dataArea,
        );
    if (!mounted) {
      return;
    }
    result.fold(
      (Failure f) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        showAppSnackBar(
          context,
          message: f.localizedMessage(l10n),
          type: AppSnackBarType.error,
        );
      },
      (SalesOrderHeaderEntity order) => setState(() => _order = order),
    );
    if (mounted) {
      setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocProvider<SoLinesCubit>(
      create: (_) =>
          sl<SoLinesCubit>()
            ..load(salesId: _order.salesId, company: _order.dataArea),
      child: Scaffold(
        appBar: AppGradientAppBar(title: Text(_order.salesId)),
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.pageWash),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              AppHeroHeader(
                title: _order.salesName.isEmpty
                    ? _order.salesId
                    : _order.salesName,
                subtitle: _order.custAccount,
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    BlocBuilder<SoLinesCubit, SoLinesState>(
                      builder: (BuildContext context, SoLinesState linesState) {
                        final int? fallbackCount = linesState is SoLinesLoaded
                            ? linesState.lines.length
                            : null;
                        final num? fallbackTotal = linesState is SoLinesLoaded
                            ? SoLinesMath.totalNetAmount(linesState.lines)
                            : null;
                        return OrderSummaryCard(
                          order: _order,
                          refreshing: _refreshing,
                          onRefresh: _refreshHeader,
                          fallbackLineCount: fallbackCount,
                          fallbackTotal: fallbackTotal,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    OrderActionGrid(order: _order),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
