import '../../../../core/utils/json_map.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import 'user_session_model.dart';

export 'user_session_model.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserSessionModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final Object? userRaw = JsonMap.value(json, 'user');
    return AuthResponseModel(
      accessToken: JsonMap.string(json, 'accessToken'),
      refreshToken: JsonMap.string(json, 'refreshToken'),
      user: UserSessionModel.fromJson(
        userRaw is Map<String, dynamic> ? userRaw : <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': user.toJson(),
  };

  AuthTokensEntity toEntity() => AuthTokensEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: user.toEntity(),
  );

  AuthResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserSessionModel? user,
  }) {
    return AuthResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}
