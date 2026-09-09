import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_text_field.dart';

/// Password field with show/hide toggle matching Login chrome.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.controller,
    this.labelText,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppTextField(
      controller: widget.controller,
      labelText: widget.labelText ?? l10n.password,
      obscureText: _obscure,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onSubmitted: widget.onSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: Semantics(
        label: _obscure ? l10n.showPassword : l10n.hidePassword,
        button: true,
        child: IconButton(
          tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
