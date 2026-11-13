import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../view_state.dart';

class ProfileState {
  const ProfileState({this.signingOut = false, this.error});
  final bool signingOut;
  final AppError? error;
}

/// User ViewModels are autoDispose: leaving the shell releases their streams.
class ProfileViewModel extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> signOut() async {
    if (state.signingOut) return;
    state = const ProfileState(signingOut: true);
    final auth = ref.read(authServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);
    final crash = ref.read(crashServiceProvider);
    try {
      // Unregister while Firestore still accepts the current user's token.
      try {
        await ref.read(notificationServiceProvider).unregisterToken();
      } catch (_) {
        // Sign-out must remain available without notification connectivity.
      }
      await auth.signOut();
      if (ref.mounted) state = const ProfileState();
      // A tracking failure must never keep the user signed in.
      try {
        await analytics.logLogout();
      } catch (_) {
        /* Best effort. */
      }
      try {
        await analytics.setUser(null);
      } catch (_) {
        /* Best effort. */
      }
      try {
        await crash.setUser(uid: '', role: 'signed_out');
      } catch (_) {
        /* Best effort. */
      }
      try {
        await crash.setClass(null);
      } catch (_) {
        /* Best effort. */
      }
    } catch (error) {
      if (ref.mounted) state = ProfileState(error: toAppError(error));
    }
  }

  Future<void> testCrash() => ref.read(crashServiceProvider).testCrash();
}

final profileViewModelProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
    );
