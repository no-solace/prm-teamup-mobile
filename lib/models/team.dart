import 'major.dart';

/// A team inside a class (classes/{classId}/teams/{teamId}).
class Team {
  const Team({
    required this.id,
    required this.classId,
    required this.name,
    required this.memberIds,
    required this.majors,
  });

  final String id;
  final String classId;
  final String name;

  /// Student IDs (MSSV) of the members.
  final List<String> memberIds;

  /// Major of each member, same order as [memberIds].
  final List<Major> majors;

  int get size => memberIds.length;
  bool get isFull => size >= TeamRules.maxMembers;
  bool get needsMembers => size < TeamRules.minMembers;
  int get distinctMajors => majors.toSet().length;

  /// Majors the team does not have yet (S5 "Needs ...").
  Set<Major> get missingMajors => Major.values.toSet().difference(majors.toSet());
}
