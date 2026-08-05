import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/barcode_scanner_panel.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/skeletons/lookup_result_skeleton.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/full_add_bloc.dart';

class FullAddScanPage extends StatefulWidget {
  const FullAddScanPage({super.key});

  @override
  State<FullAddScanPage> createState() => _FullAddScanPageState();
}

class _FullAddScanPageState extends State<FullAddScanPage> {
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _qtyCtrl;
  String? _lastScanned;

  @override
  void initState() {
    super.initState();
    final FullAddState state = context.read<FullAddBloc>().state;
    _barcodeCtrl = TextEditingController(text: state.barcode);
    _qtyCtrl = TextEditingController(text: state.quantityText);
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addItem)),
      body: BlocConsumer<FullAddBloc, FullAddState>(
        listenWhen: (FullAddState p, FullAddState c) =>
            c.submitSucceeded ||
            (c.failure != null && c.failure != p.failure) ||
            c.barcode != p.barcode,
        listener: (BuildContext context, FullAddState state) {
          if (state.barcode != _barcodeCtrl.text) {
            _barcodeCtrl.text = state.barcode;
          }
          if (state.submitSucceeded) {
            showAppSnackBar(
              context,
              message: l10n.lineAdded,
              type: AppSnackBarType.success,
            );
            context.read<FullAddBloc>().add(const FullAddMessageCleared());
            context.pop();
            return;
          }
          if (state.failure != null) {
            showFailureSnackBar(context, state.failure!, l10n: l10n);
            context.read<FullAddBloc>().add(const FullAddMessageCleared());
          }
        },
        builder: (BuildContext context, FullAddState state) {
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            children: <Widget>[
              _StepHeader(
                labels: <String>[
                  l10n.stepScan,
                  l10n.stepQuantity,
                  l10n.stepAdd,
                ],
                activeIndex: _activeStep(state),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              SectionLabel(l10n.stepScan),
              BarcodeScannerPanel(
                lastScanned: _lastScanned,
                onCaptured: (String code) {
                  setState(() => _lastScanned = code);
                  context.read<FullAddBloc>().add(FullAddBarcodeChanged(code));
                  context.read<FullAddBloc>().add(
                    const FullAddLookupRequested(),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              TextField(
                controller: _barcodeCtrl,
                decoration: InputDecoration(labelText: l10n.barcode),
                onChanged: (String v) =>
                    context.read<FullAddBloc>().add(FullAddBarcodeChanged(v)),
                onSubmitted: (_) => context.read<FullAddBloc>().add(
                  const FullAddLookupRequested(),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSm),
              PrimaryButton(
                label: l10n.lookup,
                isLoading: state.lookingUp,
                onPressed: () => context.read<FullAddBloc>().add(
                  const FullAddLookupRequested(),
                ),
              ),
              if (state.lookingUp) ...<Widget>[
                const SizedBox(height: AppDimensions.spaceMd),
                const LookupResultSkeleton(),
              ],
              if (state.item != null) ...<Widget>[
                const SizedBox(height: AppDimensions.spaceMd),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        state.item!.itemNumber,
                        style: AppTextStyles.titleMd,
                      ),
                      Text(
                        state.item!.productName,
                        style: AppTextStyles.bodySm,
                      ),
                      const SizedBox(height: AppDimensions.spaceSm),
                      KeyValueRow(
                        label: l10n.price,
                        value: state.price == null
                            ? l10n.errorNoPrice
                            : '${AppFormat.price(state.price!.price)} ${state.price!.unitId}',
                        numeric: state.price != null,
                      ),
                      if (state.onHand != null) ...<Widget>[
                        KeyValueRow(
                          label: l10n.availableQty,
                          value:
                              '${AppFormat.quantity(state.onHand!.availableSalesQuantity)} ${state.onHand!.unit}',
                          numeric: true,
                        ),
                        const SizedBox(height: AppDimensions.spaceSm),
                        _stockChip(l10n, state.onHand!.availableSalesQuantity),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.spaceMd),
              PrimaryButton(
                label: l10n.getQuantity,
                isLoading: state.fetchingQty,
                onPressed: state.item == null
                    ? null
                    : () => context.read<FullAddBloc>().add(
                        const FullAddGetQtyRequested(),
                      ),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              SectionLabel(l10n.stepQuantity),
              QuantityStepper(
                controller: _qtyCtrl,
                max: state.onHand?.availableSalesQuantity.toInt(),
                onChanged: (String v) =>
                    context.read<FullAddBloc>().add(FullAddQuantityChanged(v)),
              ),
              if (state.validation != FullAddValidation.none)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spaceSm),
                  child: Text(
                    _validationMessage(l10n, state.validation),
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: AppDimensions.spaceLg),
              PrimaryButton(
                label: l10n.submit,
                isLoading: state.submitting,
                icon: Icons.check,
                onPressed: () => context.read<FullAddBloc>().add(
                  const FullAddSubmitRequested(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _activeStep(FullAddState state) {
    if (state.item == null) return 0;
    if (state.onHand == null || state.quantityText.isEmpty) return 1;
    return 2;
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

  String _validationMessage(AppLocalizations l10n, FullAddValidation v) {
    return switch (v) {
      FullAddValidation.barcodeRequired => l10n.errorBarcodeRequired,
      FullAddValidation.noPrice => l10n.errorNoPrice,
      FullAddValidation.noStock => l10n.errorNoStock,
      FullAddValidation.qtyInvalid => l10n.errorQtyInvalid,
      FullAddValidation.qtyExceeds => l10n.errorQtyExceeds,
      FullAddValidation.lookupRequired => l10n.errorLookupRequired,
      FullAddValidation.none => '',
    };
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.labels, required this.activeIndex});

  final List<String> labels;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < labels.length; i++) ...<Widget>[
          if (i > 0) const Expanded(child: Divider(color: AppColors.border)),
          Column(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: i <= activeIndex
                    ? AppColors.primary
                    : AppColors.neutral200,
                foregroundColor: i <= activeIndex
                    ? AppColors.textInverse
                    : AppColors.textSecondary,
                child: Text('${i + 1}', style: AppTextStyles.caption),
              ),
              const SizedBox(height: AppDimensions.spaceXs),
              Text(
                labels[i],
                style: AppTextStyles.caption.copyWith(
                  color: i <= activeIndex
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  fontWeight: i == activeIndex
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
