import '../../domain/entities/user_session_entity.dart';
import '../models/user_session_model.dart';

/// Warehouse rules applied when the cached session is rewritten.
abstract final class SessionWarehouseMerge {
  /// Applies a picked warehouse to [current] and clears the selection flag.
  static UserSessionEntity applyPick(
    UserSessionEntity current, {
    required String inventLocationId,
    String? dataAreaId,
    String? warehouseDisplayName,
  }) {
    final String? area = dataAreaId?.trim();
    return current.copyWith(
      activeWarehouse: inventLocationId,
      inventLocation: inventLocationId,
      displayWarehouseName: warehouseDisplayName ?? inventLocationId,
      activeWarehouseName: warehouseDisplayName,
      inventLocationDataAreaId: area == null || area.isEmpty
          ? current.inventLocationDataAreaId ?? current.operatingCompany
          : area,
      needsWarehouseSelection: false,
    );
  }

  /// Keeps a locally picked warehouse when the API returns none.
  static UserSessionModel keepLocal(
    UserSessionModel fresh,
    UserSessionModel cached,
  ) {
    final UserSessionEntity freshEntity = fresh.toEntity();
    UserSessionModel merged = fresh;
    if (freshEntity.resolvedWarehouse == null) {
      final String? local = cached.toEntity().resolvedWarehouse;
      if (local != null) {
        merged = UserSessionModel.fromEntity(
          applyPick(
            freshEntity,
            inventLocationId: local,
            dataAreaId: cached.inventLocationDataAreaId,
            warehouseDisplayName:
                cached.displayWarehouseName ?? cached.activeWarehouseName,
          ),
        );
      }
    }
    return UserSessionModel.fromEntity(_mergeDisplayLabels(merged, cached));
  }

  static UserSessionEntity _mergeDisplayLabels(
    UserSessionModel fresh,
    UserSessionModel cached,
  ) {
    final UserSessionEntity freshEntity = fresh.toEntity();
    final UserSessionEntity cachedEntity = cached.toEntity();
    final String? freshWh = freshEntity.resolvedWarehouse?.trim();
    final String? cachedWh = cachedEntity.resolvedWarehouse?.trim();
    final bool sameWarehouse =
        freshWh != null &&
        cachedWh != null &&
        freshWh.toLowerCase() == cachedWh.toLowerCase();
    return freshEntity.copyWith(
      displayWarehouseName: UserSessionEntity.firstNonEmpty(<String?>[
        freshEntity.displayWarehouseName,
        if (sameWarehouse) cachedEntity.displayWarehouseName,
      ]),
      activeWarehouseName: UserSessionEntity.firstNonEmpty(<String?>[
        freshEntity.activeWarehouseName,
        if (sameWarehouse) cachedEntity.activeWarehouseName,
      ]),
      displayCompanyName: UserSessionEntity.firstNonEmpty(<String?>[
        freshEntity.displayCompanyName,
        cachedEntity.displayCompanyName,
      ]),
    );
  }
}
