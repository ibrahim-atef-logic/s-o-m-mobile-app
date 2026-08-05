import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/skeletons/order_card_skeleton.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/sales_order_header_entity.dart';
import '../bloc/sales_orders_bloc.dart';

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
    if (auth is AuthAuthenticated && auth.session.selectedCompany != null) {
      _companyCode = auth.session.selectedCompany!.code;
      context.read<SalesOrdersBloc>().add(SalesOrdersRequested(_companyCode!));
      return;
    }
    _companyCode = null;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mySalesOrders),
        actions: <Widget>[
          const LanguageSwitcher(compact: true),
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
      body: BlocBuilder<SalesOrdersBloc, SalesOrdersState>(
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
            SalesOrdersLoaded(:final orders) => _buildLoaded(l10n, orders),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(
    AppLocalizations l10n,
    List<SalesOrderHeaderEntity> orders,
  ) {
    if (orders.isEmpty) {
      return AppEmptyView(
        title: l10n.noOrders,
        icon: Icons.receipt_long_outlined,
        actionLabel: l10n.refresh,
        onAction: _load,
      );
    }
    final List<SalesOrderHeaderEntity> filtered = orders.where((o) {
      if (_query.isEmpty) return true;
      final String q = _query.toLowerCase();
      return o.salesId.toLowerCase().contains(q) ||
          o.salesName.toLowerCase().contains(q) ||
          o.custAccount.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceMd,
            AppDimensions.spaceMd,
            AppDimensions.spaceMd,
            AppDimensions.spaceSm,
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchOrders,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (String v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.ordersCount(filtered.length),
              style: AppTextStyles.bodySm,
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? AppEmptyView(title: l10n.noOrdersMatchSearch)
              : RefreshIndicator(
                  onRefresh: () async => _load(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    itemCount: filtered.length,
                    itemBuilder: (BuildContext context, int index) {
                      final SalesOrderHeaderEntity order = filtered[index];
                      return AppCard(
                        onTap: () => context.push(
                          '/orders/${order.salesId}',
                          extra: order,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    order.salesId,
                                    style: AppTextStyles.titleLg,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                            if (order.salesName.isNotEmpty) ...<Widget>[
                              const SizedBox(height: AppDimensions.spaceXs),
                              Text(
                                order.salesName,
                                style: AppTextStyles.bodySm,
                              ),
                            ],
                            const SizedBox(height: AppDimensions.space12),
                            Wrap(
                              spacing: AppDimensions.spaceSm,
                              runSpacing: AppDimensions.spaceSm,
                              children: <Widget>[
                                StatusChip.info(label: order.custAccount),
                                if (order.inventLocationId.isNotEmpty)
                                  StatusChip.neutral(
                                    label: order.inventLocationId,
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
      ],
    );
  }
}
