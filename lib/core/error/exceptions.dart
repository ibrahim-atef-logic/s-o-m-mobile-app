class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);
  final String message;
}

class AuthException implements Exception {
  const AuthException([this.message = 'Unauthorized']);
  final String message;
}
