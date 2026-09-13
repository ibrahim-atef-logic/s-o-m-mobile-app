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

  testWidgets('DYNAMICS_ERROR is not mapped as Dynamics unavailable', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    const ServerFailure conversion = ServerFailure(
      'DYNAMICS_ERROR: Conversion between PCS and حبة does not exist for product P042324.',
    );
    expect(conversion.localizedTitle(l10n), l10n.errorPriceFetchFailed);
    expect(conversion.localizedMessage(l10n), l10n.errorUnitConversion);

    const ServerFailure unavailable = ServerFailure(
      'DYNAMICS_UNAVAILABLE: Dynamics environment is unavailable (503)',
    );
    expect(unavailable.localizedTitle(l10n), l10n.errorDynamicsUnavailable);
  });

  testWidgets('a stopped customer infolog becomes a clear message', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    const ServerFailure failure = ServerFailure(
      "DYNAMICS_ERROR: Write failed for table row of type "
      "'SalesOrderHeaderV4Entity'. Infolog: Warning: Customer 10-10002 is "
      "stopped for All.",
    );
    expect(failure.localizedTitle(l10n), l10n.errorCustomerStopped);
    expect(failure.localizedMessage(l10n), l10n.errorCustomerStopped);
  });

  testWidgets('LINE_ALREADY_EXISTS is not treated as a Dynamics outage', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    const ServerFailure failure = ServerFailure(
      'LINE_ALREADY_EXISTS: Item BG410.003 is already on sales order MM-245265.',
    );
    expect(failure.localizedTitle(l10n), l10n.errorLineAlreadyExists);
    expect(failure.localizedMessage(l10n), l10n.errorLineAlreadyExists);
    expect(failure.snackBarMessage(l10n), l10n.errorLineAlreadyExists);
  });

  testWidgets('scan and delete API codes map to user messages', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    const ServerFailure barcode = ServerFailure(
      'BARCODE_NOT_FOUND: Barcode not found',
    );
    const ServerFailure item = ServerFailure(
      'ITEM_NOT_FOUND: Item not found',
    );
    const ServerFailure forbidden = ServerFailure(
      'FORBIDDEN_COMPANY: Company not allowed for token',
    );
    const ServerFailure locked = ServerFailure(
      'ORDER_NOT_EDITABLE: Order confirmed / الأمر مؤكد',
    );

    expect(barcode.localizedMessage(l10n), l10n.errorBarcodeNotFoundTryItem);
    expect(item.localizedMessage(l10n), l10n.errorItemNotFound);
    expect(item.snackBarMessage(l10n), l10n.errorItemNotFound);
    expect(forbidden.localizedMessage(l10n), l10n.errorForbiddenCompany);
    expect(forbidden.localizedTitle(l10n), l10n.errorForbiddenCompany);
    expect(
      locked.localizedMessage(l10n),
      'Order confirmed / الأمر مؤكد',
    );

    const ServerFailure closed = ServerFailure(
      'SO_NOT_OPEN: Sales order is not open',
    );
    const ServerFailure stock = ServerFailure('NO_STOCK: No available stock');
    const ServerFailure qty = ServerFailure(
      'QTY_EXCEEDS_STOCK: Quantity exceeds available sales qty',
    );
    const ValidationFailure max = ValidationFailure(
      'MAX_LINES: Quick add allows max 10 lines',
    );

    expect(closed.localizedMessage(l10n), l10n.errorSoNotOpen);
    expect(stock.localizedMessage(l10n), l10n.errorNoStock);
    expect(qty.localizedMessage(l10n), l10n.errorQtyExceeds);
    expect(max.localizedMessage(l10n), l10n.errorMaxQuickLines);
  });

  testWidgets('password change Dynamics errors map to a friendly message', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    const ServerFailure failure = ServerFailure(
      'PASSWORD_CHANGE_FAILED: Exception occurred while executing action '
      'ChangeUserPassword on Entity …',
    );
    expect(failure.localizedTitle(l10n), l10n.errorPasswordChangeFailed);
    expect(failure.localizedMessage(l10n), l10n.errorPasswordChangeFailed);
    expect(failure.snackBarMessage(l10n), l10n.errorPasswordChangeFailed);
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
    expect(const NetworkFailure().snackBarMessage(l10n), l10n.errorNetwork);
  });
}
