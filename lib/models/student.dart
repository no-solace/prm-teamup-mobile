import 'major.dart';

/// A student row from the imported class list (classes/{classId}/students/{mssv}).
/// Students never use the app; they are data only (Lab 2 screen-spec).
class Student {
  const Student({
    required this.mssv,
    required this.fullName,
    required this.major,
    required this.classId,
    this.teamId,
    this.semester,
  });

  /// Student ID: unique key (Lab 2 import column "MSSV").
  final String mssv;
  final String fullName;
  final Major major;
  final String classId;

  /// Null means "No team" (R2).
  final String? teamId;

  /// For example "S5" on S4/S7.
  final String? semester;

  bool get hasTeam => teamId != null;

  Student copyWith({String? teamId, bool clearTeam = false}) => Student(
        mssv: mssv,
        fullName: fullName,
        major: major,
        classId: classId,
        teamId: clearTeam ? null : (teamId ?? this.teamId),
        semester: semester,
      );
}
