import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/widgets/app_gradient_app_bar.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../core/widgets/states/app_error_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/profile_body.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthProfileOpened());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppGradientAppBar(title: Text(l10n.profileTitle)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState state) {
          return switch (state) {
            AuthInitial() ||
            AuthLoading() => const Center(child: CircularProgressIndicator()),
            AuthFailureState(:final failure) => AppErrorView(
              title: failure.localizedTitle(l10n),
              message: failure.localizedMessage(l10n),
              details: failure.technicalDetails,
              onRetry: () =>
                  context.read<AuthBloc>().add(const AuthProfileOpened()),
            ),
            AuthUnauthenticated() => AppEmptyView(
              title: l10n.loginTitle,
              description: l10n.helloSubtitle,
              icon: Icons.person_off_outlined,
            ),
            AuthAuthenticated(:final session) => ProfileBody(
              session: session,
              l10n: l10n,
            ),
          };
        },
      ),
    );
  }
}
