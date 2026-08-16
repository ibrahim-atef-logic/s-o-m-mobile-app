import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_session_store.dart';
import '../models/auth_response_model.dart';
import '../models/company_model.dart';
import 'auth_failure_mapper.dart';
import 'session_warehouse_merge.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthSessionStore store,
  }) : _remote = remote,
       _store = store;

  final AuthRemoteDataSource _remote;
  final AuthSessionStore _store;

  @override
  Future<Either<Failure, AuthTokensEntity>> login({
    required String company,
    required String personnelNumber,
    required String password,
  }) async {
    try {
      final AuthResponseModel model = await _remote.login(
        company: company,
        personnelNumber: personnelNumber,
        password: password,
      );
      _store.save(model);
      return Right<Failure, AuthTokensEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, AuthTokensEntity>(_map(e));
    }
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> refresh() async {
    try {
      final AuthResponseModel model = await _refreshAndStore();
      return Right<Failure, AuthTokensEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, AuthTokensEntity>(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final String? refreshToken = _store.refreshToken;
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
    } on Exception {
      // Always drop the in-memory session, even if the network call fails.
    }
    _store.clear();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Either<Failure, UserSessionEntity>> fetchMe() async {
    try {
      UserSessionModel me = await _remote.me();
      final AuthResponseModel? current = _store.session;
      if (current != null) {
        me = SessionWarehouseMerge.keepLocal(me, current.user);
        _store.save(current.copyWith(user: me));
      }
      return Right<Failure, UserSessionEntity>(me.toEntity());
    } catch (e) {
      return Left<Failure, UserSessionEntity>(_map(e));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final String message = await _remote.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return Right<Failure, String>(message);
    } catch (e) {
      return Left<Failure, String>(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> persistSelectedCompany(
    String companyCode,
  ) async {
    final AuthResponseModel? session = _store.session;
    if (session == null) {
      return const Left<Failure, void>(AuthFailure());
    }
    try {
      final CompanyModel company = session.user.companies.firstWhere(
        (CompanyModel c) => c.code == companyCode,
      );
      _store.saveSelectedCompany(company);
      return const Right<Failure, void>(null);
    } on StateError {
      return const Left<Failure, void>(ValidationFailure('Company not found'));
    }
  }

  @override
  Future<Either<Failure, UserSessionEntity>> persistWarehouse({
    required String inventLocationId,
    String? dataAreaId,
  }) async {
    final String warehouse = inventLocationId.trim();
    if (warehouse.isEmpty) {
      return const Left<Failure, UserSessionEntity>(
        ValidationFailure('WAREHOUSE_REQUIRED'),
      );
    }
    final AuthResponseModel? session = _store.session;
    if (session == null) {
      return const Left<Failure, UserSessionEntity>(AuthFailure());
    }
    final UserSessionEntity updated = SessionWarehouseMerge.applyPick(
      session.user.toEntity(),
      inventLocationId: warehouse,
      dataAreaId: dataAreaId,
    );
    _store.save(session.copyWith(user: UserSessionModel.fromEntity(updated)));
    return Right<Failure, UserSessionEntity>(updated);
  }

  @override
  Future<String?> readAccessToken() async => _store.accessToken;

  /// Renews the access token inside a live session; never revives a dead one.
  Future<AuthResponseModel> _refreshAndStore() async {
    final AuthResponseModel? current = _store.session;
    final String? refreshToken = current?.refreshToken;
    if (refreshToken == null) {
      throw const AuthException();
    }
    AuthResponseModel model = await _remote.refresh(refreshToken);
    final UserSessionModel? fallbackUser = current?.user;
    if (model.user.personnelNumber.isEmpty && fallbackUser != null) {
      model = model.copyWith(user: fallbackUser);
    } else if (fallbackUser != null) {
      model = model.copyWith(
        user: SessionWarehouseMerge.keepLocal(model.user, fallbackUser),
      );
    }
    _store.save(model);
    return model;
  }

  Failure _map(Object error) => mapAuthError(error);
}
