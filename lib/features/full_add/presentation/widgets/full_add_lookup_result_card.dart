import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_context.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/ltr_text.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/barcode_item_entity.dart';
import '../../../catalog/domain/entities/price_info_entity.dart';
import '../../../catalog/domain/entities/warehouse_on_hand_entity.dart';
import '../../domain/full_add_display_unit.dart';
import 'full_add_scan_chrome.dart';

/// Lookup result: name, stock (sales qty + unit), then price.
class FullAddLookupResultCard extends StatelessWidget {
  const FullAddLookupResultCard({
    required this.item,
    required this.fetchingPrice,
    required this.fetchingQty,
    required this.stockUnavailable,
    required this.price,
    required this.onHand,
    this.priceUnavailable = false,
    super.key,
  });

  final BarcodeItemEntity item;
  final bool fetchingPrice;
  final bool fetchingQty;
  final bool stockUnavailable;
  final bool priceUnavailable;
  final PriceInfoEntity? price;
  final WarehouseOnHandEntity? onHand;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      variant: AppCardVariant.tonal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AppIconBadge(icon: Icons.inventory_2_outlined),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LtrText(
                      item.itemNumber,
                      style: context.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.productName,
                      style: context.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          _stockSection(l10n),
          const SizedBox(height: AppDimensions.spaceSm),
          if (fetchingPrice)
            const FullAddPriceLoadingRow()
          else
            KeyValueRow(
              label: l10n.price,
              value: _priceValue(l10n),
              numeric: price != null,
            ),
        ],
      ),
    );
  }

  String _priceValue(AppLocalizations l10n) {
    if (price != null) {
      return _priceLabel(price!);
    }
    if (priceUnavailable) {
      return l10n.errorNoPrice;
    }
    return AppFormat.dash;
  }

  Widget _stockSection(AppLocalizations l10n) {
    if (fetchingQty) {
      return const Align(
        alignment: AlignmentDirectional.centerStart,
        child: FullAddInlineLoader(),
      );
    }
    if (onHand != null) {
      final String? unit = FullAddDisplayUnit.resolve(
        inventoryUnit: onHand!.unit,
        lookupUnitId: item.unitId,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          KeyValueRow(
            label: l10n.availableQty,
            value: FullAddDisplayUnit.formatAvailable(
              formattedQuantity: AppFormat.quantity(
                onHand!.availableSalesQuantity,
              ),
              unit: unit,
            ),
            numeric: true,
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          _stockChip(l10n, onHand!.availableSalesQuantity),
        ],
      );
    }
    if (stockUnavailable) {
      return KeyValueRow(label: l10n.availableQty, value: l10n.errorNoStock);
    }
    return const SizedBox.shrink();
  }

  String _priceLabel(PriceInfoEntity price) {
    final String amount = AppFormat.price(price.price);
    final String currency = price.currency.trim();
    return currency.isEmpty ? amount : '$amount $currency';
  }

  Widget _stockChip(AppLocalizations l10n, num qty) {
    if (qty <= 0) {
      return StatusChip.danger(label: l10n.stockOut);
    }
    if (qty < 10) {
      return StatusChip.warning(label: l10n.stockLow);
    }
    return StatusChip.success(label: l10n.stockInStock);
  }
}
