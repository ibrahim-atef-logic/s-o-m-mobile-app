import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/widgets/primary_button.dart';
import 'package:logic_retail_mobile/core/widgets/states/app_empty_view.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/bloc/full_add_bloc.dart';
import 'package:logic_retail_mobile/features/full_add/presentation/widgets/full_add_scan_panel.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_line_entity.dart';
import 'package:logic_retail_mobile/features/so_lines/presentation/cubit/so_lines_cubit.dart';
import 'package:logic_retail_mobile/features/so_lines/presentation/widgets/so_lines_add_fab.dart';
import 'package:logic_retail_mobile/features/so_lines/presentation/widgets/so_lines_scroll_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_app.dart';

class MockFullAddBloc extends MockBloc<FullAddEvent, FullAddState>
    implements FullAddBloc {}

void main() {
  late MockFullAddBloc fullAddBloc;

  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: Fixtures.salesId,
    custAccount: Fixtures.custAccount,
    salesName: 'Trial',
    dataArea: Fixtures.legalEntity,
    priceGroupId: 'RETAIL',
    inventLocationId: Fixtures.warehouse,
    inventSiteId: 'MM',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  setUp(() {
    fullAddBloc = MockFullAddBloc();
    const FullAddState initial = FullAddState(order: order);
    when(() => fullAddBloc.state).thenReturn(initial);
    whenListen(
      fullAddBloc,
      Stream<FullAddState>.value(initial),
      initialState: initial,
    );
  });

  Future<void> pumpScroll(
    WidgetTester tester, {
    required bool adding,
    List<SalesOrderLineEntity> lines = const <SalesOrderLineEntity>[],
  }) {
    return pumpTestApp(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FullAddBloc>.value(value: fullAddBloc),
      ],
      home: Scaffold(
        floatingActionButton: SoLinesAddFab(adding: adding, onPressed: () {}),
        body: SoLinesScrollView(
          adding: adding,
          state: SoLinesLoaded(lines),
          itemFilter: '',
          onItemFilter: (_) {},
          onEnterAdd: ({required String code, required bool byItem}) {},
          onRetry: () {},
          onRefresh: () async {},
          onDelete: (_) {},
          onLineAdded: () {},
        ),
      ),
    );
  }

  testWidgets('empty lines show copy only — no center add button', (
    WidgetTester tester,
  ) async {
    await pumpScroll(tester, adding: false);

    expect(find.text('No lines found'), findsOneWidget);
    expect(find.byType(PrimaryButton), findsNothing);
    // FAB may show Add item; body must not have a second CTA.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('empty state is hidden while adding', (
    WidgetTester tester,
  ) async {
    await pumpScroll(tester, adding: true);

    expect(find.text('No lines found'), findsNothing);
    expect(find.byType(AppEmptyView), findsNothing);
  });

  testWidgets('adding mode scroll view leaves FAB clearance at the end', (
    WidgetTester tester,
  ) async {
    await pumpScroll(tester, adding: true);

    final CustomScrollView scroll = tester.widget(find.byType(CustomScrollView));
    expect(scroll.slivers.length, greaterThanOrEqualTo(2));
    expect(find.byType(FullAddScanPanel), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('page uses one CustomScrollView', (WidgetTester tester) async {
    await pumpScroll(
      tester,
      adding: true,
      lines: const <SalesOrderLineEntity>[
        SalesOrderLineEntity(
          recordId: 1,
          salesId: 'SO-1',
          itemId: 'BG410.003',
          productName: 'Drill',
          salesQty: 2,
          salesUnit: 'pcs',
          lineNum: 1,
          dataArea: 'mm',
          unitPrice: 30,
          netAmount: 60,
        ),
      ],
    );

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.text('BG410.003'), findsWidgets);
  });

  testWidgets('browse FAB shows Add item; adding FAB is close-only', (
    WidgetTester tester,
  ) async {
    await pumpTestApp(
      tester,
      home: Scaffold(
        floatingActionButton: SoLinesAddFab(adding: false, onPressed: () {}),
        body: const SizedBox.shrink(),
      ),
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Add item'), findsOneWidget);

    await pumpTestApp(
      tester,
      home: Scaffold(
        floatingActionButton: SoLinesAddFab(adding: true, onPressed: () {}),
        body: const SizedBox.shrink(),
      ),
    );
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Add item'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
