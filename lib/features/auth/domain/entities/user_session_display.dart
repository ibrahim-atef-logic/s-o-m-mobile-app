import 'user_session_entity.dart';

/// Profile and list labels derived from [UserSessionEntity] activation fields.
extension UserSessionDisplay on UserSessionEntity {
  String displayOrDash(String? value) {
    final String? v = UserSessionEntity.firstNonEmpty(<String?>[value]);
    return v ?? '—';
  }

  /// Hero title: `name` → `personnelNumber`.
  String get profileDisplayName =>
      UserSessionEntity.firstNonEmpty(<String?>[name, personnelNumber]) ?? '—';

  /// Branch row on Profile — name only; hide row when null.
  String? get profileChannelLabel =>
      UserSessionEntity.firstNonEmpty(<String?>[retailChannelName]);

  /// Currency row on Profile — hide when null.
  String? get profileCurrencyLabel =>
      UserSessionEntity.firstNonEmpty(<String?>[currency]);

  /// Warehouse row on Profile; [selectWarehousePrompt] when pick is required.
  String profileWarehouseLabel({required String selectWarehousePrompt}) {
    if (needsWarehouseSelection == true) {
      return selectWarehousePrompt;
    }
    return displayOrDash(resolvedDisplayWarehouseName);
  }

  /// Branch shown outside Profile: name → channel id → warehouse code.
  String get displayBranchLabel =>
      UserSessionEntity.firstNonEmpty(<String?>[
        retailChannelName,
        retailChannelId,
        resolvedWarehouse,
      ]) ??
      '—';
}
