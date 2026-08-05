import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_session_entity.dart';
import 'company_model.dart';

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
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserSessionModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthTokensEntity toEntity() => AuthTokensEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: user.toEntity(),
  );
}

class UserSessionModel {
  const UserSessionModel({
    required this.personnelNumber,
    required this.workerRecId,
    required this.name,
    required this.companies,
    this.selectedCompany,
  });

  final String personnelNumber;
  final int workerRecId;
  final String name;
  final List<CompanyModel> companies;
  final CompanyModel? selectedCompany;

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> companiesJson =
        json['companies'] as List<dynamic>? ?? <dynamic>[];
    return UserSessionModel(
      personnelNumber: json['personnelNumber'] as String,
      workerRecId: (json['workerRecId'] as num).toInt(),
      name: json['name'] as String,
      companies: companiesJson
          .map((dynamic e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedCompany: json['selectedCompany'] == null
          ? null
          : CompanyModel.fromJson(
              json['selectedCompany'] as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'personnelNumber': personnelNumber,
    'workerRecId': workerRecId,
    'name': name,
    'companies': companies.map((CompanyModel c) => c.toJson()).toList(),
    if (selectedCompany != null) 'selectedCompany': selectedCompany!.toJson(),
  };

  UserSessionEntity toEntity() => UserSessionEntity(
    personnelNumber: personnelNumber,
    workerRecId: workerRecId,
    name: name,
    companies: companies.map((CompanyModel c) => c.toEntity()).toList(),
    selectedCompany: selectedCompany?.toEntity(),
  );

  factory UserSessionModel.fromEntity(UserSessionEntity entity) {
    return UserSessionModel(
      personnelNumber: entity.personnelNumber,
      workerRecId: entity.workerRecId,
      name: entity.name,
      companies: entity.companies
          .map(
            (c) => CompanyModel(code: c.code, name: c.name, groupId: c.groupId),
          )
          .toList(),
      selectedCompany: entity.selectedCompany == null
          ? null
          : CompanyModel(
              code: entity.selectedCompany!.code,
              name: entity.selectedCompany!.name,
              groupId: entity.selectedCompany!.groupId,
            ),
    );
  }
}
