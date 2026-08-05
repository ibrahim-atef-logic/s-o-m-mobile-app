import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  const CompanyEntity({
    required this.code,
    required this.name,
    required this.groupId,
  });

  final String code;
  final String name;
  final String groupId;

  @override
  List<Object?> get props => <Object?>[code, name, groupId];
}
