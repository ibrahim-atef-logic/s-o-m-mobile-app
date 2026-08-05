import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/widgets/primary_button.dart';
import 'package:logic_retail_mobile/core/widgets/skeletons/order_card_skeleton.dart';
import 'package:logic_retail_mobile/core/widgets/states/app_empty_view.dart';
import 'package:logic_retail_mobile/core/widgets/states/app_error_view.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('PrimaryButton shows spinner when loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(PrimaryButton(label: 'Go', isLoading: true, onPressed: () {})),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Go'), findsNothing);
  });

  testWidgets('AppEmptyView renders title and action', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      _wrap(
        AppEmptyView(
          title: 'Nothing here',
          actionLabel: 'Retry',
          onAction: () => tapped = true,
        ),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(tapped, isTrue);
  });

  testWidgets('AppErrorView retry callback fires', (WidgetTester tester) async {
    bool retried = false;
    await tester.pumpWidget(
      _wrap(
        AppErrorView(
          title: 'Failed',
          details: 'tech detail',
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('OrderCardSkeleton renders without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(const OrderCardSkeleton()));
    expect(tester.takeException(), isNull);
    expect(find.byType(OrderCardSkeleton), findsOneWidget);
  });
}
