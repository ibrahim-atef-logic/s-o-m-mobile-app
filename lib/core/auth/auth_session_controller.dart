/// Lets the Dio interceptor notify the app AuthBloc of a dead session.
class AuthSessionController {
  void Function()? onExpired;

  void notifyExpired() {
    onExpired?.call();
  }
}
