import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/core/l10n/failure_l10n.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';

void main() {
  Future<AppLocalizations> pumpL10n(WidgetTester tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return l10n;
  }

  testWidgets('FailureL10n maps sealed subtypes', (WidgetTester tester) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    expect(const NetworkFailure().localizedTitle(l10n), l10n.errorNetwork);
    expect(const AuthFailure().localizedTitle(l10n), l10n.errorAuth);
    expect(
      const ValidationFailure().localizedTitle(l10n),
      l10n.errorValidation,
    );
    expect(const CacheFailure().localizedTitle(l10n), l10n.errorCache);
    expect(const ServerFailure().localizedTitle(l10n), l10n.errorServer);
    expect(
      const ServerFailure(
        'Dynamics environment is unavailable (503)',
      ).localizedTitle(l10n),
      l10n.errorDynamicsUnavailable,
    );
  });

  testWidgets('snackBarMessage surfaces API auth and server details', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    expect(
      const AuthFailure(
        'Invalid company, personnel number or password',
      ).snackBarMessage(l10n),
      contains('Invalid company'),
    );
    expect(
      const ServerFailure('Barcode not found').snackBarMessage(l10n),
      contains('Barcode not found'),
    );
    expect(
      const NetworkFailure().snackBarMessage(l10n),
      l10n.errorNetwork,
    );
  });
}
