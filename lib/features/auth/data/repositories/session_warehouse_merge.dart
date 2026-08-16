import '../../domain/entities/user_session_entity.dart';
import '../models/user_session_model.dart';

/// Warehouse rules applied when the cached session is rewritten.
abstract final class SessionWarehouseMerge {
  /// Applies a picked warehouse to [current] and clears the selection flag.
  static UserSessionEntity applyPick(
    UserSessionEntity current, {
    required String inventLocationId,
    String? dataAreaId,
  }) {
    final String? area = dataAreaId?.trim();
    return current.copyWith(
      activeWarehouse: inventLocationId,
      inventLocation: inventLocationId,
      inventLocationDataAreaId: area == null || area.isEmpty
          ? current.inventLocationDataAreaId ?? current.operatingCompany
          : area,
      needsWarehouseSelection: false,
    );
  }

  /// Keeps a locally picked warehouse when the API returns none.
  ///
  /// Why: refresh tokens are minted before the device picks a warehouse, so the
  /// refreshed payload can still be empty while the user already chose one.
  static UserSessionModel keepLocal(
    UserSessionModel fresh,
    UserSessionModel cached,
  ) {
    final UserSessionEntity freshEntity = fresh.toEntity();
    if (freshEntity.resolvedWarehouse != null) {
      return fresh;
    }
    final String? local = cached.toEntity().resolvedWarehouse;
    if (local == null) {
      return fresh;
    }
    return UserSessionModel.fromEntity(
      applyPick(
        freshEntity,
        inventLocationId: local,
        dataAreaId: cached.inventLocationDataAreaId,
      ),
    );
  }
}
