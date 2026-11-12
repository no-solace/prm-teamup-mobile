import '../models/data_validation.dart';
import '../models/major.dart';
import '../models/proposal.dart';
import '../models/student.dart';
import '../models/team.dart';
import 'app_error.dart';

void validateMatchingDrafts(String classId, List<Proposal> proposals) {
  final ids = <String>{};
  final teams = <String>{};
  if (!DataValidation.isId(classId) ||
      proposals.any(
        (p) =>
            p.classId != classId ||
            p.status != ProposalStatus.pending ||
            p.source != ProposalSource.ai ||
            !DataValidation.isId(p.id) ||
            !DataValidation.isId(p.teamId) ||
            !p.addStudentIds.every(DataValidation.isId) ||
            !ids.add(p.id) ||
            !teams.add(p.teamId),
      )) {
    throw const ValidationError('Invalid matching proposals');
  }
}

({List<Proposal> pending, List<Proposal> writes, List<String> retire})
reconcileMatchingDrafts({
  required List<Proposal> proposed,
  required Map<String, Proposal> existing,
  required Map<String, Team> teams,
  required Map<String, Student> students,
}) {
  bool isCurrent(Proposal draft) {
    final team = teams[draft.teamId];
    if (team == null ||
        team.size != draft.currentMemberIds.length ||
        team.size != draft.currentMajors.length ||
        draft.addStudentIds.length != draft.addMajors.length ||
        draft.resultingSize > TeamRules.maxMembers) {
      return false;
    }
    for (var i = 0; i < team.size; i++) {
      if (team.memberIds[i] != draft.currentMemberIds[i] ||
          team.majors[i] != draft.currentMajors[i]) {
        return false;
      }
    }
    for (var i = 0; i < draft.addStudentIds.length; i++) {
      final student = students[draft.addStudentIds[i]];
      if (student == null ||
          student.hasTeam ||
          student.major != draft.addMajors[i]) {
        return false;
      }
    }
    return true;
  }

  final selected = <String, Proposal>{};
  final writes = <Proposal>[];
  for (final draft in proposed) {
    final previous = existing[draft.id];
    if (previous != null &&
        (previous.teamId != draft.teamId ||
            previous.source != ProposalSource.ai)) {
      throw const ValidationError(
        'Matching proposal ID conflicts with an existing proposal',
      );
    }
    if (previous?.status == ProposalStatus.approved ||
        previous?.status == ProposalStatus.discarded) {
      continue;
    }
    if (!isCurrent(draft)) {
      throw const ValidationError('Class data changed. Run matching again');
    }
    if (previous != null &&
        previous.status == ProposalStatus.pending &&
        isCurrent(previous)) {
      selected[draft.teamId] = previous;
    } else {
      selected[draft.teamId] = draft;
      writes.add(draft);
    }
  }

  final retire = [
    for (final draft in existing.values)
      if (draft.source == ProposalSource.ai &&
          draft.status == ProposalStatus.pending &&
          selected[draft.teamId]?.id != draft.id &&
          (selected.containsKey(draft.teamId) || !isCurrent(draft)))
        draft.id,
  ];
  return (pending: selected.values.toList(), writes: writes, retire: retire);
}
