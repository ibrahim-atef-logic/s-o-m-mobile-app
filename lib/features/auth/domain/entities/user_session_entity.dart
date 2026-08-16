import 'package:equatable/equatable.dart';

import 'company_entity.dart';

/// Cached mobile activation user. Source of truth after login/refresh/me.
class UserSessionEntity extends Equatable {
  const UserSessionEntity({
    required this.personnelNumber,
    required this.workerRecId,
    required this.name,
    required this.companies,
    this.selectedCompany,
    this.userId,
    this.activationRecId,
    this.isActive = true,
    this.userInfoEnable = true,
    this.company,
    this.retailChannelTableRecId,
    this.retailChannelId,
    this.channelType,
    this.inventLocation,
    this.inventLocationDataAreaId,
    this.currency,
    this.defaultCustAccount,
    this.defaultCustDataAreaId,
    this.activeCompany,
    this.activeWarehouse,
    this.needsWarehouseSelection,
  });

  final String personnelNumber;
  final int workerRecId;
  final String name;
  final List<CompanyEntity> companies;
  final CompanyEntity? selectedCompany;
  final String? userId;
  final int? activationRecId;
  final bool isActive;
  final bool userInfoEnable;
  final String? company;
  final int? retailChannelTableRecId;
  final String? retailChannelId;
  final int? channelType;
  final String? inventLocation;
  final String? inventLocationDataAreaId;
  final String? currency;
  final String? defaultCustAccount;
  final String? defaultCustDataAreaId;
  final String? activeCompany;
  final String? activeWarehouse;
  final bool? needsWarehouseSelection;

  /// DataArea for catalog / sales-order API `company` query/body.
  String get operatingCompany {
    return _firstNonEmpty(<String?>[
          activeCompany,
          company,
          selectedCompany?.code,
        ]) ??
        '';
  }

  String? get resolvedWarehouse =>
      _firstNonEmpty(<String?>[activeWarehouse, inventLocation]);

  bool get warehouseMissing {
    if (needsWarehouseSelection == true) {
      return true;
    }
    return resolvedWarehouse == null;
  }

  String displayOrDash(String? value) {
    final String? v = _firstNonEmpty(<String?>[value]);
    return v ?? '—';
  }

  CompanyEntity? companyByCode(String code) {
    final String needle = code.trim().toLowerCase();
    if (needle.isEmpty) {
      return null;
    }
    for (final CompanyEntity company in companies) {
      if (company.code.toLowerCase() == needle) {
        return company;
      }
    }
    return null;
  }

  UserSessionEntity copyWith({
    String? personnelNumber,
    int? workerRecId,
    String? name,
    List<CompanyEntity>? companies,
    CompanyEntity? selectedCompany,
    String? userId,
    int? activationRecId,
    bool? isActive,
    bool? userInfoEnable,
    String? company,
    int? retailChannelTableRecId,
    String? retailChannelId,
    int? channelType,
    String? inventLocation,
    String? inventLocationDataAreaId,
    String? currency,
    String? defaultCustAccount,
    String? defaultCustDataAreaId,
    String? activeCompany,
    String? activeWarehouse,
    bool? needsWarehouseSelection,
  }) {
    return UserSessionEntity(
      personnelNumber: personnelNumber ?? this.personnelNumber,
      workerRecId: workerRecId ?? this.workerRecId,
      name: name ?? this.name,
      companies: companies ?? this.companies,
      selectedCompany: selectedCompany ?? this.selectedCompany,
      userId: userId ?? this.userId,
      activationRecId: activationRecId ?? this.activationRecId,
      isActive: isActive ?? this.isActive,
      userInfoEnable: userInfoEnable ?? this.userInfoEnable,
      company: company ?? this.company,
      retailChannelTableRecId:
          retailChannelTableRecId ?? this.retailChannelTableRecId,
      retailChannelId: retailChannelId ?? this.retailChannelId,
      channelType: channelType ?? this.channelType,
      inventLocation: inventLocation ?? this.inventLocation,
      inventLocationDataAreaId:
          inventLocationDataAreaId ?? this.inventLocationDataAreaId,
      currency: currency ?? this.currency,
      defaultCustAccount: defaultCustAccount ?? this.defaultCustAccount,
      defaultCustDataAreaId:
          defaultCustDataAreaId ?? this.defaultCustDataAreaId,
      activeCompany: activeCompany ?? this.activeCompany,
      activeWarehouse: activeWarehouse ?? this.activeWarehouse,
      needsWarehouseSelection:
          needsWarehouseSelection ?? this.needsWarehouseSelection,
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
    personnelNumber,
    workerRecId,
    name,
    companies,
    selectedCompany,
    userId,
    activationRecId,
    isActive,
    userInfoEnable,
    company,
    retailChannelTableRecId,
    retailChannelId,
    channelType,
    inventLocation,
    inventLocationDataAreaId,
    currency,
    defaultCustAccount,
    defaultCustDataAreaId,
    activeCompany,
    activeWarehouse,
    needsWarehouseSelection,
  ];
}
