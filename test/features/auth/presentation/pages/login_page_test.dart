import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/core/locale/locale_cubit.dart';
import 'package:logic_retail_mobile/core/locale/locale_repository.dart';
import 'package:logic_retail_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:logic_retail_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_app.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc authBloc;
  late StreamController<AuthState> states;
  late LocaleCubit localeCubit;

  setUpAll(() {
    registerFallbackValue(
      const AuthLoginSubmitted(
        company: 'x',
        personnelNumber: '1',
        password: 'p',
      ),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    localeCubit = LocaleCubit(LocaleRepository(prefs));
    authBloc = MockAuthBloc();
    states = StreamController<AuthState>.broadcast();
    when(() => authBloc.state).thenReturn(const AuthUnauthenticated());
    when(() => authBloc.stream).thenAnswer((_) => states.stream);
    when(() => authBloc.add(any())).thenReturn(null);
    when(authBloc.close).thenAnswer((_) async {});
  });

  tearDown(() async {
    await localeCubit.close();
    await states.close();
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
      ],
      home: const LoginPage(),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders branded welcome copy', (WidgetTester tester) async {
    await pumpLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(
      find.text('Encrypted connection · credentials stay on this device'),
      findsOneWidget,
    );
  });

  testWidgets('empty submit shows validation messages', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Environment code is required'), findsOneWidget);
    expect(find.text('Personnel number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('filled form dispatches AuthLoginSubmitted', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'logic-trial');
    await tester.enterText(fields.at(1), '1006');
    await tester.enterText(fields.at(2), '123');
    await tester.tap(find.text('Login'));
    await tester.pump();

    verify(
      () => authBloc.add(
        const AuthLoginSubmitted(
          company: 'logic-trial',
          personnelNumber: '1006',
          password: '123',
        ),
      ),
    ).called(1);
  });

  testWidgets('accepts string personnel number like m.afif', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'logic-trial');
    await tester.enterText(fields.at(1), 'm.afif');
    await tester.enterText(fields.at(2), '123');
    await tester.tap(find.text('Login'));
    await tester.pump();

    verify(
      () => authBloc.add(
        const AuthLoginSubmitted(
          company: 'logic-trial',
          personnelNumber: 'm.afif',
          password: '123',
        ),
      ),
    ).called(1);
  });

  testWidgets('AuthFailureState shows snackbar', (WidgetTester tester) async {
    await pumpLogin(tester);

    when(() => authBloc.state).thenReturn(
      const AuthFailureState(AuthFailure('AUTH_FAILED: bad password')),
    );
    states.add(
      const AuthFailureState(AuthFailure('AUTH_FAILED: bad password')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
