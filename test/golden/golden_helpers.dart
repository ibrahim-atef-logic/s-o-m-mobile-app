import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:logic_retail_mobile/core/theme/app_theme.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';

/// Shared sizes used by golden tests.
const Size kPhoneSmall = Size(360, 800);
const Size kPhoneLarge = Size(412, 915);

Future<void> loadAppFontsForGoldens() async {
  await loadAppFonts();
}

Widget wrapGolden({required Widget child, Locale locale = const Locale('en')}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    locale: locale,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

Future<void> pumpGoldenScreen(
  WidgetTester tester, {
  required Widget child,
  required String name,
  Locale locale = const Locale('en'),
  Size size = kPhoneSmall,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidgetBuilder(
    child,
    wrapper: (Widget w) => wrapGolden(child: w, locale: locale),
    surfaceSize: size,
  );
  await tester.pumpAndSettle();
  await screenMatchesGolden(tester, name);
}
