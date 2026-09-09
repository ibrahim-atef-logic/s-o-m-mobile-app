import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login_form_card.dart';
import '../widgets/login_hero.dart';
import '../widgets/login_sheet.dart';

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
    final bool compact = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (AuthState p, AuthState c) => c is AuthFailureState,
          listener: (BuildContext context, AuthState state) {
            if (state is AuthFailureState) {
              showFailureSnackBar(context, state.failure, l10n: l10n);
            }
          },
          builder: (BuildContext context, AuthState state) {
            return DecoratedBox(
              decoration: const BoxDecoration(gradient: AppGradients.brand),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LoginHero(compact: compact),
                  Expanded(
                    child: LoginSheet(
                      child: LoginFormCard(
                        formKey: _formKey,
                        company: _company,
                        personnel: _personnel,
                        password: _password,
                        isLoading: state is AuthLoading,
                        onSubmit: () => _submit(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    TextInput.finishAutofillContext();
    context.read<AuthBloc>().add(
      AuthLoginSubmitted(
        company: _company.text,
        personnelNumber: _personnel.text.trim(),
        password: _password.text,
      ),
    );
  }
}
