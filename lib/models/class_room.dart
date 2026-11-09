import 'data_validation.dart';

/// A class imported by a mentor (classes/{classId}).
/// Counts on S2/S3 are computed from students and teams (D11), not stored.
class ClassRoom {
  const ClassRoom({
    required this.id,
    required this.name,
    required this.mentorUid,
    this.studentCount = 0,
    this.withoutTeamCount = 0,
    this.teamsNeedingMembers = 0,
  });

  final String id;
  final String name;
  final String mentorUid;
  final int studentCount;
  final int withoutTeamCount;
  final int teamsNeedingMembers;

  factory ClassRoom.fromMap(String id, Map<String, dynamic> data) => ClassRoom(
        id: DataValidation.id(id),
        name: DataValidation.text(data, 'name'),
        mentorUid: DataValidation.text(data, 'mentorUid', max: 128),
      );

  /// Counts are derived, never persisted.
  Map<String, dynamic> toMap() => {'name': name, 'mentorUid': mentorUid};

  bool get allMatched => withoutTeamCount == 0 && teamsNeedingMembers == 0;

  ClassRoom copyWith({int? studentCount, int? withoutTeamCount, int? teamsNeedingMembers}) => ClassRoom(
        id: id,
        name: name,
        mentorUid: mentorUid,
        studentCount: studentCount ?? this.studentCount,
        withoutTeamCount: withoutTeamCount ?? this.withoutTeamCount,
        teamsNeedingMembers: teamsNeedingMembers ?? this.teamsNeedingMembers,
      );
}
