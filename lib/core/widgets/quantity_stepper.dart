import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Minus / field / plus quantity control with 48dp touch targets.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.controller,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int min;
  final int? max;
  final bool enabled;

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
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _StepButton(
          icon: Icons.remove,
          semanticsLabel: 'Decrease quantity',
          onPressed: enabled ? () => _step(-1) : null,
        ),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: AppTextStyles.numeric,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: AppDimensions.space12,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
        _StepButton(
          icon: Icons.add,
          semanticsLabel: 'Increase quantity',
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
          onPressed: onPressed,
          icon: Icon(icon),
          color: AppColors.primary,
          disabledColor: AppColors.neutral300,
        ),
      ),
    );
  }
}
