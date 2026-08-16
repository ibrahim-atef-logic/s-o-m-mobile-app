import 'package:equatable/equatable.dart';

/// Standard warehouse row returned by `GET /api/v1/warehouses`.
///
/// The API already restricts rows to `InventLocationType eq Standard`, so the
/// device never filters by type.
class WarehouseEntity extends Equatable {
  const WarehouseEntity({
    required this.dataAreaId,
    required this.inventLocationId,
    required this.name,
    this.inventSiteId,
    this.inventLocationType,
  });

  final String dataAreaId;
  final String inventLocationId;
  final String name;
  final String? inventSiteId;
  final String? inventLocationType;

  /// Primary label: warehouse name, falling back to its code.
  String get displayName => name.trim().isEmpty ? inventLocationId : name;

  /// Secondary label: code plus site when the site adds information.
  String get displayDetails {
    final String? site = inventSiteId?.trim();
    if (site == null || site.isEmpty || site == inventLocationId) {
      return inventLocationId;
    }
    return '$inventLocationId · $site';
  }

  @override
  List<Object?> get props => <Object?>[
    dataAreaId,
    inventLocationId,
    name,
    inventSiteId,
    inventLocationType,
  ];
}
