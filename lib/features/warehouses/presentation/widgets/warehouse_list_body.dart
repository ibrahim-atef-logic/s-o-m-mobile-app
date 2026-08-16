import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/warehouse_entity.dart';

/// Searchable list of Standard warehouses.
class WarehouseListBody extends StatefulWidget {
  const WarehouseListBody({
    required this.warehouses,
    required this.onSelected,
    this.selectedCode,
    this.enabled = true,
    super.key,
  });

  final List<WarehouseEntity> warehouses;
  final ValueChanged<WarehouseEntity> onSelected;
  final String? selectedCode;
  final bool enabled;

  @override
  State<WarehouseListBody> createState() => _WarehouseListBodyState();
}

class _WarehouseListBodyState extends State<WarehouseListBody> {
  String _query = '';

  List<WarehouseEntity> get _filtered {
    final String needle = _query.trim().toLowerCase();
    if (needle.isEmpty) {
      return widget.warehouses;
    }
    return widget.warehouses
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
    if (widget.warehouses.isEmpty) {
      return AppEmptyView(
        title: l10n.noWarehouses,
        icon: Icons.warehouse_outlined,
      );
    }
    final List<WarehouseEntity> items = _filtered;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          child: TextField(
            decoration: InputDecoration(
              labelText: l10n.searchWarehouses,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (String value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? AppEmptyView(title: l10n.noWarehouses, icon: Icons.search_off)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMd,
                  ),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _WarehouseTile(
                      warehouse: items[index],
                      selected:
                          items[index].inventLocationId == widget.selectedCode,
                      onTap: widget.enabled
                          ? () => widget.onSelected(items[index])
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WarehouseTile extends StatelessWidget {
  const _WarehouseTile({
    required this.warehouse,
    required this.selected,
    this.onTap,
  });

  final WarehouseEntity warehouse;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: warehouse.displayName,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            const Icon(Icons.warehouse_outlined, color: AppColors.primary),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(warehouse.displayName, style: AppTextStyles.titleMd),
                  const SizedBox(height: AppDimensions.spaceXs),
                  Text(warehouse.displayDetails, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: selected ? AppColors.success : AppColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }
}
