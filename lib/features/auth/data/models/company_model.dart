import '../../domain/entities/company_entity.dart';

class CompanyModel {
  const CompanyModel({
    required this.code,
    required this.name,
    required this.groupId,
  });

  final String code;
  final String name;
  final String groupId;

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      code: json['code'] as String,
      name: json['name'] as String,
      groupId: json['groupId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'name': name,
    'groupId': groupId,
  };

  CompanyEntity toEntity() =>
      CompanyEntity(code: code, name: name, groupId: groupId);
}
