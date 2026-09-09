import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/add_flow_step_header.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_validation_text.dart';
import '../../../../core/widgets/barcode_scanner_panel.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/quick_add_bloc.dart';

class QuickAddScanPage extends StatefulWidget {
  const QuickAddScanPage({super.key});

  @override
  State<QuickAddScanPage> createState() => _QuickAddScanPageState();
}

class _QuickAddScanPageState extends State<QuickAddScanPage> {
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _qtyCtrl;
  String? _lastScanned;

  @override
  void initState() {
    super.initState();
    final QuickAddState state = context.read<QuickAddBloc>().state;
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
      appBar: AppGradientAppBar(title: Text(l10n.addItem)),
      body: BlocConsumer<QuickAddBloc, QuickAddState>(
        listenWhen: (QuickAddState p, QuickAddState c) =>
            c.lineAdded ||
            c.barcode != p.barcode ||
            c.quantityText != p.quantityText ||
            (c.failure != null && c.failure != p.failure),
        listener: (BuildContext context, QuickAddState state) {
          if (state.barcode != _barcodeCtrl.text) {
            _barcodeCtrl.text = state.barcode;
          }
          if (state.quantityText != _qtyCtrl.text) {
            _qtyCtrl.text = state.quantityText;
          }
          if (state.lineAdded) {
            showAppSnackBar(
              context,
              message: l10n.lineAdded,
              type: AppSnackBarType.success,
            );
            _barcodeCtrl.clear();
            _qtyCtrl.text = '1';
            context.read<QuickAddBloc>().add(const QuickAddMessageCleared());
            context.pop();
            return;
          }
          if (state.failure != null) {
            showFailureSnackBar(context, state.failure!, l10n: l10n);
            context.read<QuickAddBloc>().add(const QuickAddMessageCleared());
          }
        },
        builder: (BuildContext context, QuickAddState state) {
          final int step = state.barcode.trim().isEmpty
              ? 0
              : (state.quantityText.trim().isEmpty ? 1 : 2);
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.pageWash),
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              children: <Widget>[
                AddFlowStepHeader(
                  labels: <String>[
                    l10n.stepScan,
                    l10n.stepQuantity,
                    l10n.stepAdd,
                  ],
                  activeIndex: step,
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      BarcodeScannerPanel(
                        lastScanned: _lastScanned,
                        onCaptured: (String code) {
                          setState(() => _lastScanned = code);
                          context.read<QuickAddBloc>().add(
                            QuickAddBarcodeChanged(code),
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      TextField(
                        controller: _barcodeCtrl,
                        decoration: InputDecoration(labelText: l10n.barcode),
                        onChanged: (String v) => context
                            .read<QuickAddBloc>()
                            .add(QuickAddBarcodeChanged(v)),
                      ),
                    ],
                  ),
                ),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SectionLabel(l10n.quantity),
                      QuantityStepper(
                        controller: _qtyCtrl,
                        onChanged: (String v) => context
                            .read<QuickAddBloc>()
                            .add(QuickAddQuantityChanged(v)),
                      ),
                      AppValidationText(
                        _validationMessage(l10n, state.validation),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                PrimaryButton(
                  label: l10n.addToCart,
                  icon: Icons.add_shopping_cart_outlined,
                  onPressed: () => context.read<QuickAddBloc>().add(
                    const QuickAddLineAdded(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _validationMessage(AppLocalizations l10n, QuickAddValidation v) {
    return switch (v) {
      QuickAddValidation.barcodeRequired => l10n.errorBarcodeRequired,
      QuickAddValidation.qtyInvalid => l10n.errorQtyInvalid,
      QuickAddValidation.maxLines => l10n.errorMaxQuickLines,
      QuickAddValidation.emptyCart => l10n.cartEmpty,
      QuickAddValidation.none => null,
    };
  }
}
