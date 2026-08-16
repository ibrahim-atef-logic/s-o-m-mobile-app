import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';
import '../models/company_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

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
      await _local.saveSession(model);
      return Right<Failure, AuthTokensEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, AuthTokensEntity>(_map(e));
    }
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> refresh() async {
    try {
      final AuthResponseModel? cached = await _local.readSession();
      final AuthResponseModel model = await _refreshAndCache(
        fallbackUser: cached?.user,
      );
      return Right<Failure, AuthTokensEntity>(model.toEntity());
    } catch (e) {
      return Left<Failure, AuthTokensEntity>(_map(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final String? refreshToken = await _local.readRefreshToken();
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
    } on Exception {
      // Always wipe local session, even if the network call fails.
    }
    await _local.clear();
    return const Right<Failure, void>(null);
  }

  @override
  Future<Either<Failure, UserSessionEntity?>> restoreSession() async {
    try {
      final AuthResponseModel? cached = await _local.readSession();
      if (cached == null) {
        return const Right<Failure, UserSessionEntity?>(null);
      }
      try {
        final AuthResponseModel refreshed = await _refreshAndCache(
          fallbackUser: cached.user,
        );
        return Right<Failure, UserSessionEntity?>(refreshed.user.toEntity());
      } on AuthException {
        await _local.clear();
        return const Right<Failure, UserSessionEntity?>(null);
      } on NetworkException {
        return Right<Failure, UserSessionEntity?>(cached.user.toEntity());
      } on ServerException catch (e) {
        if (e.statusCode == 401) {
          await _local.clear();
          return const Right<Failure, UserSessionEntity?>(null);
        }
        return Right<Failure, UserSessionEntity?>(cached.user.toEntity());
      }
    } on CacheException {
      return const Left<Failure, UserSessionEntity?>(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserSessionEntity>> fetchMe() async {
    try {
      final UserSessionModel me = await _remote.me();
      final AuthResponseModel? cached = await _local.readSession();
      if (cached != null) {
        await _local.saveSession(cached.copyWith(user: me));
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
    try {
      final AuthResponseModel? session = await _local.readSession();
      if (session == null) {
        return const Left<Failure, void>(AuthFailure());
      }
      final CompanyModel company = session.user.companies.firstWhere(
        (CompanyModel c) => c.code == companyCode,
      );
      await _local.saveSelectedCompany(company);
      return const Right<Failure, void>(null);
    } on StateError {
      return const Left<Failure, void>(ValidationFailure('Company not found'));
    } on CacheException {
      return const Left<Failure, void>(CacheFailure());
    }
  }

  @override
  Future<String?> readAccessToken() => _local.readAccessToken();

  Future<AuthResponseModel> _refreshAndCache({
    UserSessionModel? fallbackUser,
  }) async {
    final String? refreshToken = await _local.readRefreshToken();
    if (refreshToken == null) {
      throw const AuthException();
    }
    AuthResponseModel model = await _remote.refresh(refreshToken);
    if (model.user.personnelNumber.isEmpty && fallbackUser != null) {
      model = model.copyWith(user: fallbackUser);
    }
    await _local.saveSession(model);
    return model;
  }

  Failure _map(Object error) {
    if (error is AuthException) {
      return AuthFailure(error.message);
    }
    if (error is NetworkException) {
      return const NetworkFailure();
    }
    if (error is CacheException) {
      return const CacheFailure();
    }
    if (error is ServerException) {
      return ServerFailure(error.message);
    }
    return const ServerFailure();
  }
}
