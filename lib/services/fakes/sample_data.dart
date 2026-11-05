import '../../models/class_room.dart';
import '../../models/major.dart';
import '../../models/proposal.dart';
import '../../models/student.dart';
import '../../models/team.dart';

/// Sample data shaped like the Lab 2 Figma screens (Class A, Tutor Match,
/// GreenLoop, FinLite...). Used ONLY by fakes: never by main.dart (C10).
abstract final class SampleData {
  static const mentorUid = 'fake-mentor';

  static const classes = [
    ClassRoom(id: 'class-a', name: 'Class A', mentorUid: mentorUid),
    ClassRoom(id: 'class-b', name: 'Class B', mentorUid: mentorUid),
    ClassRoom(id: 'class-c', name: 'Class C', mentorUid: mentorUid),
  ];

  static List<Student> students() => [
        // Without team (S4)
        _s('190401', 'Minh Anh', Major.gd),
        _s('190402', 'Bao Tran', Major.se),
        _s('190403', 'Lan Vo', Major.ai),
        _s('190404', 'Hoa Le', Major.mkt),
        _s('190412', 'Thu Nguyen', Major.mkt),
        // Tutor Match (4 members)
        _s('190501', 'An Pham', Major.se, 'team-tutor'),
        _s('190502', 'Binh Do', Major.se, 'team-tutor'),
        _s('190503', 'Chi Ho', Major.ai, 'team-tutor'),
        _s('190504', 'Duc Pham', Major.mkt, 'team-tutor'),
        // GreenLoop (4 members)
        _s('190601', 'Em Vu', Major.se, 'team-green'),
        _s('190602', 'Giang Ly', Major.ai, 'team-green'),
        _s('190603', 'Hung Mai', Major.ai, 'team-green'),
        _s('190604', 'Khoa Tran', Major.se, 'team-green'),
        // FinLite (4 members)
        _s('190701', 'Linh Bui', Major.mkt, 'team-fin'),
        _s('190702', 'My Dang', Major.se, 'team-fin'),
        _s('190703', 'Nam Cao', Major.gd, 'team-fin'),
        _s('190704', 'Oanh Ta', Major.se, 'team-fin'),
      ];

  static List<Team> teams(List<Student> all) {
    Team build(String id, String name) {
      final members = all.where((s) => s.teamId == id).toList();
      return Team(
        id: id,
        classId: 'class-a',
        name: name,
        memberIds: [for (final m in members) m.mssv],
        majors: [for (final m in members) m.major],
      );
    }

    return [
      build('team-tutor', 'Tutor Match'),
      build('team-green', 'GreenLoop'),
      build('team-fin', 'FinLite'),
    ];
  }

  static List<Proposal> proposals(List<Student> all, List<Team> teams) {
    Proposal build(String id, Team t, Student add, ProposalFit fit) => Proposal(
          id: id,
          classId: 'class-a',
          teamId: t.id,
          teamName: t.name,
          currentMemberIds: t.memberIds,
          currentMajors: t.majors,
          addStudentIds: [add.mssv],
          addMajors: [add.major],
          fit: fit,
          reasons: [
            'Adds ${add.major.code}, a major the team is missing',
            'Team reaches ${{...t.majors, add.major}.length} majors: ${{...t.majors, add.major}.map((m) => m.code).join(', ')}',
          ],
        );

    final byId = {for (final s in all) s.mssv: s};
    return [
      build('p-1', teams[0], byId['190401']!, ProposalFit.strong),
      build('p-2', teams[1], byId['190404']!, ProposalFit.strong),
      build('p-3', teams[2], byId['190403']!, ProposalFit.good),
    ];
  }

  static Student _s(String mssv, String name, Major major, [String? teamId]) => Student(
        mssv: mssv,
        fullName: name,
        major: major,
        classId: 'class-a',
        teamId: teamId,
        semester: 'S5',
      );
}
