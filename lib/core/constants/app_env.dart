/// Runtime environment flags injected via `--dart-define`.
abstract final class AppEnv {
  static const String name = String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDev => name == 'dev';
  static bool get isStaging => name == 'staging';
  static bool get isProd => name == 'prod';
}
