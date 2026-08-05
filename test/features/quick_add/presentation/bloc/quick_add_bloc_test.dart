import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_item_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/entities/line_submit_result_entity.dart';
import 'package:logic_retail_mobile/features/catalog/domain/usecases/submit_quick_batch_usecase.dart';
import 'package:logic_retail_mobile/features/quick_add/domain/entities/quick_cart_line_entity.dart';
import 'package:logic_retail_mobile/features/quick_add/presentation/bloc/quick_add_bloc.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockSubmitQuickBatchUseCase extends Mock
    implements SubmitQuickBatchUseCase {}

void main() {
  late MockSubmitQuickBatchUseCase submit;

  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: 'SO-000101',
    custAccount: 'US-001',
    salesName: 'Contoso',
    dataArea: 'usmf',
    priceGroupId: 'RETAIL',
    inventLocationId: 'WH-11',
    inventSiteId: '1',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  QuickAddBloc buildBloc() =>
      QuickAddBloc(order: order, submitQuickBatchUseCase: submit);

  setUp(() {
    submit = MockSubmitQuickBatchUseCase();
  });

  blocTest<QuickAddBloc, QuickAddState>(
    'adds line locally on valid input',
    build: buildBloc,
    act: (QuickAddBloc bloc) {
      bloc.add(const QuickAddBarcodeChanged('6281001000003'));
      bloc.add(const QuickAddQuantityChanged('2'));
      bloc.add(const QuickAddLineAdded());
    },
    expect: () => <QuickAddState>[
      const QuickAddState(order: order, barcode: '6281001000003'),
      const QuickAddState(
        order: order,
        barcode: '6281001000003',
        quantityText: '2',
      ),
      const QuickAddState(
        order: order,
        lines: <QuickCartLineEntity>[
          QuickCartLineEntity(barcode: '6281001000003', quantity: 2),
        ],
        lineAdded: true,
      ),
    ],
  );

  blocTest<QuickAddBloc, QuickAddState>(
    'rejects invalid quantity when adding line',
    build: buildBloc,
    seed: () => const QuickAddState(
      order: order,
      barcode: '6281001000003',
      quantityText: '0',
    ),
    act: (QuickAddBloc bloc) => bloc.add(const QuickAddLineAdded()),
    expect: () => <QuickAddState>[
      const QuickAddState(
        order: order,
        barcode: '6281001000003',
        quantityText: '0',
        validation: QuickAddValidation.qtyInvalid,
      ),
    ],
  );

  blocTest<QuickAddBloc, QuickAddState>(
    'submit batch success clears cart',
    build: () {
      when(
        () => submit(
          salesId: any(named: 'salesId'),
          company: any(named: 'company'),
          lines: any(named: 'lines'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, LineSubmitResultEntity>(
          LineSubmitResultEntity(
            success: true,
            items: <LineItemResultEntity>[
              LineItemResultEntity(
                id: '1',
                barcode: '6281001000003',
                quantity: 2,
                status: 'synced',
              ),
            ],
          ),
        ),
      );
      return buildBloc();
    },
    seed: () => const QuickAddState(
      order: order,
      lines: <QuickCartLineEntity>[
        QuickCartLineEntity(barcode: '6281001000003', quantity: 2),
      ],
    ),
    act: (QuickAddBloc bloc) => bloc.add(const QuickAddSubmitRequested()),
    expect: () => <Matcher>[
      isA<QuickAddState>().having(
        (QuickAddState s) => s.submitting,
        'sub',
        true,
      ),
      isA<QuickAddState>()
          .having((QuickAddState s) => s.lines, 'lines', isEmpty)
          .having((QuickAddState s) => s.lastResult?.success, 'ok', true),
    ],
  );
}
