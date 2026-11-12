import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/proposal.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/fakes/fake_class_service.dart';
import 'package:teamup_exe/services/fakes/fake_proposal_service.dart';
import 'package:teamup_exe/services/fakes/sample_data.dart';
import 'package:teamup_exe/services/rule_based_matching_service.dart';

void main() {
  late FakeClassService classes;
  late FakeProposalService proposals;

  setUp(() {
    classes = FakeClassService(latency: Duration.zero);
    proposals = FakeProposalService(classes: classes);
  });

  test(
    'approval changes the roster, counts and undo restores all of them',
    () async {
      expect((await classes.watchMyClasses().first).first.withoutTeamCount, 5);
      await proposals.approve('p-1');

      expect(
        (await classes.getStudent('class-a', '190401')).teamId,
        'team-tutor',
      );
      expect((await classes.watchMyClasses().first).first.withoutTeamCount, 4);
      expect(
        (await classes.watchTeams('class-a').first)
            .firstWhere((team) => team.id == 'team-tutor')
            .memberIds,
        unorderedEquals(['190501', '190502', '190503', '190504', '190401']),
      );
      expect(
        (await proposals.watchPending('class-a').first).map((p) => p.id),
        isNot(contains('p-1')),
      );

      await expectLater(
        proposals.approve('p-1'),
        throwsA(isA<ValidationError>()),
      );
      await proposals.undoApprove('p-1');
      expect((await classes.getStudent('class-a', '190401')).teamId, isNull);
      expect((await classes.watchMyClasses().first).first.withoutTeamCount, 5);
      expect(
        (await proposals.watchProposal('p-1').first).status,
        ProposalStatus.pending,
      );
    },
  );

  test(
    'regeneration keeps an edited pending proposal and a discarded one',
    () async {
      final updated = await proposals.updateMembers(
        'p-1',
        currentMemberIds: ['190501', '190502', '190503', '190504'],
        addStudentIds: ['190412'],
      );
      expect(updated.addStudentIds, ['190412']);
      final generated = SampleData.proposals(
        SampleData.students(),
        SampleData.teams(SampleData.students()),
      );
      final pending = await proposals.savePending('class-a', generated);
      expect(pending.firstWhere((p) => p.id == 'p-1').addStudentIds, [
        '190412',
      ]);

      await proposals.discard('p-1');
      final rerun = await proposals.savePending(
        'class-a',
        generated.where((p) => p.id == 'p-1').toList(),
      );
      expect(rerun, isEmpty);
      expect(
        (await proposals.watchProposal('p-1').first).status,
        ProposalStatus.discarded,
      );
    },
  );

  test('rerun replaces a stale AI draft and preserves manual drafts', () async {
    const classId = 'class-a';
    const teamId = 'team-tutor';
    final approved = await proposals.createManual(
      classId: classId,
      teamId: teamId,
      addStudentIds: ['190402'],
    );
    await proposals.approve(approved.id);
    final manual = await proposals.createManual(
      classId: classId,
      teamId: teamId,
      addStudentIds: ['190412'],
    );
    final candidates = await RuleBasedMatchingService().propose(
      classId: classId,
      students: classes.studentsFor(classId),
      teams: classes.teamsFor(classId).where((t) => t.id == teamId).toList(),
    );
    final pending = await proposals.savePending(classId, candidates);
    final replacement = pending.single;
    expect(replacement.id, isNot('p-1'));
    expect(
      (await proposals.watchPending(classId).first)
          .where((p) => p.teamId == teamId)
          .map((p) => p.id),
      unorderedEquals([replacement.id, manual.id]),
    );
    expect(
      (await proposals.watchProposal('p-1').first).status,
      ProposalStatus.superseded,
    );
    await proposals.approve(replacement.id);
    expect(classes.teamsFor(classId).firstWhere((t) => t.id == teamId).size, 6);
    expect(await proposals.savePending(classId, candidates), isEmpty);
    expect(
      (await proposals.watchProposal(replacement.id).first).status,
      ProposalStatus.approved,
    );
  });

  test('empty run retires stale AI drafts without losing valid ones', () async {
    final manual = await proposals.createManual(
      classId: 'class-a',
      teamId: 'team-tutor',
      addStudentIds: ['190401', '190402'],
    );
    await proposals.approve(manual.id);

    expect(await proposals.savePending('class-a', []), isEmpty);
    expect(
      (await proposals.watchProposal('p-1').first).status,
      ProposalStatus.superseded,
    );
    expect(
      (await proposals.watchProposal('p-2').first).status,
      ProposalStatus.pending,
    );
    await proposals.undoApprove(manual.id);
    final old = SampleData.proposals(
      SampleData.students(),
      SampleData.teams(SampleData.students()),
    ).first;
    expect((await proposals.savePending('class-a', [old])).single.id, 'p-1');
    expect(
      (await proposals.watchProposal('p-1').first).status,
      ProposalStatus.pending,
    );
  });

  test(
    'manual proposal uses the current team and prevents duplicate assignment',
    () async {
      final manual = await proposals.createManual(
        classId: 'class-a',
        teamId: 'team-tutor',
        addStudentIds: ['190402'],
      );
      expect(manual.source, ProposalSource.manual);
      expect(manual.canApprove, isTrue);
      await proposals.approve(manual.id);
      expect(
        (await classes.getStudent('class-a', '190402')).teamId,
        'team-tutor',
      );

      await expectLater(
        proposals.approve('p-1'),
        throwsA(isA<ValidationError>()),
      );
    },
  );
}
