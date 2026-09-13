import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_validation_text.dart';
import '../../../../core/widgets/barcode_scanner_panel.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../l10n/app_localizations.dart';

/// Scan step: hardware-first field, optional camera, lookup action.
class FullAddScanCard extends StatelessWidget {
  const FullAddScanCard({
    required this.controller,
    required this.focusNode,
    required this.onCaptured,
    required this.onChanged,
    required this.onLookup,
    required this.looking,
    required this.showCamera,
    required this.onToggleCamera,
    this.lastScanned,
    this.errorMessage,
    this.lookupByItem = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCaptured;
  final ValueChanged<String> onChanged;
  final VoidCallback onLookup;
  final bool looking;
  final bool showCamera;
  final VoidCallback onToggleCamera;
  final String? lastScanned;
  final String? errorMessage;
  final bool lookupByItem;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionLabel(l10n.stepScan),
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            decoration: InputDecoration(
              labelText: lookupByItem ? l10n.searchByItem : l10n.barcode,
              prefixIcon: Icon(
                lookupByItem
                    ? Icons.inventory_2_outlined
                    : Icons.qr_code_2_outlined,
              ),
              errorText: errorMessage,
              errorMaxLines: 3,
            ),
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: (_) => onLookup(),
          ),
          const SizedBox(height: AppDimensions.space12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onToggleCamera,
              icon: Icon(
                showCamera
                    ? Icons.videocam_off_outlined
                    : Icons.photo_camera_outlined,
              ),
              label: Text(showCamera ? l10n.hideCamera : l10n.scanWithCamera),
            ),
          ),
          if (showCamera) ...<Widget>[
            const SizedBox(height: AppDimensions.spaceSm),
            BarcodeScannerPanel(
              lastScanned: lastScanned,
              onCaptured: onCaptured,
            ),
          ],
          const SizedBox(height: AppDimensions.space12),
          PrimaryButton(
            label: l10n.lookup,
            icon: Icons.search,
            isLoading: looking,
            onPressed: onLookup,
          ),
        ],
      ),
    );
  }
}

/// Quantity step: stepper plus the active validation message.
class FullAddQuantityCard extends StatelessWidget {
  const FullAddQuantityCard({
    required this.controller,
    required this.onChanged,
    this.onCommitted,
    this.max,
    this.validationMessage,
    this.showSteppers = true,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCommitted;
  final int? max;
  final String? validationMessage;
  final bool showSteppers;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionLabel(l10n.stepQuantity),
          QuantityStepper(
            controller: controller,
            max: max,
            showButtons: showSteppers,
            onChanged: onChanged,
            onCommitted: onCommitted,
          ),
          AppValidationText(validationMessage),
        ],
      ),
    );
  }
}
