import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/app_shell.dart';
import '../screens/flow_a/class_detail_screen.dart';
import '../screens/flow_a/import_class_screen.dart';
import '../screens/flow_a/import_result_screen.dart';
import '../screens/flow_a/matching_screen.dart';
import '../screens/flow_a/no_team_screen.dart';
import '../screens/flow_a/student_detail_screen.dart';
import '../screens/flow_b/add_member_screen.dart';
import '../screens/flow_b/proposal_detail_screen.dart';
import '../screens/flow_b/proposals_screen.dart';
import '../screens/flow_c/add_student_screen.dart';
import '../screens/flow_c/need_members_screen.dart';
import '../screens/flow_c/no_match_screen.dart';
import '../screens/gallery/gallery_screen.dart';
import '../screens/my_classes/my_classes_screen.dart';
import '../screens/notifications/inbox_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../viewmodels/auth/session_view_model.dart';
import '../viewmodels/notifications/notification_taps_view_model.dart';
import 'routes.dart';

/// True only in main_fake.dart: registers /_gallery (D7, skeleton DoD).
final galleryEnabledProvider = Provider<bool>((ref) => false);

/// Bridges the Riverpod session to go_router's refreshListenable.
class _SessionListenable extends ChangeNotifier {
  void ping() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final refresh = _SessionListenable();
  ref.listen(sessionProvider, (_, _) => refresh.ping());
  final gallery = ref.read(galleryEnabledProvider);
  String? pendingNotificationRoute;

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.classes,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final atSignIn = state.matchedLocation == Routes.signIn;
      // Still resolving the first auth event: wait on S1 (it shows a spinner),
      // so no signed-in screen flashes before the session is known.
      if (session.isLoading && !session.hasValue) {
        return atSignIn ? null : Routes.signIn;
      }
      final signedIn = !session.hasError && session.asData?.value != null;
      if (!signedIn) return atSignIn ? null : Routes.signIn;
      if (pendingNotificationRoute != null) {
        final destination = pendingNotificationRoute!;
        pendingNotificationRoute = null;
        if (state.uri.path != destination) return destination;
      }
      if (atSignIn) return Routes.classes;
      return null;
    },
    routes: [
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      if (gallery)
        GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.classes,
                builder: (_, _) => const MyClassesScreen(),
                routes: [
                  GoRoute(
                    path: 'import',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const ImportClassScreen(),
                    routes: [
                      GoRoute(
                        path: 'result',
                        parentNavigatorKey: rootKey,
                        builder: (_, _) => const ImportResultScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':classId',
                    parentNavigatorKey: rootKey,
                    builder: (_, s) => ClassDetailScreen(
                      classId: s.pathParameters['classId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'no-team',
                        parentNavigatorKey: rootKey,
                        builder: (_, s) =>
                            NoTeamScreen(classId: s.pathParameters['classId']!),
                      ),
                      GoRoute(
                        path: 'need-members',
                        parentNavigatorKey: rootKey,
                        builder: (_, s) => NeedMembersScreen(
                          classId: s.pathParameters['classId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'students/:studentId',
                        parentNavigatorKey: rootKey,
                        builder: (_, s) => StudentDetailScreen(
                          classId: s.pathParameters['classId']!,
                          studentId: s.pathParameters['studentId']!,
                          selectionMode:
                              s.uri.queryParameters['select'] == 'true',
                        ),
                      ),
                      GoRoute(
                        path: 'matching',
                        parentNavigatorKey: rootKey,
                        builder: (_, s) => MatchingScreen(
                          classId: s.pathParameters['classId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'no-match',
                        parentNavigatorKey: rootKey,
                        builder: (_, s) => NoMatchScreen(
                          classId: s.pathParameters['classId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'add-student',
                        parentNavigatorKey: rootKey,
                        builder: (_, s) => AddStudentScreen(
                          classId: s.pathParameters['classId']!,
                          teamId: s.uri.queryParameters['teamId'],
                          studentId: s.uri.queryParameters['studentId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.proposals,
                builder: (_, _) => const ProposalsScreen(),
                routes: [
                  GoRoute(
                    path: ':proposalId',
                    builder: (_, s) => ProposalDetailScreen(
                      proposalId: s.pathParameters['proposalId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'add-member',
                        builder: (_, s) => AddMemberScreen(
                          proposalId: s.pathParameters['proposalId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (_, _) => const InboxScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Tapped push notification -> go to its route, if it is on the allow-list.
  final taps = ref.listen(notificationTapsProvider, (_, next) {
    final route = next.value;
    if (route != null && Routes.isAllowedDeepLink(route)) {
      if (ref.read(sessionProvider).asData?.value != null) {
        router.go(route);
      } else {
        pendingNotificationRoute = route;
      }
    }
  });

  ref.onDispose(() {
    taps.close();
    refresh.dispose();
    router.dispose();
  });
  return router;
});
