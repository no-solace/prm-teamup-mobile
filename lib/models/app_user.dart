/// users/{uid}.role. A student is a leader or a member of one team.
enum UserRole {
  mentor,
  leader,
  member;

  static UserRole? fromName(Object? value) =>
      values.where((r) => r.name == value).firstOrNull;
}

/// The signed-in user (users/{uid}).
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.role = UserRole.mentor,
    this.classId,
    this.teamId,
    this.studentId,
    this.mentorUid,
  });

  final String uid;
  final String displayName;

  /// Shown on S6 only. Never sent to Analytics or Crashlytics (no PII).
  final String? email;
  final String? photoUrl;
  final String? phoneNumber;

  /// Null until onboarding picks a role (no users/{uid} document yet).
  final UserRole? role;

  /// Student only: the class, team, MSSV and mentor they were linked to.
  final String? classId;
  final String? teamId;
  final String? studentId;
  final String? mentorUid;

  bool get needsOnboarding => role == null;
  bool get isMentor => role == UserRole.mentor;
  bool get isStudent => role == UserRole.leader || role == UserRole.member;
  bool get isLeader => role == UserRole.leader;

  /// Students' topic document ID (topics/{classId}_{teamId}).
  String? get topicId =>
      isStudent && classId != null && teamId != null ? '${classId}_$teamId' : null;

  String get roleLabel => switch (role) {
    UserRole.mentor => 'Mentor',
    UserRole.leader => 'Team leader',
    UserRole.member => 'Team member',
    null => 'New account',
  };

  /// Avatar initials on S6 (for example "LN").
  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
