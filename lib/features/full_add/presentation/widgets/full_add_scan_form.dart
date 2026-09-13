import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/skeletons/lookup_result_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/full_add_qty_rules.dart';
import '../bloc/full_add_bloc.dart';
import '../full_add_lookup_error.dart';
import 'full_add_lookup_result_card.dart';
import 'full_add_mode_toggle.dart';
import 'full_add_scan_cards.dart';

/// Composer body: mode, lookup field, result, qty, optional Add button.
class FullAddScanForm extends StatelessWidget {
  const FullAddScanForm({
    required this.state,
    required this.l10n,
    required this.barcodeCtrl,
    required this.qtyCtrl,
    required this.barcodeFocus,
    required this.lastScanned,
    required this.showCamera,
    required this.onToggleCamera,
    required this.onCaptured,
    required this.onBarcodeChanged,
    required this.onLookup,
    required this.onLookupByItem,
    required this.onModeChanged,
    required this.onQtyChanged,
    required this.onQtyCommitted,
    required this.onAdd,
    super.key,
  });

  final FullAddState state;
  final AppLocalizations l10n;
  final TextEditingController barcodeCtrl;
  final TextEditingController qtyCtrl;
  final FocusNode barcodeFocus;
  final String? lastScanned;
  final bool showCamera;
  final VoidCallback onToggleCamera;
  final ValueChanged<String> onCaptured;
  final ValueChanged<String> onBarcodeChanged;
  final VoidCallback onLookup;
  final ValueChanged<bool> onLookupByItem;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onQtyChanged;
  final VoidCallback onQtyCommitted;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceMd,
        AppDimensions.spaceSm,
        AppDimensions.spaceMd,
        AppDimensions.spaceXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FullAddModeToggle(autoMode: state.autoMode, onChanged: onModeChanged),
          const SizedBox(height: AppDimensions.spaceSm),
          SegmentedButton<bool>(
            segments: <ButtonSegment<bool>>[
              ButtonSegment<bool>(
                value: false,
                label: Text(l10n.searchByBarcode),
                icon: const Icon(Icons.qr_code_2_outlined),
              ),
              ButtonSegment<bool>(
                value: true,
                label: Text(l10n.searchByItem),
                icon: const Icon(Icons.inventory_2_outlined),
              ),
            ],
            selected: <bool>{state.lookupByItem},
            onSelectionChanged: (Set<bool> next) => onLookupByItem(next.first),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          FullAddScanCard(
            controller: barcodeCtrl,
            focusNode: barcodeFocus,
            lastScanned: lastScanned,
            looking: state.lookingUp || state.fetchingPrice,
            lookupByItem: state.lookupByItem,
            errorMessage: fullAddLookupErrorMessage(l10n: l10n, state: state),
            showCamera: showCamera,
            onToggleCamera: onToggleCamera,
            onCaptured: onCaptured,
            onChanged: onBarcodeChanged,
            onLookup: onLookup,
          ),
          if (state.lookingUp) const LookupResultSkeleton(),
          if (state.item != null)
            FullAddLookupResultCard(
              item: state.item!,
              fetchingPrice: state.fetchingPrice,
              fetchingQty: state.fetchingQty,
              stockUnavailable:
                  state.validation == FullAddValidation.noStock &&
                  state.onHand == null,
              priceUnavailable: state.validation == FullAddValidation.noPrice,
              price: state.price,
              onHand: state.onHand,
            ),
          FullAddQuantityCard(
            controller: qtyCtrl,
            showSteppers: !state.autoMode,
            max: state.onHand == null
                ? null
                : FullAddQtyRules.roundNearest(
                    state.onHand!.availableSalesQuantity,
                  ),
            onChanged: onQtyChanged,
            onCommitted: (_) => onQtyCommitted(),
            validationMessage: _qtyError(l10n, state),
          ),
          if (!state.autoMode) ...<Widget>[
            const SizedBox(height: AppDimensions.spaceSm),
            PrimaryButton(
              label: l10n.addToCart,
              isLoading: state.submitting,
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ],
      ),
    );
  }

  String? _qtyError(AppLocalizations l10n, FullAddState state) {
    if (state.validation == FullAddValidation.none ||
        state.validation == FullAddValidation.barcodeRequired ||
        state.fetchingPrice) {
      return null;
    }
    return switch (state.validation) {
      FullAddValidation.noPrice => l10n.errorNoPrice,
      FullAddValidation.noStock => l10n.errorNoStock,
      FullAddValidation.qtyInvalid => l10n.errorQtyInvalid,
      FullAddValidation.qtyExceeds => l10n.errorQtyExceeds,
      FullAddValidation.lookupRequired => l10n.errorLookupRequired,
      FullAddValidation.barcodeRequired || FullAddValidation.none => null,
    };
  }
}
