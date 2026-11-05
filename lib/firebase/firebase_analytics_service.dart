import 'package:firebase_analytics/firebase_analytics.dart';

import '../services/analytics_service.dart';

/// Owner: Khang. Event names and parameters follow docs/analytics-plan.md.
/// Analytics only accepts String and num parameters, so bools are sent as 0/1.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics}) : _a = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _a;

  Future<void> _log(String name, Map<String, Object> params) => _a.logEvent(name: name, parameters: params);

  static int _b(bool v) => v ? 1 : 0;

  @override
  Future<void> setUser(String uid) => _a.setUserId(id: uid);

  @override
  Future<void> logLogin() => _a.logLogin(loginMethod: 'google');

  @override
  Future<void> logLogout() => _log('logout', {});

  @override
  Future<void> logClassImport({required int rowCount, required int availableCount}) =>
      _log('class_import', {'row_count': rowCount, 'available_count': availableCount});

  @override
  Future<void> logViewItem({required String itemCategory, required String itemId}) =>
      _log('view_item', {'item_category': itemCategory, 'item_id': itemId});

  @override
  Future<void> logAiMatchStart({required int studentCount, required int teamCount}) =>
      _log('ai_match_start', {'student_count': studentCount, 'team_count': teamCount});

  @override
  Future<void> logAiMatchResult({required int proposalCount, required bool noMatch, required int durationMs}) =>
      _log('ai_match_result', {'proposal_count': proposalCount, 'no_match': _b(noMatch), 'duration_ms': durationMs});

  @override
  Future<void> logProposalApprove(
          {required int memberCount, required int majorCount, required String source, required bool edited}) =>
      _log('proposal_approve',
          {'member_count': memberCount, 'major_count': majorCount, 'source': source, 'edited': _b(edited)});

  @override
  Future<void> logProposalDiscard({required String source}) => _log('proposal_discard', {'source': source});

  @override
  Future<void> logMemberChangeBlocked({required String reason}) => _log('member_change_blocked', {'reason': reason});

  @override
  Future<void> logReportExport({required int teamCount, required int fileSizeKb}) =>
      _log('report_export', {'team_count': teamCount, 'file_size_kb': fileSizeKb});
}
