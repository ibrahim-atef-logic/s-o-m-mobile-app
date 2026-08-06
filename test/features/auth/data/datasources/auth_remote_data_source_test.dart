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
}
