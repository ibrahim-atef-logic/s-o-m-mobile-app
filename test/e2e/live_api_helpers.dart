import 'package:dio/dio.dart';

import '../helpers/fixtures.dart';

/// Live API helpers for tagged e2e tests.
class LiveApiClient {
  LiveApiClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue: Fixtures.e2eBaseUrl,
                ),
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: <String, Object?>{'Content-Type': 'application/json'},
                validateStatus: (_) => true,
              ),
            );

  final Dio dio;

  String? accessToken;

  static String get company => const String.fromEnvironment(
        'E2E_COMPANY',
        defaultValue: Fixtures.loginCompany,
      );

  static String get personnel => const String.fromEnvironment(
        'E2E_PERSONNEL',
        defaultValue: Fixtures.personnelNumber,
      );

  static String get password => const String.fromEnvironment(
        'E2E_PASSWORD',
        defaultValue: Fixtures.password,
      );

  static String get legalEntity => const String.fromEnvironment(
        'E2E_LEGAL_ENTITY',
        defaultValue: Fixtures.legalEntity,
      );

  static bool get enableWrite =>
      const String.fromEnvironment('ENABLE_WRITE_E2E', defaultValue: 'false') ==
      'true';

  Map<String, String> authHeader() {
    final String? token = accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('loginOnce() must succeed before authHeader()');
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  Future<Response<dynamic>> loginOnce({
    String? companyOverride,
    String? personnelOverride,
    String? passwordOverride,
  }) async {
    final Response<dynamic> response = await dio.post<dynamic>(
      '/api/v1/auth/login',
      data: <String, String>{
        'company': companyOverride ?? company,
        'personnelNumber': personnelOverride ?? personnel,
        'password': passwordOverride ?? password,
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      accessToken = data['accessToken'] as String?;
    }
    return response;
  }
}
