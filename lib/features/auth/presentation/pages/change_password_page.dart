import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/change_password_cubit.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _old = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (BuildContext context, ChangePasswordState state) {
          if (state is ChangePasswordSuccess) {
            showAppSnackBar(
              context,
              message: state.message.isEmpty ? l10n.passwordChanged : state.message,
              type: AppSnackBarType.success,
            );
          } else if (state is ChangePasswordFailure) {
            showFailureSnackBar(context, state.failure, l10n: l10n);
          }
        },
        builder: (BuildContext context, ChangePasswordState state) {
          final bool loading = state is ChangePasswordSubmitting;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _old,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.oldPassword),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return l10n.errorPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  TextFormField(
                    controller: _new,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.newPassword),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return l10n.errorPasswordRequired;
                      }
                      if (v == _old.text) {
                        return l10n.errorPasswordSameAsOld;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.confirmPassword),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return l10n.errorPasswordRequired;
                      }
                      if (v != _new.text) {
                        return l10n.errorPasswordMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceXl),
                  PrimaryButton(
                    label: l10n.save,
                    isLoading: loading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      context.read<ChangePasswordCubit>().submit(
                        oldPassword: _old.text,
                        newPassword: _new.text,
                        confirmPassword: _confirm.text,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
