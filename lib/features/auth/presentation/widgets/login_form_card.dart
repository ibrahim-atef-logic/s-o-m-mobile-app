import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_password_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

/// Login credentials: company, personnel, password, submit.
class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    required this.formKey,
    required this.company,
    required this.personnel,
    required this.password,
    required this.isLoading,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController company;
  final TextEditingController personnel;
  final TextEditingController password;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceLg,
            AppDimensions.spaceMd,
            AppDimensions.spaceLg,
            AppDimensions.spaceLg,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: <Widget>[
            _CredentialFields(
              company: company,
              personnel: personnel,
              password: password,
              isLoading: isLoading,
              onSubmit: onSubmit,
            ),
            const SizedBox(height: AppDimensions.spaceXl),
            PrimaryButton(
              label: AppLocalizations.of(context).login,
              isLoading: isLoading,
              icon: Icons.arrow_forward_rounded,
              onPressed: onSubmit,
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            const _LoginSecureHint(),
          ],
        ),
      ),
    );
  }
}

class _CredentialFields extends StatelessWidget {
  const _CredentialFields({
    required this.company,
    required this.personnel,
    required this.password,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController company;
  final TextEditingController personnel;
  final TextEditingController password;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          controller: company,
          enabled: !isLoading,
          labelText: l10n.companyCode,
          hintText: l10n.companyCodeHint,
          prefixIcon: const Icon(Icons.apartment_outlined),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const <String>[AutofillHints.organizationName],
          validator: (String? v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.errorCompanyRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        AppTextField(
          controller: personnel,
          enabled: !isLoading,
          labelText: l10n.personnelNumber,
          hintText: l10n.personnelNumberHint,
          prefixIcon: const Icon(Icons.badge_outlined),
          keyboardType: TextInputType.text,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          autofillHints: const <String>[AutofillHints.username],
          textInputAction: TextInputAction.next,
          validator: (String? v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.errorPersonnelRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        AppPasswordField(
          controller: password,
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.password],
          onSubmitted: (_) => onSubmit(),
          validator: (String? v) {
            if (v == null || v.isEmpty) {
              return l10n.errorPasswordRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _LoginSecureHint extends StatelessWidget {
  const _LoginSecureHint();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(
          Icons.lock_outline_rounded,
          size: AppDimensions.iconSm,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Expanded(
          child: Text(
            l10n.loginSecureHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }
}
