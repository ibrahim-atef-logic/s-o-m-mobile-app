import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/locale/locale_cubit.dart';
import 'package:logic_retail_mobile/core/locale/locale_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleCubit', () {
    test('defaults to Arabic when nothing stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final LocaleCubit cubit = LocaleCubit(LocaleRepository(prefs));
      expect(cubit.state, const Locale('ar'));
      await cubit.close();
    });

    test('restores stored locale', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'locale_code': 'en',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final LocaleCubit cubit = LocaleCubit(LocaleRepository(prefs));
      expect(cubit.state, const Locale('en'));
      await cubit.close();
    });

    test('setLocale persists and emits', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final LocaleCubit cubit = LocaleCubit(LocaleRepository(prefs));
      await cubit.setLanguageCode('en');
      expect(cubit.state, const Locale('en'));
      expect(prefs.getString('locale_code'), 'en');
      await cubit.close();
    });
  });
}
