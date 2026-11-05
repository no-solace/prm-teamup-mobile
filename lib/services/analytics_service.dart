/// Owner: Khang. One method per event in docs/analytics-plan.md (D17).
/// Parameters never contain e-mail or names (no PII).
abstract interface class AnalyticsService {
  Future<void> setUser(String uid);

  Future<void> logLogin();

  Future<void> logLogout();

  Future<void> logClassImport({required int rowCount, required int availableCount});

  /// itemCategory: class | student | proposal
  Future<void> logViewItem({required String itemCategory, required String itemId});

  Future<void> logAiMatchStart({required int studentCount, required int teamCount});

  Future<void> logAiMatchResult({required int proposalCount, required bool noMatch, required int durationMs});

  Future<void> logProposalApprove({required int memberCount, required int majorCount, required String source, required bool edited});

  Future<void> logProposalDiscard({required String source});

  /// reason: max_6 | min_5
  Future<void> logMemberChangeBlocked({required String reason});

  Future<void> logReportExport({required int teamCount, required int fileSizeKb});
}
