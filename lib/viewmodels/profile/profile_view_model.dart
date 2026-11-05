import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';

/// S6 Profile actions. Owner: Ken (profile, sign out); Cuong adds the
/// Firebase demo actions (export + upload) in a demo view model.
///
/// Clearing local user data on sign-out (Lab 3 Auth): every per-user ViewModel
/// is `autoDispose`, so when the router leaves the tab shell for /sign-in they
/// are disposed and nothing of the previous mentor stays in memory.
class ProfileViewModel extends Notifier<void> {
  @override
  void build() {}

  Future<void> signOut() async {
    await ref.read(analyticsServiceProvider).logLogout();
    await ref.read(authServiceProvider).signOut();
  }

  /// Demo area only (owner: Cuong).
  void testCrash() => ref.read(crashServiceProvider).testCrash();
}

final profileViewModelProvider = NotifierProvider<ProfileViewModel, void>(ProfileViewModel.new);
