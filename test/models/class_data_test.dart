import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/class_room.dart';
import 'package:teamup_exe/models/student.dart';
import 'package:teamup_exe/models/team.dart';

void main() {
  test('class map omits all derived counts', () {
    const room = ClassRoom(id: 'a', name: 'Class A', mentorUid: 'u', studentCount: 9);
    expect(room.toMap(), {'name': 'Class A', 'mentorUid': 'u'});
    expect(ClassRoom.fromMap('a', room.toMap()).studentCount, 0);
  });
  test('student round trip uses path IDs and nullable group', () {
    final student = Student.fromMap('001', 'a', {'fullName': 'An', 'major': 'SE', 'teamId': null});
    expect(student.hasTeam, isFalse);
    expect(Student.fromMap('001', 'a', student.copyWith(teamId: '1').toMap()).teamId, '1');
  });
  test('unknown major and invalid paths are rejected', () {
    expect(() => Student.fromMap('001', 'a', {'fullName': 'An', 'major': 'X', 'teamId': null}), throwsFormatException);
    expect(() => ClassRoom.fromMap('../x', {'name': 'A', 'mentorUid': 'u'}), throwsFormatException);
  });
  test('team parallel arrays and duplicate IDs are validated', () {
    expect(() => Team.fromMap('1', 'a', {'name': 'One', 'memberIds': ['1'], 'majors': []}), throwsFormatException);
    expect(() => Team.fromMap('1', 'a', {'name': 'One', 'memberIds': ['1', '1'], 'majors': ['SE', 'AI']}), throwsFormatException);
    expect(() => Team.fromMap('1', 'a', {'name': 'One', 'memberIds': [123], 'majors': ['SE']}), throwsFormatException);
  });
  test('5-member team remains an available target until full', () {
    final team = Team.fromMap('1', 'a', {
      'name': 'One', 'memberIds': ['1', '2', '3', '4', '5'], 'majors': ['SE', 'SE', 'SE', 'AI', 'GD'],
    });
    expect(team.needsMembers, isFalse);
    expect(team.isFull, isFalse);
    expect(team.distinctMajors, 3);
    expect(Team.fromMap('1', 'a', team.toMap()).size, 5);
    expect(() => team.memberIds.add('6'), throwsUnsupportedError);
  });
}
