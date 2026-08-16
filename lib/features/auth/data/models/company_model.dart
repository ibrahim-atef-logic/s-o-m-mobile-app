import '../../../../core/utils/json_map.dart';
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
    final String code = JsonMap.string(json, 'code');
    final String name = JsonMap.string(json, 'name');
    return CompanyModel(
      code: code,
      name: name.isEmpty ? code : name,
      groupId: JsonMap.string(json, 'groupId'),
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
