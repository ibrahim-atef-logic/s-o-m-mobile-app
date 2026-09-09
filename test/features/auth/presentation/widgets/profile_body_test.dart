import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/auth/data/models/user_session_model.dart';
import 'package:logic_retail_mobile/features/auth/presentation/widgets/profile_body.dart';
import 'package:logic_retail_mobile/l10n/app_localizations.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_app.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required dynamic session,
    Locale locale = const Locale('ar'),
  }) async {
    await pumpTestApp(
      tester,
      locale: locale,
      home: Builder(
        builder: (BuildContext context) {
          return ProfileBody(
            session: session,
            l10n: AppLocalizations.of(context),
          );
        },
      ),
    );
  }

  testWidgets('ProfileBody shows display names not raw company code', (
    WidgetTester tester,
  ) async {
    final session = UserSessionModel.fromJson(
      Fixtures.sampleActivationUser1006,
    ).toEntity();

    await pumpProfile(tester, session: session);

    expect(find.text('محمد عفيف'), findsOneWidget);
    expect(find.text('1006'), findsOneWidget);
    expect(find.text('تجزئة هايبر ماركت'), findsOneWidget);
    expect(find.text('MMS000WH'), findsOneWidget);
    expect(find.text('سلة المواد الغذائية المخفضة'), findsOneWidget);
    expect(find.text('SAR'), findsOneWidget);
    expect(find.text('mm'), findsNothing);
  });

  testWidgets('ProfileBody hides warehouse row for user 12344', (
    WidgetTester tester,
  ) async {
    final session = UserSessionModel.fromJson(
      Fixtures.sampleActivationUser12344,
    ).toEntity();

    await pumpProfile(tester, session: session);

    expect(find.text('المستودع'), findsNothing);
    expect(find.text('PLTR'), findsOneWidget);
    expect(find.text('سلة المواد الغذائية المخفضة'), findsNothing);
    expect(find.text('SAR'), findsNothing);
  });
}
