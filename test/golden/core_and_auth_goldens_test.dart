import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:logic_retail_mobile/core/widgets/app_card.dart';
import 'package:logic_retail_mobile/core/widgets/app_validation_text.dart';
import 'package:logic_retail_mobile/core/widgets/key_value_row.dart';
import 'package:logic_retail_mobile/core/widgets/primary_button.dart';
import 'package:logic_retail_mobile/core/widgets/section_label.dart';
import 'package:logic_retail_mobile/core/widgets/states/app_empty_view.dart';
import 'package:logic_retail_mobile/core/widgets/states/app_error_view.dart';
import 'package:logic_retail_mobile/core/widgets/sticky_action_bar.dart';

import 'golden_helpers.dart';

void main() {
  setUpAll(() async {
    await loadAppFontsForGoldens();
  });

  group('design system goldens', () {
    testGoldens('AppEmptyView en 360', (WidgetTester tester) async {
      await pumpGoldenScreen(
        tester,
        name: 'empty_view_en_360',
        size: kPhoneSmall,
        child: const Scaffold(
          body: AppEmptyView(
            title: 'Nothing here',
            description: 'Try creating a new order',
            actionLabel: 'Create',
            onAction: _noop,
          ),
        ),
      );
    });

    testGoldens('AppEmptyView ar 412', (WidgetTester tester) async {
      await pumpGoldenScreen(
        tester,
        name: 'empty_view_ar_412',
        locale: const Locale('ar'),
        size: kPhoneLarge,
        child: const Scaffold(
          body: AppEmptyView(
            title: 'لا توجد أوامر',
            description: 'أنشئ أمر مبيعات جديد',
            actionLabel: 'إنشاء',
            onAction: _noop,
          ),
        ),
      );
    });

    testGoldens('AppErrorView en 360', (WidgetTester tester) async {
      await pumpGoldenScreen(
        tester,
        name: 'error_view_en_360',
        size: kPhoneSmall,
        child: const Scaffold(
          body: AppErrorView(
            title: 'Something went wrong',
            message: 'Please try again',
            onRetry: _noop,
          ),
        ),
      );
    });

    testGoldens('order summary chrome en 360', (WidgetTester tester) async {
      await pumpGoldenScreen(
        tester,
        name: 'order_summary_chrome_en_360',
        size: kPhoneSmall,
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const <Widget>[
                    SectionLabel('Order summary'),
                    AppCard(
                      child: Column(
                        children: <Widget>[
                          KeyValueRow(label: 'Customer', value: 'C-100'),
                          KeyValueRow(label: 'Warehouse', value: 'WH-01'),
                          KeyValueRow(
                            label: 'Total',
                            value: '125.00',
                            numeric: true,
                          ),
                        ],
                      ),
                    ),
                    AppValidationText('Quantity exceeds available stock'),
                    SizedBox(height: 16),
                    PrimaryButton(label: 'Continue', onPressed: _noop),
                  ],
                ),
              ),
              const StickyActionBar.summary(
                summary: '3 lines',
                secondarySummary: 'Total: 125.00',
              ),
            ],
          ),
        ),
      );
    });
  });
}

void _noop() {}
