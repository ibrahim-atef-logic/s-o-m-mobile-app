import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/widgets/ltr_text.dart';

void main() {
  testWidgets('LtrText forces LTR so .|022 is not visually reversed in RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: LtrText('.|022'))),
        ),
      ),
    );

    expect(find.text('.|022'), findsOneWidget);
    final Directionality inner = tester.widget<Directionality>(
      find.descendant(
        of: find.byType(LtrText),
        matching: find.byType(Directionality),
      ),
    );
    expect(inner.textDirection, TextDirection.ltr);
  });
}
