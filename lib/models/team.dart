import 'data_validation.dart';
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

  factory Team.fromMap(String id, String classId, Map<String, dynamic> data) {
    final members = data['memberIds'];
    final codes = data['majors'];
    if (members is! List || codes is! List ||
        members.length > TeamRules.maxMembers || members.length != codes.length ||
        members.toSet().length != members.length) {
      throw const FormatException('Invalid team members');
    }
    final ids = <String>[];
    final majors = <Major>[];
    for (var i = 0; i < members.length; i++) {
      final member = members[i];
      final code = codes[i];
      if (member is! String || code is! String) {
        throw const FormatException('Invalid team member');
      }
      ids.add(DataValidation.id(member));
      final major = Major.fromCode(code);
      if (major == null) throw const FormatException('Invalid major');
      majors.add(major);
    }
    return Team(
      id: DataValidation.id(id),
      classId: DataValidation.id(classId),
      name: DataValidation.text(data, 'name'),
      memberIds: List.unmodifiable(ids),
      majors: List.unmodifiable(majors),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'memberIds': List<String>.of(memberIds),
        'majors': [for (final major in majors) major.code],
      };

  int get size => memberIds.length;
  bool get isFull => size >= TeamRules.maxMembers;
  bool get needsMembers => size < TeamRules.minMembers;
  int get distinctMajors => majors.toSet().length;

  /// Majors the team does not have yet (S5 "Needs ...").
  Set<Major> get missingMajors => Major.values.toSet().difference(majors.toSet());
}
