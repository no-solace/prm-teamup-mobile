import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/app_shell.dart';
import '../screens/gallery/gallery_screen.dart';
import '../screens/my_classes/my_classes_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../viewmodels/auth/session_view_model.dart';
import '../viewmodels/notifications/notification_taps_view_model.dart';
import 'routes.dart';

/// True only in main_fake.dart: registers /_gallery (D7, skeleton DoD).
final galleryEnabledProvider = Provider<bool>((ref) => false);

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Bridges the Riverpod session to go_router's refreshListenable.
class _SessionListenable extends ChangeNotifier {
  void ping() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionListenable();
  ref.listen(sessionProvider, (_, _) => refresh.ping());
  final gallery = ref.read(galleryEnabledProvider);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.classes,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final atSignIn = state.matchedLocation == Routes.signIn;
      // Still resolving the first auth event: wait on S1 (it shows a spinner),
      // so no signed-in screen flashes before the session is known.
      if (session.isLoading && !session.hasValue) return atSignIn ? null : Routes.signIn;
      final signedIn = session.value != null;
      if (!signedIn) return atSignIn ? null : Routes.signIn;
      if (atSignIn) return Routes.classes;
      return null;
    },
    routes: [
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      if (gallery) GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.classes,
              builder: (_, _) => const MyClassesScreen(),
              routes: [
                GoRoute(
                  path: 'import',
                  builder: (_, _) => const PlaceholderScreen(id: 'S22', title: 'Import class', owner: 'Dan'),
                  routes: [
                    GoRoute(
                      path: 'result',
                      builder: (_, _) => const PlaceholderScreen(id: 'S23', title: 'Import result', owner: 'Dan'),
                    ),
                  ],
                ),
                GoRoute(
                  path: ':classId',
                  builder: (_, s) => PlaceholderScreen(
                    id: 'S3',
                    title: 'Class overview',
                    owner: 'Dan',
                    params: s.pathParameters,
                  ),
                  routes: [
                    GoRoute(
                      path: 'no-team',
                      builder: (_, s) => PlaceholderScreen(
                          id: 'S4', title: 'Students without a team', owner: 'Dan', params: s.pathParameters),
                    ),
                    GoRoute(
                      path: 'need-members',
                      builder: (_, s) => PlaceholderScreen(
                          id: 'S5', title: 'Teams needing members', owner: 'Khang', params: s.pathParameters),
                    ),
                    GoRoute(
                      path: 'students/:studentId',
                      builder: (_, s) =>
                          PlaceholderScreen(id: 'S7', title: 'Student detail', owner: 'Dan', params: s.pathParameters),
                    ),
                    GoRoute(
                      path: 'matching',
                      builder: (_, s) =>
                          PlaceholderScreen(id: 'S8', title: 'Matching', owner: 'Dan', params: s.pathParameters),
                    ),
                    GoRoute(
                      path: 'no-match',
                      builder: (_, s) =>
                          PlaceholderScreen(id: 'S15', title: 'No match found', owner: 'Khang', params: s.pathParameters),
                    ),
                    GoRoute(
                      path: 'add-student',
                      builder: (_, s) =>
                          PlaceholderScreen(id: 'S16', title: 'Add student', owner: 'Khang', params: s.pathParameters),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.proposals,
              builder: (_, _) => const PlaceholderScreen(id: 'S9', title: 'Proposals', owner: 'Cuong', isTabRoot: true),
              routes: [
                GoRoute(
                  path: ':proposalId',
                  builder: (_, s) =>
                      PlaceholderScreen(id: 'S10', title: 'Proposal detail', owner: 'Cuong', params: s.pathParameters),
                  routes: [
                    GoRoute(
                      path: 'add-member',
                      builder: (_, s) =>
                          PlaceholderScreen(id: 'S11', title: 'Add member', owner: 'Cuong', params: s.pathParameters),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );

  // Tapped push notification -> go to its route, if it is on the allow-list.
  final taps = ref.listen(notificationTapsProvider, (_, next) {
    final route = next.value;
    if (route != null && Routes.isAllowedDeepLink(route)) router.go(route);
  });

  ref.onDispose(() {
    taps.close();
    refresh.dispose();
    router.dispose();
  });
  return router;
});
