import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../features/auth/data/datasources/auth_session_store.dart';
import '../../features/auth/domain/entities/auth_tokens_entity.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../auth/auth_session_controller.dart';
import '../error/failures.dart';
import '../network/auth_interceptor.dart';
import '../network/error_interceptor.dart';
import 'injection.dart';

/// Attaches auth refresh + error mapping (+ debug logger) to [dio].
void attachDioInterceptors(Dio dio) {
  dio.interceptors.addAll(<Interceptor>[
    AuthInterceptor(
      tokenReader: () async => sl<AuthSessionStore>().accessToken,
      onRefresh: () async {
        final Either<Failure, AuthTokensEntity> result =
            await sl<AuthRepository>().refresh();
        return result.isRight();
      },
      onRefreshFailed: () {
        sl<AuthSessionStore>().clear();
        sl<AuthSessionController>().notifyExpired();
      },
      dio: dio,
    ),
    // Logger before ErrorInterceptor: the latter rejects the chain.
    if (kDebugMode) PrettyDioLogger(requestBody: true, responseBody: true),
    ErrorInterceptor(),
  ]);
}
