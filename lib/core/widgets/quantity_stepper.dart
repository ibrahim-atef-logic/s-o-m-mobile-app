import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Minus / field / plus quantity control with 48dp touch targets.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.controller,
    required this.onChanged,
    this.onCommitted,
    this.min = 1,
    this.max,
    this.enabled = true,
    this.showButtons = true,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCommitted;
  final int min;
  final int? max;
  final bool enabled;

  /// When false (auto add mode), only the numeric field is shown.
  final bool showButtons;

  int get _current {
    return int.tryParse(controller.text.trim()) ?? min;
  }

  void _step(int delta) {
    if (!enabled) return;
    int next = _current + delta;
    if (next < min) next = min;
    if (max != null && next > max!) next = max!;
    controller.text = '$next';
    onChanged(controller.text);
    onCommitted?.call(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Widget field = TextField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      style: context.numericStyle,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: AppDimensions.space12,
        ),
      ),
      onChanged: onChanged,
      onSubmitted: (_) => onCommitted?.call(controller.text),
      textInputAction: TextInputAction.done,
    );
    if (!showButtons) {
      return field;
    }
    return Row(
      children: <Widget>[
        _StepButton(
          icon: Icons.remove,
          semanticsLabel: l10n.decreaseQuantity,
          onPressed: enabled ? () => _step(-1) : null,
        ),
        Expanded(child: field),
        _StepButton(
          icon: Icons.add,
          semanticsLabel: l10n.increaseQuantity,
          onPressed: enabled ? () => _step(1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: SizedBox(
        width: AppDimensions.minTouchTarget,
        height: AppDimensions.minTouchTarget,
        child: IconButton(
          tooltip: semanticsLabel,
          onPressed: onPressed,
          icon: Icon(icon),
          color: AppColors.primary,
          disabledColor: AppColors.neutral300,
        ),
      ),
    );
  }
}
