import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _company = TextEditingController();
  final TextEditingController _personnel = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _company.dispose();
    _personnel.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (AuthState p, AuthState c) => c is AuthFailureState,
        listener: (BuildContext context, AuthState state) {
          if (state is AuthFailureState) {
            showFailureSnackBar(context, state.failure, l10n: l10n);
          }
        },
        builder: (BuildContext context, AuthState state) {
          final bool loading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppDimensions.spaceXl),
                  const Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  Text(
                    l10n.loginTitle,
                    style: AppTextStyles.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spaceXl),
                  TextFormField(
                    controller: _company,
                    decoration: InputDecoration(
                      labelText: l10n.companyCode,
                      prefixIcon: const Icon(Icons.business_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.errorCompanyRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  TextFormField(
                    controller: _personnel,
                    decoration: InputDecoration(
                      labelText: l10n.personnelNumber,
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
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
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: Semantics(
                        label: _obscure ? l10n.showPassword : l10n.hidePassword,
                        button: true,
                        child: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    obscureText: _obscure,
                    autofillHints: const <String>[AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(context),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return l10n.errorPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceXl),
                  PrimaryButton(
                    label: l10n.login,
                    isLoading: loading,
                    onPressed: () => _submit(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginSubmitted(
            company: _company.text,
            personnelNumber: _personnel.text.trim(),
            password: _password.text,
          ),
        );
  }
}
