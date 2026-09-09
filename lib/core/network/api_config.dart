/// Points the app at the Jobfy backend (Go REST API).
///
/// Override at build/run time, e.g.:
///   flutter run --dart-define=API_BASE_URL=https://api.jobfy.app/v1
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const Duration timeout = Duration(seconds: 15);
}
