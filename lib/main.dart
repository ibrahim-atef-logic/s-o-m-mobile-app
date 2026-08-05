import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';

import 'core/di/injection.dart';
import 'core/locale/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        Logger().e(details.exceptionAsString(), stackTrace: details.stack);
      };
      await configureDependencies();
      final AuthBloc authBloc = sl<AuthBloc>()..add(const AuthStarted());
      runApp(
        LogicRetailApp(authBloc: authBloc, localeCubit: sl<LocaleCubit>()),
      );
    },
    (Object error, StackTrace stack) {
      Logger().e('Uncaught error', error: error, stackTrace: stack);
    },
  );
}

class LogicRetailApp extends StatelessWidget {
  const LogicRetailApp({
    required this.authBloc,
    required this.localeCubit,
    super.key,
  });

  final AuthBloc authBloc;
  final LocaleCubit localeCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<LocaleCubit>.value(value: localeCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (BuildContext context, Locale locale) {
          return MaterialApp.router(
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: kDebugMode,
            theme: buildAppTheme(),
            locale: locale,
            routerConfig: createAppRouter(authBloc),
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
