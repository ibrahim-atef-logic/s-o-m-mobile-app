import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:logic_retail_mobile/features/auth/presentation/cubit/change_password_cubit.dart';
import 'package:logic_retail_mobile/features/auth/presentation/pages/change_password_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_app.dart';

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockChangePasswordUseCase useCase;

  setUp(() {
    useCase = MockChangePasswordUseCase();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ChangePasswordCubit>(
          create: (_) => ChangePasswordCubit(useCase),
        ),
      ],
      home: const ChangePasswordPage(),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('validates empty, mismatch, and same-as-old locally', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Password is required'), findsNWidgets(3));
    verifyNever(
      () => useCase(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    );

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '123');
    await tester.enterText(fields.at(1), '123');
    await tester.enterText(fields.at(2), '123');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('New password must be different from the current one'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(1), '456');
    await tester.enterText(fields.at(2), '789');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('New password and confirmation do not match'),
      findsOneWidget,
    );
    verifyNever(
      () => useCase(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
        confirmPassword: any(named: 'confirmPassword'),
      ),
    );
  });
}
