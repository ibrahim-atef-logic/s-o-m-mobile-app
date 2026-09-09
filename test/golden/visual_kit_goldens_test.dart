import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:logic_retail_mobile/core/theme/app_colors.dart';
import 'package:logic_retail_mobile/core/widgets/app_action_tile.dart';
import 'package:logic_retail_mobile/core/widgets/app_card.dart';
import 'package:logic_retail_mobile/core/widgets/app_gradient_app_bar.dart';
import 'package:logic_retail_mobile/core/widgets/app_hero_header.dart';
import 'package:logic_retail_mobile/core/widgets/app_icon_badge.dart';
import 'package:logic_retail_mobile/core/widgets/app_search_field.dart';
import 'package:logic_retail_mobile/core/widgets/app_section_header.dart';
import 'package:logic_retail_mobile/core/widgets/context_row.dart';
import 'package:logic_retail_mobile/core/widgets/status_chip.dart';

import 'golden_helpers.dart';

void main() {
  setUpAll(() async {
    await loadAppFontsForGoldens();
  });

  group('visual kit goldens', () {
    testGoldens('hero header with stats en 360', (WidgetTester tester) async {
      await pumpGoldenScreen(
        tester,
        name: 'hero_header_en_360',
        size: kPhoneSmall,
        child: Scaffold(
          appBar: const AppGradientAppBar(title: Text('MM-245265')),
          body: ListView(
            padding: EdgeInsets.zero,
            children: const <Widget>[
              AppHeroHeader(
                title: 'Mira Mart Jeddah',
                subtitle: 'C-000123',
                icon: Icons.receipt_long_outlined,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: AppHeroStat(
                        label: 'Order total',
                        value: '1,250.00',
                        icon: Icons.payments_outlined,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: AppHeroStat(
                        label: 'Warehouse',
                        value: 'WH-01',
                        icon: Icons.warehouse_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppSectionHeader(title: 'Order summary'),
                    AppCard(
                      accentColor: AppColors.primary,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppIconBadge(icon: Icons.inventory_2_outlined),
                          SizedBox(width: 12),
                          Expanded(child: Text('MM-245265')),
                          StatusChip.info(label: '12 PCS'),
                        ],
                      ),
                    ),
                    AppCard(
                      child: Column(
                        children: <Widget>[
                          ContextRow(
                            icon: Icons.storefront_outlined,
                            label: 'Customer',
                            value: 'C-000123',
                          ),
                          Divider(height: 16),
                          ContextRow(
                            icon: Icons.warehouse_outlined,
                            label: 'Warehouse',
                            value: 'WH-01',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });

    testGoldens('list chrome ar 412', (WidgetTester tester) async {
      await pumpGoldenScreen(
        tester,
        name: 'list_chrome_ar_412',
        locale: const Locale('ar'),
        size: kPhoneLarge,
        child: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              AppSearchField(hintText: 'بحث', onChanged: _onQuery),
              const SizedBox(height: 16),
              AppCard(
                accentColor: AppColors.primary,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    AppIconBadge(icon: Icons.inventory_2_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('MM-245265'),
                          SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: <Widget>[
                              StatusChip.info(label: 'C-000123'),
                              StatusChip.neutral(label: 'WH-01'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppActionTile(
                title: 'تغيير كلمة المرور',
                icon: Icons.lock_reset_outlined,
                onTap: _noop,
              ),
            ],
          ),
        ),
      );
    });
  });
}

void _noop() {}

void _onQuery(String value) {}
