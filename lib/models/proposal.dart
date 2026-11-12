import 'data_validation.dart';
import 'major.dart';

/// "Proposal" here is a team-matching proposal (Lab 2 S9/S10), NOT a project topic.
enum ProposalStatus { pending, approved, discarded, superseded }

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
      resultingSize >= TeamRules.minMembers &&
      resultingSize <= TeamRules.maxMembers;

  factory Proposal.fromMap(String id, Map<String, dynamic> data) {
    List<String> ids(String key) => [
      for (final value in data[key] as List<dynamic>)
        DataValidation.id(value as String),
    ];
    List<Major> majors(String key) => [
      for (final value in data[key] as List<dynamic>)
        Major.fromCode(value as String) ??
            (throw const FormatException('Invalid proposal major')),
    ];
    T choice<T extends Enum>(List<T> values, String key) => values.firstWhere(
      (value) => value.name == data[key],
      orElse: () => throw FormatException('Invalid proposal $key'),
    );
    final currentIds = ids('currentMemberIds');
    final addedIds = ids('addStudentIds');
    final current = majors('currentMajors');
    final added = majors('addMajors');
    if (currentIds.length != current.length ||
        addedIds.length != added.length ||
        currentIds.length + addedIds.length > TeamRules.maxMembers ||
        {...currentIds, ...addedIds}.length !=
            currentIds.length + addedIds.length) {
      throw const FormatException('Invalid proposal roster');
    }
    return Proposal(
      id: DataValidation.id(id),
      classId: DataValidation.id(data['classId'] as String),
      teamId: DataValidation.id(data['teamId'] as String),
      teamName: data['teamName'] as String,
      currentMemberIds: currentIds,
      currentMajors: current,
      addStudentIds: addedIds,
      addMajors: added,
      fit: choice(ProposalFit.values, 'fit'),
      reasons: List<String>.from(data['reasons'] as List),
      status: choice(ProposalStatus.values, 'status'),
      source: choice(ProposalSource.values, 'source'),
    );
  }

  Map<String, dynamic> toMap(String mentorUid) => {
    'classId': classId,
    'mentorUid': mentorUid,
    'teamId': teamId,
    'teamName': teamName,
    'currentMemberIds': currentMemberIds,
    'currentMajors': [for (final major in currentMajors) major.code],
    'addStudentIds': addStudentIds,
    'addMajors': [for (final major in addMajors) major.code],
    'fit': fit.name,
    'reasons': reasons,
    'status': status.name,
    'source': source.name,
  };
}
