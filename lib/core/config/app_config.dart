/// App-wide runtime configuration.
class AppConfig {
  /// The Go backend isn't deployed yet, so repositories default to their
  /// in-memory Fake data source instead of making real network calls.
  ///
  /// Flip this off once the backend is reachable — either edit the default
  /// below, or build with `--dart-define=USE_FAKE_BACKEND=false` to switch
  /// without touching code.
  static const bool useFakeBackend = bool.fromEnvironment(
    'USE_FAKE_BACKEND',
    defaultValue: true,
  );
}
