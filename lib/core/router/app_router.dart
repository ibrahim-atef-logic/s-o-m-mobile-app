import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cubit/change_password_cubit.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/hello_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/customers/presentation/pages/customer_picker_page.dart';
import '../../features/failed_lines/presentation/pages/failed_lines_page.dart';
import '../../features/full_add/presentation/bloc/full_add_bloc.dart';
import '../../features/full_add/presentation/pages/full_add_cart_page.dart';
import '../../features/full_add/presentation/pages/full_add_scan_page.dart';
import '../../features/quick_add/presentation/bloc/quick_add_bloc.dart';
import '../../features/quick_add/presentation/pages/quick_add_cart_page.dart';
import '../../features/quick_add/presentation/pages/quick_add_scan_page.dart';
import '../../features/sales_orders/domain/entities/sales_order_header_entity.dart';
import '../../features/sales_orders/presentation/bloc/sales_orders_bloc.dart';
import '../../features/sales_orders/presentation/pages/create_order_page.dart';
import '../../features/sales_orders/presentation/pages/my_sales_orders_page.dart';
import '../../features/sales_orders/presentation/pages/sales_order_details_page.dart';
import '../../features/so_lines/presentation/pages/so_lines_page.dart';
import '../../features/warehouses/presentation/pages/warehouse_picker_page.dart';
import '../di/injection.dart';
import 'app_router_support.dart';
import 'auth_redirect.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/hello',
    refreshListenable: GoRouterAuthRefresh(authBloc),
    redirect: (BuildContext context, GoRouterState state) {
      return resolveAuthRedirect(
        state: authBloc.state,
        location: state.matchedLocation,
      );
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
        path: '/warehouse',
        builder: (BuildContext context, GoRouterState state) {
          return WarehousePickerPage(
            isChange: state.uri.queryParameters['change'] == '1',
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfilePage();
        },
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<ChangePasswordCubit>(
            create: (_) => sl<ChangePasswordCubit>(),
            child: const ChangePasswordPage(),
          );
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
        path: '/orders/new',
        builder: (BuildContext context, GoRouterState state) {
          return const CreateOrderPage();
        },
      ),
      GoRoute(
        path: '/orders/new/customer',
        builder: (BuildContext context, GoRouterState state) {
          final String company = state.uri.queryParameters['company'] ?? '';
          final String account = state.uri.queryParameters['account'] ?? '';
          return CustomerPickerPage(
            company: company,
            selectedAccount: account.isEmpty ? null : account,
          );
        },
      ),
      GoRoute(
        path: '/orders/:salesId',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! SalesOrderHeaderEntity) {
            return const MissingRouteScaffold(kind: MissingRouteKind.order);
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
            return const MissingRouteScaffold(kind: MissingRouteKind.order);
          }
          final AuthState auth = authBloc.state;
          return BlocProvider<FullAddBloc>(
            create: (_) => sl<FullAddBloc>(
              param1: extra,
              param2: auth is AuthAuthenticated
                  ? auth.session.resolvedWarehouse
                  : null,
            ),
            child: const FullAddCartPage(),
          );
        },
      ),
      GoRoute(
        path: '/orders/:salesId/full-add/scan',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! FullAddBloc) {
            return const MissingRouteScaffold(kind: MissingRouteKind.session);
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
            return const MissingRouteScaffold(kind: MissingRouteKind.order);
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
            return const MissingRouteScaffold(kind: MissingRouteKind.session);
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
