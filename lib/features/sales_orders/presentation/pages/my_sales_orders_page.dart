import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/skeletons/order_card_skeleton.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user_session_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/sales_orders_bloc.dart';
import '../widgets/orders_list_body.dart';
import '../widgets/warehouse_missing_banner.dart';

class MySalesOrdersPage extends StatefulWidget {
  const MySalesOrdersPage({super.key});

  @override
  State<MySalesOrdersPage> createState() => _MySalesOrdersPageState();
}

class _MySalesOrdersPageState extends State<MySalesOrdersPage> {
  String _query = '';
  String? _companyCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final AuthState auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated && auth.session.operatingCompany.isNotEmpty) {
      _companyCode = auth.session.operatingCompany;
      context.read<SalesOrdersBloc>().add(SalesOrdersRequested(_companyCode!));
      return;
    }
    _companyCode = null;
  }

  UserSessionEntity? get _session {
    final AuthState auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated ? auth.session : null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_companyCode == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.mySalesOrders)),
        body: AppErrorView(
          title: l10n.errorValidation,
          message: l10n.errorCompanyRequired,
          onRetry: () {
            setState(_load);
          },
        ),
      );
    }
    final UserSessionEntity? session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.mySalesOrders),
            if (session != null)
              Text(
                '${session.displayOrDash(session.operatingCompany)} / ${session.displayOrDash(session.resolvedWarehouse)}',
                style: AppTextStyles.bodySm,
              ),
          ],
        ),
        actions: <Widget>[
          const LanguageSwitcher(compact: true),
          Semantics(
            label: l10n.profileTitle,
            button: true,
            child: IconButton(
              tooltip: l10n.profileTitle,
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
            ),
          ),
          Semantics(
            label: l10n.logout,
            button: true,
            child: IconButton(
              tooltip: l10n.logout,
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              icon: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (session != null && session.warehouseMissing)
            const WarehouseMissingBanner(),
          Expanded(
            child: BlocBuilder<SalesOrdersBloc, SalesOrdersState>(
              builder: (BuildContext context, SalesOrdersState state) {
                return switch (state) {
                  SalesOrdersInitial() || SalesOrdersLoading() => ListSkeleton(
                    itemBuilder: (_, int index) => const OrderCardSkeleton(),
                  ),
                  SalesOrdersFailure(:final failure) => AppErrorView(
                    title: failure.localizedTitle(l10n),
                    message: failure.localizedMessage(l10n),
                    details: failure.technicalDetails,
                    onRetry: _load,
                  ),
                  SalesOrdersLoaded(:final orders) => OrdersListBody(
                    orders: orders,
                    query: _query,
                    onQueryChanged: (String v) => setState(() => _query = v),
                    onRefresh: _load,
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
