import '../../models/proposal.dart';
import '../../models/student.dart';
import '../../models/team.dart';
import '../matching_service.dart';
import '../rule_based_matching_service.dart';
import 'sample_data.dart';

/// Returns the 3 proposals from Figma S9 (or none, to show S15).
class FakeMatchingService implements MatchingService {
  FakeMatchingService({this.noMatch = false, this.latency = const Duration(seconds: 2)});

  final bool noMatch;
  final Duration latency;

  @override
  Future<List<Proposal>> propose({
    required String classId,
    required List<Student> students,
    required List<Team> teams,
  }) async {
    await Future<void>.delayed(latency);
    if (noMatch) return const [];
    if (classId != 'class-a') {
      return RuleBasedMatchingService().propose(
        classId: classId,
        students: students,
        teams: teams,
      );
    }
    return SampleData.proposals(students, teams);
  }
}
