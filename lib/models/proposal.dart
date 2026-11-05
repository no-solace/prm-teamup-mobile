import 'major.dart';

/// "Proposal" here is a team-matching proposal (Lab 2 S9/S10), NOT a project topic.
enum ProposalStatus { pending, approved, discarded }

enum ProposalSource { ai, manual }

enum ProposalFit { strong, good }

/// classes/{classId}/proposals/{id}
class Proposal {
  const Proposal({
    required this.id,
    required this.classId,
    required this.teamId,
    required this.teamName,
    required this.currentMemberIds,
    required this.currentMajors,
    required this.addStudentIds,
    required this.addMajors,
    required this.fit,
    required this.reasons,
    this.status = ProposalStatus.pending,
    this.source = ProposalSource.ai,
  });

  final String id;
  final String classId;
  final String teamId;
  final String teamName;
  final List<String> currentMemberIds;
  final List<Major> currentMajors;

  /// Students the proposal adds (S10 "New member").
  final List<String> addStudentIds;
  final List<Major> addMajors;
  final ProposalFit fit;

  /// "Why" lines on S10, for example "Team reaches 3 majors: SE, AI, GD".
  final List<String> reasons;
  final ProposalStatus status;
  final ProposalSource source;

  int get resultingSize => currentMemberIds.length + addStudentIds.length;
  int get resultingMajorCount => {...currentMajors, ...addMajors}.length;

  /// R1: approve only when 5..6 members (S25 blocks below 5, S13 blocks above 6).
  bool get canApprove =>
      resultingSize >= TeamRules.minMembers && resultingSize <= TeamRules.maxMembers;
}
