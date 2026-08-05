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
    } on AuthException catch (e) {
      return Left<Failure, AuthTokensEntity>(AuthFailure(e.message));
    } on NetworkException {
      return const Left<Failure, AuthTokensEntity>(NetworkFailure());
    } on ServerException catch (e) {
      return Left<Failure, AuthTokensEntity>(ServerFailure(e.message));
    } on CacheException {
      return const Left<Failure, AuthTokensEntity>(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> refresh() async {
    try {
      final String? refreshToken = await _local.readRefreshToken();
      if (refreshToken == null) {
        return const Left<Failure, AuthTokensEntity>(AuthFailure());
      }
      final AuthResponseModel model = await _remote.refresh(refreshToken);
      await _local.saveAccessToken(model.accessToken);
      await _local.saveSession(model);
      return Right<Failure, AuthTokensEntity>(model.toEntity());
    } on AuthException catch (e) {
      return Left<Failure, AuthTokensEntity>(AuthFailure(e.message));
    } on NetworkException {
      return const Left<Failure, AuthTokensEntity>(NetworkFailure());
    } on ServerException catch (e) {
      return Left<Failure, AuthTokensEntity>(ServerFailure(e.message));
    } on CacheException {
      return const Left<Failure, AuthTokensEntity>(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final String? refreshToken = await _local.readRefreshToken();
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
      await _local.clear();
      return const Right<Failure, void>(null);
    } on NetworkException {
      await _local.clear();
      return const Right<Failure, void>(null);
    } on Exception {
      await _local.clear();
      return const Right<Failure, void>(null);
    }
  }

  @override
  Future<Either<Failure, UserSessionEntity?>> restoreSession() async {
    try {
      final AuthResponseModel? model = await _local.readSession();
      return Right<Failure, UserSessionEntity?>(model?.user.toEntity());
    } on CacheException {
      return const Left<Failure, UserSessionEntity?>(CacheFailure());
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
}
