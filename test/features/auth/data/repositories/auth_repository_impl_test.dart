import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/exceptions.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_session_store.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:logic_retail_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockRemote remote;
  late InMemoryAuthSessionStore store;
  late AuthRepositoryImpl sut;

  final AuthResponseModel complete = AuthResponseModel.fromJson(
    Fixtures.sampleLoginDataJson,
  );
  final AuthResponseModel incomplete = AuthResponseModel.fromJson(
    Fixtures.sampleLoginDataIncompleteJson,
  );

  setUp(() {
    remote = MockRemote();
    store = InMemoryAuthSessionStore();
    sut = AuthRepositoryImpl(remote: remote, store: store);
    registerFallbackValue(complete);
  });

  test('login keeps the session in memory only', () async {
    when(
      () => remote.login(
        company: any(named: 'company'),
        personnelNumber: any(named: 'personnelNumber'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => complete);

    final Either<Failure, AuthTokensEntity> result = await sut.login(
      company: Fixtures.loginCompany,
      personnelNumber: Fixtures.personnelNumber,
      password: Fixtures.password,
    );

    expect(result.isRight(), isTrue);
    expect(store.session?.user.activeWarehouse, Fixtures.warehouse);
    expect(await sut.readAccessToken(), complete.accessToken);
  });

  test(
    'refresh without a live session fails instead of reviving one',
    () async {
      final Either<Failure, AuthTokensEntity> result = await sut.refresh();

      expect(result.getLeft().toNullable(), isA<AuthFailure>());
      verifyNever(() => remote.refresh(any()));
    },
  );

  test('refresh renews the token of a live session', () async {
    store.save(incomplete);
    when(() => remote.refresh(any())).thenAnswer((_) async => complete);

    final Either<Failure, AuthTokensEntity> result = await sut.refresh();

    final UserSessionEntity? user = result.toNullable()?.user;
    expect(user?.activeCompany, 'mm');
    expect(user?.activeWarehouse, Fixtures.warehouse);
    verify(() => remote.refresh(incomplete.refreshToken)).called(1);
  });

  test(
    'refresh keeps the locally picked warehouse when the API omits it',
    () async {
      store.save(
        incomplete.copyWith(
          user: UserSessionModel.fromEntity(
            incomplete.user.toEntity().copyWith(
              activeWarehouse: 'MMS021ST',
              inventLocation: 'MMS021ST',
              inventLocationDataAreaId: 'PLTR',
              needsWarehouseSelection: false,
            ),
          ),
        ),
      );
      when(() => remote.refresh(any())).thenAnswer((_) async => incomplete);

      final Either<Failure, AuthTokensEntity> result = await sut.refresh();

      final UserSessionEntity? user = result.toNullable()?.user;
      expect(user?.resolvedWarehouse, 'MMS021ST');
      expect(user?.warehouseMissing, isFalse);
    },
  );

  test('logout drops the in-memory session even when the API fails', () async {
    store.save(complete);
    when(() => remote.logout(any())).thenThrow(const NetworkException());

    await sut.logout();

    expect(store.session, isNull);
  });

  test('persistWarehouse writes the pick into the live session', () async {
    store.save(incomplete);

    final Either<Failure, UserSessionEntity> result = await sut
        .persistWarehouse(inventLocationId: ' MMS021ST ', dataAreaId: 'PLTR');

    final UserSessionEntity? updated = result.toNullable();
    expect(updated?.activeWarehouse, 'MMS021ST');
    expect(updated?.inventLocation, 'MMS021ST');
    expect(updated?.inventLocationDataAreaId, 'PLTR');
    expect(updated?.needsWarehouseSelection, isFalse);
    expect(updated?.warehouseMissing, isFalse);
    expect(store.session?.user.activeWarehouse, 'MMS021ST');
    expect(store.session?.accessToken, incomplete.accessToken);
  });

  test('persistWarehouse rejects an empty warehouse code', () async {
    store.save(incomplete);

    final Either<Failure, UserSessionEntity> result = await sut
        .persistWarehouse(inventLocationId: '  ');

    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    expect(store.session?.user.activeWarehouse, isNot('  '));
  });
}
