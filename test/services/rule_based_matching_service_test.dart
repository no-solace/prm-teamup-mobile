import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/major.dart';
import 'package:teamup_exe/models/proposal.dart';
import 'package:teamup_exe/models/student.dart';
import 'package:teamup_exe/models/team.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/fakes/fake_matching_service.dart';
import 'package:teamup_exe/services/fakes/sample_data.dart';
import 'package:teamup_exe/services/matching_service.dart';
import 'package:teamup_exe/services/rule_based_matching_service.dart';

const _classId = 'class-1';

Student _student(
  String id,
  Major major, {
  String? teamId,
  String classId = _classId,
  String? name,
}) => Student(
  mssv: id,
  fullName: name ?? id,
  major: major,
  classId: classId,
  teamId: teamId,
);

Team _team(
  String id,
  List<Major> majors, {
  List<String>? members,
  String classId = _classId,
}) => Team(
  id: id,
  classId: classId,
  name: 'Team $id',
  memberIds: members ?? [for (var i = 0; i < majors.length; i++) '$id-$i'],
  majors: majors,
);

List<Object> _snapshot(List<Proposal> proposals) => [
  for (final p in proposals)
    [
      p.id,
      p.classId,
      p.teamId,
      p.teamName,
      p.currentMemberIds,
      p.currentMajors,
      p.addStudentIds,
      p.addMajors,
      p.fit,
      p.reasons,
      p.status,
      p.source,
    ],
];

void main() {
  late MatchingService service;
  setUp(() => service = RuleBasedMatchingService());

  Future<List<Proposal>> propose(List<Student> students, List<Team> teams) =>
      service.propose(classId: _classId, students: students, teams: teams);

  group('R1: 5–6 members', () {
    test(
      'completes a four-member team to five with an aligned snapshot',
      () async {
        final team = _team('t', [Major.se, Major.ai, Major.se, Major.se]);
        final p = (await propose([_student('new', Major.gd)], [team])).single;
        expect(p.resultingSize, 5);
        expect(p.canApprove, isTrue);
        expect(p.currentMemberIds, team.memberIds);
        expect(p.currentMajors, team.majors);
        expect(p.addStudentIds, ['new']);
        expect(p.addMajors, [Major.gd]);
        expect(p.status, ProposalStatus.pending);
        expect(p.source, ProposalSource.ai);
      },
    );

    test(
      'does not consume students for a team that cannot reach five',
      () async {
        final proposals = await propose(
          [_student('one', Major.gd)],
          [
            _team('a-small', [Major.se]),
            _team('b', List.filled(4, Major.se)),
          ],
        );
        expect(proposals.single.teamId, 'b');
        expect(proposals.single.resultingSize, 5);
      },
    );

    test('does not return a partial unapprovable proposal', () async {
      expect(
        await propose(
          [_student('one', Major.ai)],
          [
            _team('t', [Major.se, Major.se, Major.se]),
          ],
        ),
        isEmpty,
      );
    });

    test(
      'can complete an existing empty team but never invents a team',
      () async {
        final students = [
          for (var i = 0; i < 5; i++) _student('s$i', Major.values[i % 4]),
        ];
        expect(
          (await propose(students, [_team('t', [])])).single.resultingSize,
          5,
        );
        expect(await propose(students, []), isEmpty);
      },
    );

    test('completes two teams before giving either a sixth member', () async {
      final proposals = await propose(
        [_student('one', Major.ai), _student('two', Major.mkt)],
        [
          _team('a', List.filled(4, Major.se)),
          _team('b', List.filled(4, Major.se)),
        ],
      );
      expect(proposals, hasLength(2));
      expect(proposals.map((p) => p.resultingSize), everyElement(5));
    });

    test(
      'underfilled team takes priority over extending a five-member team',
      () async {
        final proposals = await propose(
          [_student('one', Major.gd)],
          [
            _team('a', [Major.se, Major.ai, Major.mkt, Major.se, Major.se]),
            _team('z', List.filled(4, Major.se)),
          ],
        );
        expect(proposals.single.teamId, 'z');
      },
    );

    test(
      'five-member team may take one student, never more than six',
      () async {
        final p = (await propose(
          [for (var i = 0; i < 8; i++) _student('s$i', Major.ai)],
          [_team('t', List.filled(5, Major.se))],
        )).single;
        expect(p.resultingSize, 6);
        expect(p.addStudentIds, hasLength(1));
      },
    );

    test('unused pool fills spare sixth places after completion', () async {
      final ps = await propose(
        [for (var i = 0; i < 3; i++) _student('s$i', Major.gd)],
        [
          _team('a', [Major.se, Major.ai, Major.se, Major.se]),
          _team('b', [Major.se, Major.ai, Major.se, Major.se]),
        ],
      );
      expect(ps.map((p) => p.resultingSize), [6, 5]);
    });
  });

  group('R2: exclude assigned students and full teams', () {
    test(
      'assignment and roster independently block a student from the pool',
      () async {
        final proposals = await propose(
          [
            _student('assigned', Major.gd, teamId: 'unloaded'),
            _student('rostered', Major.mkt),
            _student('free', Major.ai),
          ],
          [
            _team(
              'full',
              List.filled(6, Major.mkt),
              members: ['rostered', 'f1', 'f2', 'f3', 'f4', 'f5'],
            ),
            _team('target', List.filled(4, Major.se)),
          ],
        );
        expect(proposals.single.teamId, 'target');
        expect(proposals.single.addStudentIds, ['free']);
      },
    );

    test('never targets six-member or oversized teams', () async {
      expect(
        await propose(
          [_student('s', Major.ai)],
          [
            _team('six', List.filled(6, Major.se)),
            _team('seven', List.filled(7, Major.se)),
          ],
        ),
        isEmpty,
      );
    });

    test(
      'does not duplicate students across proposals or their current rosters',
      () async {
        final students = [
          for (var i = 0; i < 5; i++) _student('s$i', Major.values[i % 4]),
        ];
        final ps = await propose(
          [...students, ...students],
          [
            _team('a', List.filled(4, Major.se)),
            _team('b', List.filled(3, Major.ai)),
          ],
        );
        final added = ps.expand((p) => p.addStudentIds).toList();
        expect(ps, hasLength(2));
        expect(added.toSet().length, added.length);
        expect(
          added.toSet().intersection(
            ps.expand((p) => p.currentMemberIds).toSet(),
          ),
          isEmpty,
        );
      },
    );

    test('limits targets and students to the selected class', () async {
      final ps = await propose(
        [
          _student('foreign', Major.gd, classId: 'other'),
          _student('local', Major.ai),
        ],
        [
          _team('a-foreign', List.filled(4, Major.se), classId: 'other'),
          _team('local', List.filled(4, Major.se)),
        ],
      );
      expect(ps.single.classId, _classId);
      expect(ps.single.teamId, 'local');
      expect(ps.single.addStudentIds, ['local']);
    });
  });

  group('R3: major diversity and explanations', () {
    test(
      'chooses a missing major over an earlier ID with a repeated major',
      () async {
        final p = (await propose(
          [_student('a-repeat', Major.se), _student('z-missing', Major.mkt)],
          [
            _team('t', [Major.se, Major.ai, Major.se, Major.se, Major.se]),
          ],
        )).single;
        expect(p.addStudentIds, ['z-missing']);
        expect(p.resultingMajorCount, 3);
        expect(p.fit, ProposalFit.strong);
        expect(p.reasons, contains('Adds missing majors: MKT.'));
      },
    );

    test('uses the sixth place when needed to reach three majors', () async {
      final p = (await propose(
        [
          _student('a-repeat', Major.se),
          _student('b-ai', Major.ai),
          _student('c-gd', Major.gd),
        ],
        [_team('t', List.filled(4, Major.se))],
      )).single;
      expect(p.resultingSize, 6);
      expect(p.addStudentIds.toSet(), {'b-ai', 'c-gd'});
      expect(p.fit, ProposalFit.strong);
      expect(p.reasons, contains('Team reaches 3 majors: SE, AI, GD.'));
    });

    test(
      'explains a feasible low-diversity group without inventing majors',
      () async {
        final p = (await propose(
          [_student('s', Major.se)],
          [_team('t', List.filled(4, Major.se))],
        )).single;
        expect(p.canApprove, isTrue);
        expect(p.resultingMajorCount, 1);
        expect(p.fit, ProposalFit.good);
        expect(p.reasons.join(' '), contains('mentor review is needed'));
        expect(p.reasons, contains('Team reaches 1 majors: SE.'));
      },
    );

    test(
      'does not claim three majors when only one place is available',
      () async {
        final p = (await propose(
          [_student('s1', Major.ai), _student('s2', Major.mkt)],
          [_team('t', List.filled(5, Major.se))],
        )).single;
        expect(p.resultingSize, 6);
        expect(p.resultingMajorCount, 2);
        expect(p.fit, ProposalFit.good);
      },
    );

    test(
      'preserves scarce majors when a common missing major is available',
      () async {
        final ps = await propose(
          [
            _student('rare', Major.ai),
            _student('common-1', Major.mkt),
            _student('common-2', Major.mkt),
          ],
          [
            _team('a', [Major.se, Major.gd, Major.se, Major.se]),
            _team('b', [Major.se, Major.mkt, Major.se, Major.se]),
          ],
        );
        expect(ps, hasLength(2));
        expect(
          ps.map((p) => p.resultingMajorCount),
          everyElement(greaterThanOrEqualTo(3)),
        );
        expect(
          ps.singleWhere((p) => p.teamId == 'b').addStudentIds,
          contains('rare'),
        );
      },
    );
  });

  group('missing and conflicting data', () {
    test('empty input or empty pool returns no match', () async {
      expect(await propose([], []), isEmpty);
      expect(
        await propose([], [_team('t', List.filled(5, Major.se))]),
        isEmpty,
      );
      expect(await propose([_student('s', Major.ai)], []), isEmpty);
    });

    test('blank class ID gives the existing domain validation error', () async {
      await expectLater(
        service.propose(classId: ' ', students: [], teams: []),
        throwsA(isA<ValidationError>()),
      );
    });

    test(
      'quarantines duplicate IDs with conflicting majors or assignments',
      () async {
        final ps = await propose(
          [
            _student('bad-major', Major.ai),
            _student('bad-major', Major.mkt),
            _student('bad-team', Major.gd),
            _student('bad-team', Major.gd, teamId: 'other'),
            _student(' ', Major.gd),
            _student('good', Major.se),
          ],
          [_team('t', List.filled(4, Major.se))],
        );
        expect(ps.single.addStudentIds, ['good']);
      },
    );

    test(
      'collapses identical team snapshots but rejects conflicting snapshots',
      () async {
        final team = _team('t', [Major.se, Major.ai, Major.se, Major.se]);
        final students = [_student('s', Major.mkt)];
        expect(await propose(students, [team, team]), hasLength(1));
        expect(
          await propose(students, [team, _team('t', List.filled(3, Major.se))]),
          isEmpty,
        );
      },
    );

    test('malformed rosters reserve their students and are skipped', () async {
      final ps = await propose(
        [_student('reserved', Major.gd), _student('free', Major.ai)],
        [
          _team('invalid', [Major.gd], members: ['reserved', 'missing-major']),
          _team(
            'duplicates',
            List.filled(4, Major.se),
            members: ['d', 'd', 'e', 'f'],
          ),
          _team('blank', [Major.se], members: ['']),
          _team('', []),
          _team('target', List.filled(4, Major.se)),
        ],
      );
      expect(ps.single.teamId, 'target');
      expect(ps.single.addStudentIds, ['free']);
    });

    test('shared member makes both team rosters unsafe', () async {
      expect(
        await propose(
          [_student('free', Major.gd)],
          [
            _team(
              'a',
              List.filled(4, Major.se),
              members: ['shared', 'a1', 'a2', 'a3'],
            ),
            _team(
              'b',
              List.filled(4, Major.se),
              members: ['shared', 'b1', 'b2', 'b3'],
            ),
          ],
        ),
        isEmpty,
      );
    });

    test(
      'assignment absent from team roster prevents using a stale team size',
      () async {
        expect(
          await propose(
            [
              _student('unlisted', Major.se, teamId: 't'),
              _student('free', Major.ai),
            ],
            [_team('t', List.filled(4, Major.se))],
          ),
          isEmpty,
        );
      },
    );

    test(
      'known roster major or assignment conflict prevents a proposal',
      () async {
        final team = _team('t', List.filled(4, Major.se));
        for (final member in [
          _student('t-0', Major.gd),
          _student('t-0', Major.se, teamId: 'different'),
        ]) {
          expect(
            await propose([member, _student('free', Major.ai)], [team]),
            isEmpty,
          );
        }
      },
    );

    test(
      'supports roster-only current members when student records are absent',
      () async {
        final ps = await propose(
          [_student('free', Major.ai)],
          [_team('t', List.filled(4, Major.se))],
        );
        expect(ps.single.resultingSize, 5);
      },
    );
  });

  group('determinism and compatibility', () {
    test(
      'all proposal fields are stable across shuffles and repeated calls',
      () async {
        final students = [
          for (var i = 0; i < 15; i++) _student('s$i', Major.values[i % 4]),
        ];
        final teams = [
          for (var i = 0; i < 5; i++) _team('t$i', List.filled(i, Major.se)),
        ];
        final expected = _snapshot(await propose(students, teams));
        expect(expected, isNotEmpty);
        for (var seed = 0; seed < 20; seed++) {
          final shuffledStudents = List<Student>.of(students)
            ..shuffle(Random(seed));
          final shuffledTeams = List<Team>.of(teams)..shuffle(Random(seed));
          expect(
            _snapshot(await propose(shuffledStudents, shuffledTeams)),
            expected,
          );
        }
      },
    );

    test(
      'names do not affect matching and member/major pairs stay aligned',
      () async {
        final students = [_student('a', Major.gd), _student('b', Major.ai)];
        final team = _team(
          't',
          [Major.ai, Major.se, Major.se, Major.se],
          members: ['z', 'b', 'd', 'a'],
        );
        final reversed = Team(
          id: team.id,
          classId: team.classId,
          name: team.name,
          memberIds: team.memberIds.reversed.toList(),
          majors: team.majors.reversed.toList(),
        );
        final expected = await propose(students, [team]);
        // Both IDs in this fixture are roster members: they cannot enter the pool.
        expect(expected, isEmpty);
        final free = [_student('free', Major.mkt, name: 'Z')];
        final original =
            (await propose([_student('free', Major.mkt, name: 'A')], [team]))
                .single;
        final p = (await propose(free, [reversed])).single;
        expect(p.id, original.id);
        expect(p.addStudentIds, original.addStudentIds);
        expect(p.addMajors, original.addMajors);
        expect(p.currentMemberIds, reversed.memberIds);
        expect(p.currentMajors, reversed.majors);
      },
    );

    test(
      'does not mutate input and returns detached immutable snapshots',
      () async {
        final students = [_student('free', Major.ai)];
        final team = _team('t', List.filled(4, Major.se));
        final teams = [team];
        final p = (await propose(
          List.unmodifiable(students),
          List.unmodifiable(teams),
        )).single;
        expect(students.single.teamId, isNull);
        expect(team.size, 4);
        team.memberIds[0] = 'changed-after-proposing';
        team.majors[0] = Major.gd;
        expect(p.currentMemberIds.first, 't-0');
        expect(p.currentMajors.first, Major.se);
        expect(() => p.addStudentIds.add('injected'), throwsUnsupportedError);
      },
    );

    test(
      'generated small rosters always obey capacity and unique allocation',
      () async {
        for (var seed = 0; seed < 60; seed++) {
          final random = Random(seed);
          final poolSize = random.nextInt(30);
          final students = [
            for (var i = 0; i < poolSize; i++)
              _student('s$i', Major.values[random.nextInt(4)]),
          ];
          final teams = [
            for (var i = 0; i < 6; i++)
              _team(
                't$i',
                List.generate(
                  random.nextInt(7),
                  (_) => Major.values[random.nextInt(4)],
                ),
              ),
          ];
          final ps = await propose(students, teams);
          final ids = ps.expand((p) => p.addStudentIds).toList();
          expect(ids.toSet().length, ids.length, reason: 'seed=$seed');
          expect(ps.map((p) => p.teamId).toSet().length, ps.length);
          for (final p in ps) {
            expect(p.canApprove, isTrue, reason: 'seed=$seed');
            expect(p.addStudentIds, isNotEmpty);
            expect(p.addStudentIds.length, p.addMajors.length);
            for (var i = 0; i < p.addStudentIds.length; i++) {
              expect(
                p.addMajors[i],
                students.singleWhere((s) => s.mssv == p.addStudentIds[i]).major,
              );
            }
          }
        }
      },
    );

    test(
      'existing Figma fake remains usable through the same interface',
      () async {
        final MatchingService fake = FakeMatchingService(
          latency: Duration.zero,
        );
        final students = SampleData.students();
        final teams = SampleData.teams(students);
        expect(
          await fake.propose(
            classId: 'class-a',
            students: students,
            teams: teams,
          ),
          hasLength(3),
        );
        final MatchingService noMatch = FakeMatchingService(
          noMatch: true,
          latency: Duration.zero,
        );
        expect(
          await noMatch.propose(classId: _classId, students: [], teams: []),
          isEmpty,
        );
      },
    );
  });
}
