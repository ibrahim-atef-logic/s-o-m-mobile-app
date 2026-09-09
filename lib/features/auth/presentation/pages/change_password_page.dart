import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/app_hero_header.dart';
import '../../../../core/widgets/app_password_field.dart';
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
      appBar: AppGradientAppBar(title: Text(l10n.changePassword)),
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (BuildContext context, ChangePasswordState state) {
          if (state is ChangePasswordSuccess) {
            showAppSnackBar(
              context,
              message: l10n.passwordChanged,
              type: AppSnackBarType.success,
            );
          } else if (state is ChangePasswordFailure) {
            showAppSnackBar(
              context,
              message: l10n.errorPasswordChangeFailed,
              type: AppSnackBarType.error,
            );
          }
        },
        builder: (BuildContext context, ChangePasswordState state) {
          final bool loading = state is ChangePasswordSubmitting;
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.pageWash),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppHeroHeader(
                      title: l10n.changePassword,
                      subtitle: l10n.profileTitle,
                      icon: Icons.lock_reset_outlined,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceLg),
                      child: AppCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(AppDimensions.spaceLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            AppPasswordField(
                              controller: _old,
                              labelText: l10n.oldPassword,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.password,
                              ],
                              validator: (String? v) {
                                if (v == null || v.isEmpty) {
                                  return l10n.errorPasswordRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppDimensions.spaceMd),
                            AppPasswordField(
                              controller: _new,
                              labelText: l10n.newPassword,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[
                                AutofillHints.newPassword,
                              ],
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
                            AppPasswordField(
                              controller: _confirm,
                              labelText: l10n.confirmPassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const <String>[
                                AutofillHints.newPassword,
                              ],
                              onSubmitted: (_) => _submit(context),
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
                            const SizedBox(height: AppDimensions.spaceLg),
                            PrimaryButton(
                              label: l10n.save,
                              isLoading: loading,
                              icon: Icons.check,
                              onPressed: () => _submit(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ChangePasswordCubit>().submit(
      oldPassword: _old.text,
      newPassword: _new.text,
      confirmPassword: _confirm.text,
    );
  }
}
