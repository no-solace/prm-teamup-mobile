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
import '../screens/flow_d/topic_detail_screen.dart';
import '../screens/flow_d/topic_form_screen.dart';
import '../screens/flow_d/topics_screen.dart';
import '../screens/flow_e/book_slot_screen.dart';
import '../screens/flow_e/schedule_screen.dart';
import '../screens/flow_f/meeting_screen.dart';
import '../screens/flow_f/minutes_form_screen.dart';
import '../screens/gallery/gallery_screen.dart';
import '../screens/my_team/my_team_screen.dart';
import '../screens/notifications/inbox_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
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
      final user = session.hasError ? null : session.asData?.value;
      if (user == null) return atSignIn ? null : Routes.signIn;
      final path = state.uri.path;
      final atOnboarding = path == Routes.onboarding;
      if (user.needsOnboarding) return atOnboarding ? null : Routes.onboarding;
      if (pendingNotificationRoute != null) {
        final destination = pendingNotificationRoute!;
        pendingNotificationRoute = null;
        // go_router re-runs redirect on it, so the role guard below applies.
        if (path != destination) return destination;
      }
      if (atSignIn || atOnboarding) return Routes.classes;
      final denied = user.isStudent
          ? Routes.isMentorOnly(path)
          : Routes.isStudentOnly(path);
      return denied ? Routes.classes : null;
    },
    routes: [
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      if (gallery)
        GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.classes,
                // Mentor: My classes (S2). Student: My team.
                builder: (_, _) => const ClassesTab(),
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
                path: Routes.topics,
                builder: (_, _) => const TopicsScreen(),
                routes: [
                  // Literal paths before the :topicId parameter.
                  GoRoute(
                    path: 'submit',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const TopicFormScreen(),
                  ),
                  GoRoute(
                    path: ':topicId',
                    builder: (_, s) => TopicDetailScreen(
                      topicId: s.pathParameters['topicId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.schedule,
                builder: (_, _) => const ScheduleScreen(),
                routes: [
                  GoRoute(
                    path: 'book',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const BookSlotScreen(),
                  ),
                  GoRoute(
                    path: ':bookingId',
                    builder: (_, s) => MeetingScreen(
                      bookingId: s.pathParameters['bookingId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'minutes',
                        parentNavigatorKey: rootKey,
                        builder: (_, s) => MinutesFormScreen(
                          bookingId: s.pathParameters['bookingId']!,
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
