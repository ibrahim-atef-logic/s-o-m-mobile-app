import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/hello_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/failed_lines/presentation/pages/failed_lines_page.dart';
import '../../features/full_add/presentation/bloc/full_add_bloc.dart';
import '../../features/full_add/presentation/pages/full_add_cart_page.dart';
import '../../features/full_add/presentation/pages/full_add_scan_page.dart';
import '../../features/quick_add/presentation/bloc/quick_add_bloc.dart';
import '../../features/quick_add/presentation/pages/quick_add_cart_page.dart';
import '../../features/quick_add/presentation/pages/quick_add_scan_page.dart';
import '../../features/sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../features/sales_orders/presentation/bloc/sales_orders_bloc.dart';
import '../../features/sales_orders/presentation/pages/my_sales_orders_page.dart';
import '../../features/sales_orders/presentation/pages/sales_order_details_page.dart';
import '../../features/so_lines/presentation/pages/so_lines_page.dart';
import '../../l10n/app_localizations.dart';
import '../di/injection.dart';
import '../widgets/states/app_empty_view.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/hello',
    refreshListenable: GoRouterAuthRefresh(authBloc),
    redirect: (BuildContext context, GoRouterState state) {
      final AuthState authState = authBloc.state;
      final String loc = state.matchedLocation;
      final bool onAuth = loc == '/hello' || loc == '/login';

      if (authState is AuthLoading || authState is AuthInitial) {
        return null;
      }
      if (authState is AuthUnauthenticated || authState is AuthFailureState) {
        return onAuth ? null : '/hello';
      }
      if (authState is AuthAuthenticated) {
        if (onAuth || loc == '/company') {
          return '/orders';
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/hello',
        builder: (BuildContext context, GoRouterState state) {
          return const HelloPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<SalesOrdersBloc>(
            create: (_) => sl<SalesOrdersBloc>(),
            child: const MySalesOrdersPage(),
          );
        },
      ),
      GoRoute(
        path: '/orders/:salesId',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! SalesOrderHeaderEntity) {
            return _MissingScaffold(messageKey: _MissingKind.order);
          }
          return SalesOrderDetailsPage(order: extra);
        },
      ),
      GoRoute(
        path: '/orders/:salesId/lines',
        builder: (BuildContext context, GoRouterState state) {
          final String salesId = state.pathParameters['salesId'] ?? '';
          final String company = state.uri.queryParameters['company'] ?? '';
          return SoLinesPage(salesId: salesId, company: company);
        },
      ),
      GoRoute(
        path: '/orders/:salesId/full-add',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! SalesOrderHeaderEntity) {
            return _MissingScaffold(messageKey: _MissingKind.order);
          }
          return BlocProvider<FullAddBloc>(
            create: (_) => sl<FullAddBloc>(param1: extra),
            child: const FullAddCartPage(),
          );
        },
      ),
      GoRoute(
        path: '/orders/:salesId/full-add/scan',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! FullAddBloc) {
            return _MissingScaffold(messageKey: _MissingKind.session);
          }
          return BlocProvider<FullAddBloc>.value(
            value: extra,
            child: const FullAddScanPage(),
          );
        },
      ),
      GoRoute(
        path: '/orders/:salesId/quick-add',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! SalesOrderHeaderEntity) {
            return _MissingScaffold(messageKey: _MissingKind.order);
          }
          return BlocProvider<QuickAddBloc>(
            create: (_) => sl<QuickAddBloc>(param1: extra),
            child: const QuickAddCartPage(),
          );
        },
      ),
      GoRoute(
        path: '/orders/:salesId/quick-add/scan',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! QuickAddBloc) {
            return _MissingScaffold(messageKey: _MissingKind.session);
          }
          return BlocProvider<QuickAddBloc>.value(
            value: extra,
            child: const QuickAddScanPage(),
          );
        },
      ),
      GoRoute(
        path: '/orders/:salesId/failed-lines',
        builder: (BuildContext context, GoRouterState state) {
          final String salesId = state.pathParameters['salesId'] ?? '';
          final String company = state.uri.queryParameters['company'] ?? '';
          final String? mode = state.uri.queryParameters['mode'];
          return FailedLinesPage(
            salesId: salesId,
            company: company,
            mode: mode,
          );
        },
      ),
    ],
  );
}

enum _MissingKind { order, session }

class _MissingScaffold extends StatelessWidget {
  const _MissingScaffold({required this.messageKey});

  final _MissingKind messageKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String message = switch (messageKey) {
      _MissingKind.order => l10n.errorMissingOrder,
      _MissingKind.session => l10n.errorMissingSession,
    };
    return Scaffold(
      body: AppEmptyView(title: message, icon: Icons.warning_amber_outlined),
    );
  }
}

class GoRouterAuthRefresh extends ChangeNotifier {
  GoRouterAuthRefresh(AuthBloc bloc) {
    _sub = bloc.stream.listen((AuthState _) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
