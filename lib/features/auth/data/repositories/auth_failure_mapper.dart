import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

/// Maps data-layer exceptions to auth failures.
Failure mapAuthError(Object error) {
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
