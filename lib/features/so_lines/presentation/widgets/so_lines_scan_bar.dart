import 'package:flutter/material.dart';

import '../../../../core/scanner/hardware_scan_listener.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/scan_code.dart';
import '../../../../l10n/app_localizations.dart';

enum SoLineSearchMode { barcode, item }

/// Browse-mode filter bar. Hardware or submit enters add mode.
class SoLinesScanBar extends StatefulWidget {
  const SoLinesScanBar({
    required this.onItemFilter,
    required this.onEnterAdd,
    super.key,
  });

  final ValueChanged<String> onItemFilter;
  final void Function({required String code, required bool byItem}) onEnterAdd;

  @override
  State<SoLinesScanBar> createState() => _SoLinesScanBarState();
}

class _SoLinesScanBarState extends State<SoLinesScanBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  SoLineSearchMode _mode = SoLineSearchMode.barcode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onHardware(String raw) {
    final String value = ScanCode.stripControls(raw);
    if (ScanCode.isBlank(value)) {
      return;
    }
    _controller.text = value;
    widget.onItemFilter('');
    widget.onEnterAdd(code: value, byItem: false);
  }

  void _submit(String raw) {
    final String value = ScanCode.stripControls(raw);
    if (ScanCode.isBlank(value)) {
      widget.onItemFilter('');
      return;
    }
    final bool byItem = _mode == SoLineSearchMode.item;
    if (byItem) {
      widget.onItemFilter(value);
    } else {
      widget.onItemFilter('');
    }
    widget.onEnterAdd(code: value, byItem: byItem);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return HardwareScanListener(
      onScan: _onHardware,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spaceMd,
          AppDimensions.spaceSm,
          AppDimensions.spaceMd,
          0,
        ),
        child: Column(
          children: <Widget>[
            SegmentedButton<SoLineSearchMode>(
              segments: <ButtonSegment<SoLineSearchMode>>[
                ButtonSegment<SoLineSearchMode>(
                  value: SoLineSearchMode.barcode,
                  label: Text(l10n.searchByBarcode),
                  icon: const Icon(Icons.qr_code_2_outlined),
                ),
                ButtonSegment<SoLineSearchMode>(
                  value: SoLineSearchMode.item,
                  label: Text(l10n.searchByItem),
                  icon: const Icon(Icons.inventory_2_outlined),
                ),
              ],
              selected: <SoLineSearchMode>{_mode},
              onSelectionChanged: (Set<SoLineSearchMode> next) {
                setState(() => _mode = next.first);
                _focus.requestFocus();
              },
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: _mode == SoLineSearchMode.barcode
                    ? l10n.barcode
                    : l10n.searchByItem,
                prefixIcon: const Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (String v) {
                if (_mode == SoLineSearchMode.item) {
                  widget.onItemFilter(v);
                }
              },
              onSubmitted: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
