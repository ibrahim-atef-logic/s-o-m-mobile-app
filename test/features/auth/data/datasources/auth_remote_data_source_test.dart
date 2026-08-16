import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:logic_retail_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRemoteDataSourceImpl sut;

  setUp(() {
    dio = MockDio();
    sut = AuthRemoteDataSourceImpl(dio);
  });

  test('login posts company + personnelNumber + password', () async {
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <String, dynamic>{
          'success': true,
          'data': Fixtures.sampleLoginDataJson,
        },
      ),
    );

    final AuthResponseModel result = await sut.login(
      company: Fixtures.loginCompany,
      personnelNumber: Fixtures.personnelNumber,
      password: Fixtures.password,
    );

    expect(result.user.personnelNumber, Fixtures.personnelNumber);
    verify(
      () => dio.post<dynamic>(
        '/api/v1/auth/login',
        data: <String, String>{
          'company': Fixtures.loginCompany,
          'personnelNumber': Fixtures.personnelNumber,
          'password': Fixtures.password,
        },
      ),
    ).called(1);
  });

  test('login always sends personnelNumber as a JSON string', () async {
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <String, dynamic>{
          'success': true,
          'data': Fixtures.sampleLoginDataJson,
        },
      ),
    );

    await sut.login(
      company: Fixtures.loginCompany,
      personnelNumber: 'm.afif',
      password: Fixtures.password,
    );

    final VerificationResult captured = verify(
      () => dio.post<dynamic>('/api/v1/auth/login', data: captureAny(named: 'data')),
    );
    final Map<String, String> body =
        captured.captured.single as Map<String, String>;
    expect(body['personnelNumber'], 'm.afif');
    expect(body['personnelNumber'], isA<String>());
  });

  test('me calls GET /api/v1/auth/me', () async {
    when(() => dio.get<dynamic>(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <String, dynamic>{
          'success': true,
          'data': Fixtures.sampleLoginDataJson['user'],
        },
      ),
    );

    final UserSessionModel me = await sut.me();
    expect(me.personnelNumber, Fixtures.personnelNumber);

    verify(() => dio.get<dynamic>('/api/v1/auth/me')).called(1);
  });

  test('changePassword posts old and new password only', () async {
    when(
      () => dio.post<dynamic>(any(), data: any(named: 'data')),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: <String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'isSuccess': true,
            'message': 'changed',
            'activationRecId': 1,
          },
        },
      ),
    );

    final String message = await sut.changePassword(
      oldPassword: '123',
      newPassword: '456',
    );
    expect(message, 'changed');
    verify(
      () => dio.post<dynamic>(
        '/api/v1/auth/change-password',
        data: <String, String>{
          'oldPassword': '123',
          'newPassword': '456',
        },
      ),
    ).called(1);
  });
}
