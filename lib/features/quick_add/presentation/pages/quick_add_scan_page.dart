import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/barcode_scanner_panel.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
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
      appBar: AppBar(title: Text(l10n.addItem)),
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
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
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
                onChanged: (String v) =>
                    context.read<QuickAddBloc>().add(QuickAddBarcodeChanged(v)),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              Text(l10n.quantity),
              const SizedBox(height: AppDimensions.spaceSm),
              QuantityStepper(
                controller: _qtyCtrl,
                onChanged: (String v) => context.read<QuickAddBloc>().add(
                  QuickAddQuantityChanged(v),
                ),
              ),
              if (state.validation != QuickAddValidation.none)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spaceSm),
                  child: Text(
                    _validationMessage(l10n, state.validation),
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: AppDimensions.spaceLg),
              PrimaryButton(
                label: l10n.addToCart,
                onPressed: () =>
                    context.read<QuickAddBloc>().add(const QuickAddLineAdded()),
              ),
            ],
          );
        },
      ),
    );
  }

  String _validationMessage(AppLocalizations l10n, QuickAddValidation v) {
    return switch (v) {
      QuickAddValidation.barcodeRequired => l10n.errorBarcodeRequired,
      QuickAddValidation.qtyInvalid => l10n.errorQtyInvalid,
      QuickAddValidation.maxLines => l10n.errorMaxQuickLines,
      QuickAddValidation.emptyCart => l10n.cartEmpty,
      QuickAddValidation.none => '',
    };
  }
}
