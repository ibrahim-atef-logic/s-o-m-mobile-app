import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/utils/scan_code.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../full_add/presentation/bloc/full_add_bloc.dart';
import '../../../sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../../sales_orders/domain/entities/sales_order_line_entity.dart';
import '../cubit/so_lines_cubit.dart';
import '../widgets/so_lines_add_fab.dart';
import '../widgets/so_lines_scroll_view.dart';

class SoLinesPage extends StatelessWidget {
  const SoLinesPage({required this.order, super.key});

  final SalesOrderHeaderEntity order;

  @override
  Widget build(BuildContext context) {
    final AuthState auth = context.read<AuthBloc>().state;
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SoLinesCubit>(
          create: (_) =>
              sl<SoLinesCubit>()
                ..load(salesId: order.salesId, company: order.dataArea),
        ),
        BlocProvider<FullAddBloc>(
          create: (_) => sl<FullAddBloc>(
            param1: order,
            param2: auth is AuthAuthenticated
                ? auth.session.resolvedWarehouse
                : null,
          ),
        ),
      ],
      child: _SoLinesScaffold(order: order),
    );
  }
}

class _SoLinesScaffold extends StatefulWidget {
  const _SoLinesScaffold({required this.order});

  final SalesOrderHeaderEntity order;

  @override
  State<_SoLinesScaffold> createState() => _SoLinesScaffoldState();
}

class _SoLinesScaffoldState extends State<_SoLinesScaffold> {
  String _itemFilter = '';
  bool _adding = false;

  void _reloadLines() {
    context.read<SoLinesCubit>().load(
      salesId: widget.order.salesId,
      company: widget.order.dataArea,
    );
  }

  void _enterAdd({String? code, bool byItem = false}) {
    final FullAddBloc bloc = context.read<FullAddBloc>();
    bloc.add(const FullAddScanReset());
    bloc.add(FullAddLookupByItemChanged(byItem));
    if (code != null && !ScanCode.isBlank(code)) {
      bloc.add(FullAddBarcodeChanged(ScanCode.stripControls(code)));
    }
    setState(() => _adding = true);
  }

  void _exitAdd() {
    context.read<FullAddBloc>().add(const FullAddScanReset());
    setState(() => _adding = false);
  }

  Future<void> _confirmDelete(SalesOrderLineEntity line) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(l10n.deleteLine),
          content: Text(l10n.confirmDeleteLine),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.deleteLine),
            ),
          ],
        );
      },
    );
    if (!mounted || ok != true) {
      return;
    }
    await context.read<SoLinesCubit>().deleteLine(
      salesId: widget.order.salesId,
      company: widget.order.dataArea,
      recordId: line.recordId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppGradientAppBar(
        title: Text(l10n.linesTitle(widget.order.salesId)),
        actions: _adding
            ? <Widget>[
                IconButton(
                  tooltip: l10n.close,
                  onPressed: _exitAdd,
                  icon: const Icon(Icons.close),
                ),
              ]
            : null,
      ),
      // Hide FAB while composing — close lives in the app bar so it never
      // covers quantity / add controls at the bottom.
      floatingActionButton: _adding
          ? null
          : SoLinesAddFab(adding: false, onPressed: () => _enterAdd()),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.pageWash),
        child: BlocConsumer<SoLinesCubit, SoLinesState>(
          listenWhen: (SoLinesState previous, SoLinesState next) {
            final Failure? prev = previous is SoLinesLoaded
                ? previous.actionFailure
                : null;
            final Failure? curr = next is SoLinesLoaded
                ? next.actionFailure
                : null;
            return curr != null && curr != prev;
          },
          listener: (BuildContext context, SoLinesState state) {
            if (state is! SoLinesLoaded || state.actionFailure == null) {
              return;
            }
            showAppSnackBar(
              context,
              message: state.actionFailure!.localizedMessage(l10n),
              type: AppSnackBarType.error,
            );
            context.read<SoLinesCubit>().clearActionFailure();
          },
          builder: (BuildContext context, SoLinesState state) {
            return SoLinesScrollView(
              adding: _adding,
              state: state,
              itemFilter: _itemFilter,
              onItemFilter: (String v) => setState(() => _itemFilter = v),
              onEnterAdd: ({required String code, required bool byItem}) =>
                  _enterAdd(code: code, byItem: byItem),
              onRetry: _reloadLines,
              onRefresh: () async => _reloadLines(),
              onDelete: _confirmDelete,
              onLineAdded: _reloadLines,
            );
          },
        ),
      ),
    );
  }
}
