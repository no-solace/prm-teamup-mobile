import 'data_validation.dart';
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

  factory Student.fromMap(String mssv, String classId, Map<String, dynamic> data) {
    final major = Major.fromCode(DataValidation.text(data, 'major', max: 3));
    if (major == null) throw const FormatException('Invalid major');
    final teamId = DataValidation.optionalText(data, 'teamId', max: 64);
    return Student(
      mssv: DataValidation.id(mssv),
      classId: DataValidation.id(classId),
      fullName: DataValidation.text(data, 'fullName'),
      major: major,
      teamId: teamId == null ? null : DataValidation.id(teamId),
      semester: DataValidation.optionalText(data, 'semester'),
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'major': major.code,
        'teamId': teamId,
        if (semester != null) 'semester': semester,
      };

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
