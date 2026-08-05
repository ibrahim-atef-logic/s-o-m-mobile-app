import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/entities/sales_order_header_entity.dart';
import 'package:logic_retail_mobile/features/sales_orders/domain/usecases/get_my_sales_orders_usecase.dart';
import 'package:logic_retail_mobile/features/sales_orders/presentation/bloc/sales_orders_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMySalesOrdersUseCase extends Mock
    implements GetMySalesOrdersUseCase {}

void main() {
  late MockGetMySalesOrdersUseCase useCase;

  const SalesOrderHeaderEntity order = SalesOrderHeaderEntity(
    salesId: 'SO-000100',
    custAccount: 'US-001',
    salesName: 'Contoso',
    dataArea: 'usmf',
    priceGroupId: 'RETAIL',
    inventLocationId: 'WH-11',
    inventSiteId: '1',
    salesStatus: 'Backorder',
    documentStatus: 'None',
  );

  setUp(() {
    useCase = MockGetMySalesOrdersUseCase();
  });

  blocTest<SalesOrdersBloc, SalesOrdersState>(
    'loads orders successfully',
    build: () {
      when(() => useCase(company: any(named: 'company'))).thenAnswer(
        (_) async => const Right<Failure, List<SalesOrderHeaderEntity>>(
          <SalesOrderHeaderEntity>[order],
        ),
      );
      return SalesOrdersBloc(getMySalesOrdersUseCase: useCase);
    },
    act: (SalesOrdersBloc bloc) => bloc.add(const SalesOrdersRequested('usmf')),
    expect: () => <SalesOrdersState>[
      const SalesOrdersLoading(),
      const SalesOrdersLoaded(<SalesOrderHeaderEntity>[order]),
    ],
  );

  blocTest<SalesOrdersBloc, SalesOrdersState>(
    'emits failure on network error',
    build: () {
      when(() => useCase(company: any(named: 'company'))).thenAnswer(
        (_) async =>
            const Left<Failure, List<SalesOrderHeaderEntity>>(NetworkFailure()),
      );
      return SalesOrdersBloc(getMySalesOrdersUseCase: useCase);
    },
    act: (SalesOrdersBloc bloc) => bloc.add(const SalesOrdersRequested('usmf')),
    expect: () => <SalesOrdersState>[
      const SalesOrdersLoading(),
      const SalesOrdersFailure(NetworkFailure()),
    ],
  );
}
