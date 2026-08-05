import 'package:equatable/equatable.dart';

import 'company_entity.dart';

class UserSessionEntity extends Equatable {
  const UserSessionEntity({
    required this.personnelNumber,
    required this.workerRecId,
    required this.name,
    required this.companies,
    this.selectedCompany,
  });

  final String personnelNumber;
  final int workerRecId;
  final String name;
  final List<CompanyEntity> companies;
  final CompanyEntity? selectedCompany;

  UserSessionEntity copyWith({
    String? personnelNumber,
    int? workerRecId,
    String? name,
    List<CompanyEntity>? companies,
    CompanyEntity? selectedCompany,
  }) {
    return UserSessionEntity(
      personnelNumber: personnelNumber ?? this.personnelNumber,
      workerRecId: workerRecId ?? this.workerRecId,
      name: name ?? this.name,
      companies: companies ?? this.companies,
      selectedCompany: selectedCompany ?? this.selectedCompany,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    personnelNumber,
    workerRecId,
    name,
    companies,
    selectedCompany,
  ];
}
