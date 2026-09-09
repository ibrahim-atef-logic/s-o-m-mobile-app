import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_selectable_tile.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/warehouse_entity.dart';

/// Filtered list of Standard warehouses (search lives on the page).
class WarehouseListBody extends StatelessWidget {
  const WarehouseListBody({
    required this.warehouses,
    required this.onSelected,
    this.query = '',
    this.selectedCode,
    this.enabled = true,
    super.key,
  });

  final List<WarehouseEntity> warehouses;
  final ValueChanged<WarehouseEntity> onSelected;
  final String query;
  final String? selectedCode;
  final bool enabled;

  List<WarehouseEntity> get _filtered {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return warehouses;
    }
    return warehouses
        .where(
          (WarehouseEntity w) =>
              w.inventLocationId.toLowerCase().contains(needle) ||
              w.name.toLowerCase().contains(needle) ||
              (w.inventSiteId ?? '').toLowerCase().contains(needle),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (warehouses.isEmpty) {
      return AppEmptyView(
        title: l10n.noWarehouses,
        icon: Icons.warehouse_outlined,
      );
    }
    final List<WarehouseEntity> items = _filtered;
    if (items.isEmpty) {
      return AppEmptyView(
        title: l10n.noWarehousesMatchSearch,
        icon: Icons.search_off,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final WarehouseEntity warehouse = items[index];
        return AppSelectableTile(
          title: warehouse.displayName,
          subtitle: warehouse.displayDetails,
          leadingIcon: Icons.warehouse_outlined,
          selected: warehouse.inventLocationId == selectedCode,
          enabled: enabled,
          onTap: () => onSelected(warehouse),
        );
      },
    );
  }
}
