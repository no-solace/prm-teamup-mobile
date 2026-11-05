import '../models/proposal.dart';
import '../models/student.dart';
import '../models/team.dart';

/// Owner: Dan. The "AI" of Lab 3: rule-based matching by major (R1-R3).
/// Pure Dart so it can be unit tested and, in Final, replaced by Gemini.
abstract interface class MatchingService {
  /// Returns proposals that put students without a team into teams with room.
  /// An empty list means "No match" (S15).
  Future<List<Proposal>> propose({
    required String classId,
    required List<Student> students,
    required List<Team> teams,
  });
}
