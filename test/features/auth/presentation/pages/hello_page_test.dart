import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:logic_retail_mobile/core/locale/locale_cubit.dart';
import 'package:logic_retail_mobile/core/locale/locale_repository.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/company_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:logic_retail_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:logic_retail_mobile/features/auth/presentation/pages/hello_page.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc authBloc;
  late LocaleCubit localeCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    localeCubit = LocaleCubit(LocaleRepository(prefs));
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthUnauthenticated());
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(authBloc.close).thenAnswer((_) async {});
  });

  tearDown(() async {
    await localeCubit.close();
  });

  Future<void> pumpHello(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GoRouter router = GoRouter(
      initialLocation: '/hello',
      routes: <RouteBase>[
        GoRoute(path: '/hello', builder: (_, __) => const HelloPage()),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Scaffold(body: Text('LOGIN_PAGE')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<LocaleCubit>.value(value: localeCubit),
        ],
        child: MaterialApp.router(
          locale: const Locale('ar'),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Hello shows continue and hides logout when unauthenticated', (
    WidgetTester tester,
  ) async {
    await pumpHello(tester);

    expect(find.byType(HelloPage), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsNothing);
  });

  testWidgets('Continue navigates to login', (WidgetTester tester) async {
    await pumpHello(tester);
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN_PAGE'), findsOneWidget);
  });

  testWidgets('Hello shows logout when authenticated', (
    WidgetTester tester,
  ) async {
    when(() => authBloc.state).thenReturn(
      const AuthAuthenticated(
        UserSessionEntity(
          personnelNumber: '1006',
          workerRecId: 1,
          name: 'Trial',
          companies: <CompanyEntity>[
            CompanyEntity(
              code: 'logic-trial',
              name: 'Logic Trial',
              groupId: 'GRP-TRIAL',
            ),
          ],
        ),
      ),
    );
    await pumpHello(tester);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
  });
}
