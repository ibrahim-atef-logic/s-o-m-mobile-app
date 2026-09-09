import 'package:equatable/equatable.dart';

import 'company_entity.dart';

export 'user_session_display.dart';

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
    this.retailChannelName,
    this.channelType,
    this.inventLocation,
    this.inventLocationDataAreaId,
    this.inventLocationDataAreaName,
    this.userInfoCompany,
    this.userInfoCompanyName,
    this.displayCompanyName,
    this.displayWarehouseName,
    this.activeWarehouseName,
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

  /// Human-readable branch/store from D365 `RetailChannelName` (via API).
  final String? retailChannelName;
  final int? channelType;
  final String? inventLocation;
  final String? inventLocationDataAreaId;

  /// Branch company display name from D365 (may be null until F&O deploys).
  final String? inventLocationDataAreaName;

  /// User company code from activation (`UserInfo_company`).
  final String? userInfoCompany;

  /// User company display name (may be null until F&O deploys).
  final String? userInfoCompanyName;

  /// Server-computed label: branch name → user company name → company name/code.
  final String? displayCompanyName;

  /// Warehouse label from D365 lookup (may equal code until Arabic name exists).
  final String? displayWarehouseName;

  /// Warehouse name from activation row (before display merge).
  final String? activeWarehouseName;
  final String? currency;
  final String? defaultCustAccount;
  final String? defaultCustDataAreaId;
  final String? activeCompany;
  final String? activeWarehouse;
  final bool? needsWarehouseSelection;

  /// DataArea for catalog / sales-order API `company` query/body.
  String get operatingCompany {
    return firstNonEmpty(<String?>[
          activeCompany,
          company,
          selectedCompany?.code,
        ]) ??
        '';
  }

  /// Human label for UI only — never send this as DataAreaId.
  String get resolvedDisplayCompanyName {
    return firstNonEmpty(<String?>[
          displayCompanyName,
          inventLocationDataAreaName,
          userInfoCompanyName,
          companies.isEmpty ? null : companies.first.name,
          activeCompany,
        ]) ??
        '';
  }

  /// Human warehouse label for UI — codes only when no display name exists.
  String get resolvedDisplayWarehouseName {
    return firstNonEmpty(<String?>[
          displayWarehouseName,
          activeWarehouseName,
          activeWarehouse,
          inventLocation,
        ]) ??
        '';
  }

  /// DataArea for create-sales-order calls, which follow the warehouse company.
  String get orderDataArea {
    return firstNonEmpty(<String?>[
          inventLocationDataAreaId,
          activeCompany,
          company,
          selectedCompany?.code,
        ]) ??
        '';
  }

  String? get resolvedWarehouse =>
      firstNonEmpty(<String?>[activeWarehouse, inventLocation]);

  bool get warehouseMissing {
    if (needsWarehouseSelection == true) {
      return true;
    }
    return resolvedWarehouse == null;
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
    String? retailChannelName,
    int? channelType,
    String? inventLocation,
    String? inventLocationDataAreaId,
    String? inventLocationDataAreaName,
    String? userInfoCompany,
    String? userInfoCompanyName,
    String? displayCompanyName,
    String? displayWarehouseName,
    String? activeWarehouseName,
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
      retailChannelName: retailChannelName ?? this.retailChannelName,
      channelType: channelType ?? this.channelType,
      inventLocation: inventLocation ?? this.inventLocation,
      inventLocationDataAreaId:
          inventLocationDataAreaId ?? this.inventLocationDataAreaId,
      inventLocationDataAreaName:
          inventLocationDataAreaName ?? this.inventLocationDataAreaName,
      userInfoCompany: userInfoCompany ?? this.userInfoCompany,
      userInfoCompanyName: userInfoCompanyName ?? this.userInfoCompanyName,
      displayCompanyName: displayCompanyName ?? this.displayCompanyName,
      displayWarehouseName: displayWarehouseName ?? this.displayWarehouseName,
      activeWarehouseName: activeWarehouseName ?? this.activeWarehouseName,
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

  /// Shared trim helper for activation string fields.
  static String? firstNonEmpty(List<String?> values) {
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
    retailChannelName,
    channelType,
    inventLocation,
    inventLocationDataAreaId,
    inventLocationDataAreaName,
    userInfoCompany,
    userInfoCompanyName,
    displayCompanyName,
    displayWarehouseName,
    activeWarehouseName,
    currency,
    defaultCustAccount,
    defaultCustDataAreaId,
    activeCompany,
    activeWarehouse,
    needsWarehouseSelection,
  ];
}
