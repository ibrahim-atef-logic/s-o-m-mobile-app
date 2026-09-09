import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/theme/app_dimensions.dart';
import 'package:logic_retail_mobile/core/theme/app_theme.dart';
import 'package:logic_retail_mobile/core/widgets/app_list_tile.dart';
import 'package:logic_retail_mobile/core/widgets/app_validation_text.dart';
import 'package:logic_retail_mobile/core/widgets/directional_chevron.dart';
import 'package:logic_retail_mobile/core/widgets/sticky_action_bar.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: child),
    );
  }

  group('DirectionalChevron', () {
    testWidgets('renders chevron in LTR and RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DirectionalChevron(),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: DirectionalChevron(),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(
        tester.widget<DirectionalChevron>(find.byType(DirectionalChevron)).size,
        AppDimensions.iconSm,
      );
    });
  });

  group('AppValidationText', () {
    testWidgets('renders nothing for null', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const AppValidationText(null)));
      expect(find.byType(Text), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders nothing for empty', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const AppValidationText('')));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows message when present', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const AppValidationText('Required')));
      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('AppListTile', () {
    testWidgets('honors 48dp min touch target', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(AppListTile(title: 'Row', dense: true, onTap: () {})),
      );
      final Size size = tester.getSize(find.byType(AppListTile));
      expect(size.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
    });
  });

  group('StickyActionBar.summary', () {
    testWidgets('renders summary without primary button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const StickyActionBar.summary(
            summary: '3 lines',
            secondarySummary: 'Total: 10.00',
          ),
        ),
      );
      expect(find.text('3 lines'), findsOneWidget);
      expect(find.text('Total: 10.00'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
