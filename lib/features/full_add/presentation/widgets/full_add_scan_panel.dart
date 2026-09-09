import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/scanner/hardware_scan_listener.dart';
import '../../../../core/utils/scan_code.dart';
import '../../../../core/widgets/app_error_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/full_add_bloc.dart';
import 'full_add_scan_form.dart';

/// Inline scan / lookup / submit UI (composer, not a modal).
class FullAddScanPanel extends StatefulWidget {
  const FullAddScanPanel({this.onLineAdded, super.key});

  final VoidCallback? onLineAdded;

  @override
  State<FullAddScanPanel> createState() => _FullAddScanPanelState();
}

class _FullAddScanPanelState extends State<FullAddScanPanel> {
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _qtyCtrl;
  late final FocusNode _barcodeFocus;
  String? _lastScanned;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    final FullAddState state = context.read<FullAddBloc>().state;
    _barcodeCtrl = TextEditingController(text: state.barcode);
    _qtyCtrl = TextEditingController(text: state.quantityText);
    _barcodeFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _barcodeFocus.requestFocus();
      if (!ScanCode.isBlank(state.barcode) && state.item == null) {
        context.read<FullAddBloc>().add(const FullAddLookupRequested());
      }
    });
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _qtyCtrl.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  void _handleBarcode(String code) {
    if (!mounted) {
      return;
    }
    final String value = ScanCode.stripControls(code);
    if (ScanCode.isBlank(value)) {
      return;
    }
    setState(() => _lastScanned = value);
    _barcodeCtrl.text = value;
    final FullAddBloc bloc = context.read<FullAddBloc>();
    bloc.add(FullAddBarcodeChanged(value));
    bloc.add(const FullAddLookupRequested(byItem: false));
    _barcodeFocus.requestFocus();
  }

  void _commitQty(FullAddBloc bloc, FullAddState state) {
    if (!state.autoMode || state.item == null || state.submitting) {
      return;
    }
    bloc.add(const FullAddSubmitRequested());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return HardwareScanListener(
      onScan: _handleBarcode,
      child: BlocConsumer<FullAddBloc, FullAddState>(
        listenWhen: (FullAddState p, FullAddState c) =>
            c.submitSucceeded ||
            (c.failure != null && c.failure != p.failure) ||
            c.barcode != p.barcode ||
            c.quantityText != p.quantityText,
        listener: _onState,
        builder: (BuildContext context, FullAddState state) {
          final FullAddBloc bloc = context.read<FullAddBloc>();
          return FullAddScanForm(
            state: state,
            l10n: l10n,
            barcodeCtrl: _barcodeCtrl,
            qtyCtrl: _qtyCtrl,
            barcodeFocus: _barcodeFocus,
            lastScanned: _lastScanned,
            showCamera: _showCamera,
            onToggleCamera: () {
              setState(() => _showCamera = !_showCamera);
              if (!_showCamera) {
                _barcodeFocus.requestFocus();
              }
            },
            onCaptured: _handleBarcode,
            onBarcodeChanged: (String v) => bloc.add(FullAddBarcodeChanged(v)),
            onLookup: () => bloc.add(const FullAddLookupRequested()),
            onLookupByItem: (bool byItem) {
              bloc.add(FullAddLookupByItemChanged(byItem));
              _barcodeFocus.requestFocus();
            },
            onModeChanged: (bool auto) =>
                bloc.add(FullAddModeChanged(autoMode: auto)),
            onQtyChanged: (String v) => bloc.add(FullAddQuantityChanged(v)),
            onQtyCommitted: () => _commitQty(bloc, state),
            onAdd: () => bloc.add(const FullAddSubmitRequested()),
          );
        },
      ),
    );
  }

  void _onState(BuildContext context, FullAddState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FullAddBloc bloc = context.read<FullAddBloc>();
    if (state.barcode != _barcodeCtrl.text) {
      _barcodeCtrl.text = state.barcode;
    }
    if (state.quantityText != _qtyCtrl.text) {
      _qtyCtrl.text = state.quantityText;
    }
    if (state.submitSucceeded) {
      showAppSnackBar(
        context,
        message: l10n.lineAdded,
        type: AppSnackBarType.success,
      );
      bloc.add(const FullAddMessageCleared());
      bloc.add(const FullAddScanReset());
      _barcodeFocus.requestFocus();
      widget.onLineAdded?.call();
      return;
    }
    if (state.failure != null) {
      showFailureDetailsDialog(context, state.failure!, l10n: l10n);
      bloc.add(const FullAddMessageCleared());
    }
  }
}
