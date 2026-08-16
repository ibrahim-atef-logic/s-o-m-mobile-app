import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logic_retail_mobile/core/error/exceptions.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:logic_retail_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:logic_retail_mobile/features/auth/domain/entities/user_session_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockLocal extends Mock implements AuthLocalDataSource {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late AuthRepositoryImpl sut;

  final AuthResponseModel complete =
      AuthResponseModel.fromJson(Fixtures.sampleLoginDataJson);
  final AuthResponseModel incomplete =
      AuthResponseModel.fromJson(Fixtures.sampleLoginDataIncompleteJson);

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    sut = AuthRepositoryImpl(remote: remote, local: local);
    registerFallbackValue(complete);
  });

  test('restoreSession refreshes and replaces cached user', () async {
    when(local.readSession).thenAnswer((_) async => incomplete);
    when(local.readRefreshToken).thenAnswer((_) async => 'refresh-token-12344');
    when(() => remote.refresh(any())).thenAnswer((_) async => complete);
    when(() => local.saveSession(any())).thenAnswer((_) async {});

    final Either<Failure, UserSessionEntity?> result = await sut.restoreSession();
    expect(result.isRight(), isTrue);
    final UserSessionEntity? user = result.getOrElse((_) => null);
    expect(user?.activeCompany, 'mm');
    expect(user?.activeWarehouse, 'MMS000WH');
    verify(() => local.saveSession(any())).called(1);
  });

  test('restoreSession clears cache when refresh is unauthorized', () async {
    when(local.readSession).thenAnswer((_) async => complete);
    when(local.readRefreshToken).thenAnswer((_) async => 'dead');
    when(() => remote.refresh(any())).thenThrow(const AuthException());
    when(local.clear).thenAnswer((_) async {});

    final Either<Failure, UserSessionEntity?> result = await sut.restoreSession();
    expect(result, const Right<Failure, UserSessionEntity?>(null));
    verify(local.clear).called(1);
  });
}
