import 'package:equatable/equatable.dart';

import 'company_entity.dart';
import 'user_session_entity.dart';

class AuthTokensEntity extends Equatable {
  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserSessionEntity user;

  @override
  List<Object?> get props => <Object?>[accessToken, refreshToken, user];
}

// Re-export convenience for company list typing in auth package.
typedef AuthCompany = CompanyEntity;
