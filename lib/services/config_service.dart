/// Typed Remote Config values (D17). Defaults must match
/// firebase/remote-config-template.json.
class AppConfig {
  const AppConfig({required this.aiMatchingEnabled, required this.maxProposalsShown});

  static const defaults = AppConfig(aiMatchingEnabled: true, maxProposalsShown: 3);

  /// Shows or hides "Match with AI" on S3, S4, S5.
  final bool aiMatchingEnabled;

  /// Number of proposal cards on S9.
  final int maxProposalsShown;
}

/// Owner: Dan.
abstract interface class ConfigService {
  AppConfig get current;

  /// Emits the current value, then every activated change (realtime updates).
  Stream<AppConfig> watch();

  /// Fetch + activate; on failure keeps the last or default values.
  Future<void> refresh();

  /// Shown on the demo area: "default", "remote", "static"...
  String get lastFetchStatus;
}
