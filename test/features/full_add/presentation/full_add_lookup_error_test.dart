import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/bloc/full_add_bloc.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/full_add_lookup_error.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';

import '../../../helpers/fixtures.dart';

void main() {
  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: Fixtures.salesId,
    custAccount: Fixtures.custAccount,
    salesName: 'Trial Customer',
    dataArea: Fixtures.legalEntity,
    priceGroupId: 'RETAIL',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MM',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  Future<AppLocalizations> pumpL10n(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
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

  testWidgets('maps barcode and item 404 to Item not found', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    expect(
      fullAddLookupErrorMessage(
        l10n: l10n,
        state: const FullAddState(
          order: order,
          barcode: Fixtures.unknownBarcode,
          failure: ServerFailure('BARCODE_NOT_FOUND: Barcode not found'),
        ),
      ),
      l10n.errorItemNotFound,
    );
    expect(
      fullAddLookupErrorMessage(
        l10n: l10n,
        state: const FullAddState(
          order: order,
          barcode: 'NOPE',
          lookupByItem: true,
          failure: ServerFailure('ITEM_NOT_FOUND: Item not found'),
        ),
      ),
      l10n.errorItemNotFound,
    );
  });

  testWidgets('maps FORBIDDEN_COMPANY and barcode required', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    expect(
      fullAddLookupErrorMessage(
        l10n: l10n,
        state: const FullAddState(
          order: order,
          barcode: Fixtures.barcode,
          failure: ServerFailure(
            'FORBIDDEN_COMPANY: Company not allowed for token',
          ),
        ),
      ),
      l10n.errorForbiddenCompany,
    );
    expect(
      fullAddLookupErrorMessage(
        l10n: l10n,
        state: const FullAddState(
          order: order,
          validation: FullAddValidation.barcodeRequired,
        ),
      ),
      l10n.errorBarcodeRequired,
    );
  });

  testWidgets('hides the error while lookup is in flight', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n = await pumpL10n(tester);

    expect(
      fullAddLookupErrorMessage(
        l10n: l10n,
        state: const FullAddState(
          order: order,
          barcode: Fixtures.unknownBarcode,
          lookingUp: true,
          failure: ServerFailure('BARCODE_NOT_FOUND: Barcode not found'),
        ),
      ),
      isNull,
    );
  });
}
