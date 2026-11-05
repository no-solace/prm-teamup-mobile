import '../models/proposal.dart';
import '../models/student.dart';
import '../models/team.dart';
import 'app_error.dart';
import 'matching_service.dart';

/// Owner: Dan. The real Lab 3 matching (no ML model, as in Lab 2):
/// - only students without a team, only teams with room (R2);
/// - prefer teams missing a major, aim for 5..6 members and >= 3 majors (R1, R3).
/// Pure Dart: test it in test/services/rule_based_matching_service_test.dart.
class RuleBasedMatchingService implements MatchingService {
  @override
  Future<List<Proposal>> propose({
    required String classId,
    required List<Student> students,
    required List<Team> teams,
  }) async {
    // TODO(Dan): implement and unit test.
    throw const UnknownError('Matching not implemented yet');
  }
}
