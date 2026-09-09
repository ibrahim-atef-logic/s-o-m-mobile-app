import '../../../../core/utils/json_map.dart';
import '../../domain/entities/user_session_entity.dart';
import 'company_model.dart';

class UserSessionModel {
  const UserSessionModel({
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
  final List<CompanyModel> companies;
  final CompanyModel? selectedCompany;
  final String? userId;
  final int? activationRecId;
  final bool isActive;
  final bool userInfoEnable;
  final String? company;
  final int? retailChannelTableRecId;
  final String? retailChannelId;
  final String? retailChannelName;
  final int? channelType;
  final String? inventLocation;
  final String? inventLocationDataAreaId;
  final String? inventLocationDataAreaName;
  final String? userInfoCompany;
  final String? userInfoCompanyName;
  final String? displayCompanyName;
  final String? displayWarehouseName;
  final String? activeWarehouseName;
  final String? currency;
  final String? defaultCustAccount;
  final String? defaultCustDataAreaId;
  final String? activeCompany;
  final String? activeWarehouse;
  final bool? needsWarehouseSelection;

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> companiesJson =
        (JsonMap.value(json, 'companies') as List<dynamic>?) ?? <dynamic>[];
    final String? warehouse =
        JsonMap.stringOrNull(json, 'activeWarehouse') ??
        JsonMap.stringOrNull(json, 'inventLocation');
    final bool? needsFlag = JsonMap.flagOrNull(json, 'needsWarehouseSelection');
    final Object? selectedRaw = JsonMap.value(json, 'selectedCompany');
    return UserSessionModel(
      personnelNumber: JsonMap.stringAny(json, <String>[
        'personnelNumber',
        'PersonnelNumber',
        '_personnelNumber',
      ]),
      workerRecId: JsonMap.integer(json, 'workerRecId'),
      name: JsonMap.string(json, 'name'),
      companies: <CompanyModel>[
        for (final Object? item in companiesJson)
          if (item is Map)
            CompanyModel.fromJson(Map<String, dynamic>.from(item)),
      ],
      selectedCompany: selectedRaw is Map<String, dynamic>
          ? CompanyModel.fromJson(selectedRaw)
          : null,
      userId: JsonMap.stringOrNull(json, 'userId'),
      activationRecId: JsonMap.integerOrNull(json, 'activationRecId'),
      isActive: JsonMap.flag(json, 'isActive', fallback: true),
      userInfoEnable: JsonMap.flag(json, 'userInfoEnable', fallback: true),
      company: JsonMap.stringOrNull(json, 'company'),
      retailChannelTableRecId: JsonMap.integerOrNull(
        json,
        'retailChannelTableRecId',
      ),
      retailChannelId: JsonMap.stringOrNull(json, 'retailChannelId'),
      // JsonMap.value is case-insensitive → also accepts RetailChannelName.
      retailChannelName: JsonMap.stringOrNull(json, 'retailChannelName'),
      channelType: JsonMap.integerOrNull(json, 'channelType'),
      inventLocation: JsonMap.stringOrNull(json, 'inventLocation'),
      inventLocationDataAreaId: JsonMap.stringOrNull(
        json,
        'inventLocationDataAreaId',
      ),
      inventLocationDataAreaName: JsonMap.stringOrNull(
        json,
        'inventLocationDataAreaName',
      ),
      userInfoCompany: JsonMap.stringOrNull(json, 'userInfoCompany'),
      userInfoCompanyName: JsonMap.stringOrNull(json, 'userInfoCompanyName'),
      displayCompanyName: JsonMap.stringOrNull(json, 'displayCompanyName'),
      displayWarehouseName: JsonMap.stringOrNull(json, 'displayWarehouseName'),
      activeWarehouseName: JsonMap.stringOrNull(json, 'activeWarehouseName'),
      currency: JsonMap.stringOrNull(json, 'currency'),
      defaultCustAccount: JsonMap.stringOrNull(json, 'defaultCustAccount'),
      defaultCustDataAreaId: JsonMap.stringOrNull(
        json,
        'defaultCustDataAreaId',
      ),
      activeCompany: JsonMap.stringOrNull(json, 'activeCompany'),
      activeWarehouse: JsonMap.stringOrNull(json, 'activeWarehouse'),
      needsWarehouseSelection: needsFlag ?? warehouse == null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'personnelNumber': personnelNumber,
    'workerRecId': workerRecId,
    'name': name,
    'companies': companies.map((CompanyModel c) => c.toJson()).toList(),
    if (selectedCompany != null) 'selectedCompany': selectedCompany!.toJson(),
    'userId': userId,
    'activationRecId': activationRecId,
    'isActive': isActive,
    'userInfoEnable': userInfoEnable,
    'company': company,
    'retailChannelTableRecId': retailChannelTableRecId,
    'retailChannelId': retailChannelId,
    'retailChannelName': retailChannelName,
    'channelType': channelType,
    'inventLocation': inventLocation,
    'inventLocationDataAreaId': inventLocationDataAreaId,
    'inventLocationDataAreaName': inventLocationDataAreaName,
    'userInfoCompany': userInfoCompany,
    'userInfoCompanyName': userInfoCompanyName,
    'displayCompanyName': displayCompanyName,
    'displayWarehouseName': displayWarehouseName,
    'activeWarehouseName': activeWarehouseName,
    'currency': currency,
    'defaultCustAccount': defaultCustAccount,
    'defaultCustDataAreaId': defaultCustDataAreaId,
    'activeCompany': activeCompany,
    'activeWarehouse': activeWarehouse,
    'needsWarehouseSelection': needsWarehouseSelection,
  };

  UserSessionEntity toEntity() => UserSessionEntity(
    personnelNumber: personnelNumber,
    workerRecId: workerRecId,
    name: name,
    companies: companies.map((CompanyModel c) => c.toEntity()).toList(),
    selectedCompany: selectedCompany?.toEntity(),
    userId: userId,
    activationRecId: activationRecId,
    isActive: isActive,
    userInfoEnable: userInfoEnable,
    company: company,
    retailChannelTableRecId: retailChannelTableRecId,
    retailChannelId: retailChannelId,
    retailChannelName: retailChannelName,
    channelType: channelType,
    inventLocation: inventLocation,
    inventLocationDataAreaId: inventLocationDataAreaId,
    inventLocationDataAreaName: inventLocationDataAreaName,
    userInfoCompany: userInfoCompany,
    userInfoCompanyName: userInfoCompanyName,
    displayCompanyName: displayCompanyName,
    displayWarehouseName: displayWarehouseName,
    activeWarehouseName: activeWarehouseName,
    currency: currency,
    defaultCustAccount: defaultCustAccount,
    defaultCustDataAreaId: defaultCustDataAreaId,
    activeCompany: activeCompany,
    activeWarehouse: activeWarehouse,
    needsWarehouseSelection: needsWarehouseSelection,
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
      userId: entity.userId,
      activationRecId: entity.activationRecId,
      isActive: entity.isActive,
      userInfoEnable: entity.userInfoEnable,
      company: entity.company,
      retailChannelTableRecId: entity.retailChannelTableRecId,
      retailChannelId: entity.retailChannelId,
      retailChannelName: entity.retailChannelName,
      channelType: entity.channelType,
      inventLocation: entity.inventLocation,
      inventLocationDataAreaId: entity.inventLocationDataAreaId,
      inventLocationDataAreaName: entity.inventLocationDataAreaName,
      userInfoCompany: entity.userInfoCompany,
      userInfoCompanyName: entity.userInfoCompanyName,
      displayCompanyName: entity.displayCompanyName,
      displayWarehouseName: entity.displayWarehouseName,
      activeWarehouseName: entity.activeWarehouseName,
      currency: entity.currency,
      defaultCustAccount: entity.defaultCustAccount,
      defaultCustDataAreaId: entity.defaultCustDataAreaId,
      activeCompany: entity.activeCompany,
      activeWarehouse: entity.activeWarehouse,
      needsWarehouseSelection: entity.needsWarehouseSelection,
    );
  }
}
