/// Typed Remote Config values (D17). Defaults must match
/// firebase/remote-config-defaults.json (bundled as an asset).
class AppConfig {
  const AppConfig({
    required this.aiMatchingEnabled,
    required this.maxProposalsShown,
    this.maxTopicRevisions = 3,
    this.defaultMeetingDurationMinutes = 30,
  });

  static const defaults = AppConfig(
    aiMatchingEnabled: true,
    maxProposalsShown: 3,
  );

  factory AppConfig.fromValues(Map<String, dynamic> values) => AppConfig(
    aiMatchingEnabled: values['ai_matching_enabled'] is bool
        ? values['ai_matching_enabled'] as bool
        : defaults.aiMatchingEnabled,
    maxProposalsShown: values['max_proposals_shown'] is num
        ? (values['max_proposals_shown'] as num).toInt().clamp(1, 20)
        : defaults.maxProposalsShown,
    maxTopicRevisions: values['max_topic_revisions'] is num
        ? (values['max_topic_revisions'] as num).toInt().clamp(0, 10)
        : defaults.maxTopicRevisions,
    defaultMeetingDurationMinutes:
        values['default_meeting_duration_minutes'] is num
        ? (values['default_meeting_duration_minutes'] as num).toInt().clamp(15, 120)
        : defaults.defaultMeetingDurationMinutes,
  );

  /// Flow D: how many times a leader may resubmit a topic.
  final int maxTopicRevisions;

  /// Flow E: length of a new availability slot.
  final int defaultMeetingDurationMinutes;

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
