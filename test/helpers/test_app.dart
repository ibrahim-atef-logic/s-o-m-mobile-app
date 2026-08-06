import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';

/// Pumps a [MaterialApp] with app localizations and optional [BlocProvider]s.
Future<void> pumpTestApp(
  WidgetTester tester, {
  required Widget home,
  List<BlocProvider<dynamic>> providers = const <BlocProvider<dynamic>>[],
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  Widget child = home;
  if (providers.isNotEmpty) {
    child = MultiBlocProvider(providers: providers, child: home);
  }

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
