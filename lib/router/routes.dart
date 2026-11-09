/// Route paths (D7). Screens navigate with these helpers, never raw strings,
/// so a renamed route breaks at compile time.
abstract final class Routes {
  static const signIn = '/sign-in';

  // Tab 1: Classes (Flow A + C)
  static const classes = '/classes'; // S2
  static const importClass = '/classes/import'; // S22
  static const importResult = '/classes/import/result'; // S23
  static String classDetail(String classId) => '/classes/$classId'; // S3
  static String noTeam(String classId) => '/classes/$classId/no-team'; // S4
  static String needMembers(String classId) =>
      '/classes/$classId/need-members'; // S5
  /// Call with selectionMode from S11 and await the returned MSSV.
  static String student(
    String classId,
    String studentId, {
    bool selectionMode = false,
  }) =>
      '/classes/$classId/students/$studentId${selectionMode ? '?select=true' : ''}'; // S7
  static String matching(String classId) =>
      '/classes/$classId/matching'; // S8 (S18)
  static String noMatch(String classId) => '/classes/$classId/no-match'; // S15
  /// Flow C may use studentId as its initial selection when arriving from S7.
  static String addStudent(
    String classId, {
    String? studentId,
    String? teamId,
  }) => Uri(
    path: '/classes/$classId/add-student',
    queryParameters: {
      'studentId': ?studentId,
      'teamId': ?teamId,
    },
  ).toString(); // S16 (S21)

  // Tab 2: Proposals (Flow B)
  static const proposals = '/proposals'; // S9 (S14)
  static String proposal(String proposalId) =>
      '/proposals/$proposalId'; // S10 (S20, S25)
  static String addMember(String proposalId) =>
      '/proposals/$proposalId/add-member'; // S11 (S13)

  // Tab 3: Profile
  static const profile = '/profile'; // S6
  static const notifications = '/profile/notifications';

  /// Debug widget gallery, only registered by main_fake.dart.
  static const gallery = '/_gallery';

  /// Routes a push notification may open (D7). Anything else is ignored.
  static final _deepLinkPatterns = [
    RegExp(r'^/classes$'),
    RegExp(r'^/classes/[\w-]+$'),
    RegExp(r'^/classes/[\w-]+/(no-team|need-members|no-match)$'),
    RegExp(r'^/proposals$'),
    RegExp(r'^/proposals/[\w-]+$'),
    RegExp(r'^/profile$'),
    RegExp(r'^/profile/notifications$'),
  ];

  static bool isAllowedDeepLink(String route) =>
      _deepLinkPatterns.any((p) => p.hasMatch(route));
}
