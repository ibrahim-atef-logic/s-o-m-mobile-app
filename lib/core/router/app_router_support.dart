import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/states/app_empty_view.dart';

enum MissingRouteKind { order, session }

class MissingRouteScaffold extends StatelessWidget {
  const MissingRouteScaffold({required this.kind, super.key});

  final MissingRouteKind kind;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String message = switch (kind) {
      MissingRouteKind.order => l10n.errorMissingOrder,
      MissingRouteKind.session => l10n.errorMissingSession,
    };
    return Scaffold(
      body: AppEmptyView(title: message, icon: Icons.warning_amber_outlined),
    );
  }
}

class GoRouterAuthRefresh extends ChangeNotifier {
  GoRouterAuthRefresh(AuthBloc bloc) {
    _sub = bloc.stream.listen((AuthState _) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
