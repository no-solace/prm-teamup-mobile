import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../view_state.dart';

/// First sign-in: pick Mentor, or link to an imported student (class code +
/// MSSV). The session stream re-emits with the new role and the router moves on.
class OnboardingViewModel extends Notifier<({bool busy, AppError? error})> {
  @override
  ({bool busy, AppError? error}) build() => (busy: false, error: null);

  Future<void> _run(Future<void> Function() body) async {
    if (state.busy) return;
    state = (busy: true, error: null);
    try {
      await body();
      state = (busy: false, error: null);
    } catch (e) {
      state = (busy: false, error: toAppError(e));
    }
  }

  Future<void> becomeMentor() =>
      _run(() => ref.read(authServiceProvider).completeMentorProfile());

  Future<void> joinTeam({
    required String classId,
    required String studentId,
    required bool leader,
  }) => _run(() {
    if (classId.trim().isEmpty || studentId.trim().isEmpty) {
      throw const ValidationError('Enter the class code and your student ID');
    }
    return ref.read(authServiceProvider).completeStudentProfile(
      classId: classId,
      studentId: studentId,
      leader: leader,
    );
  });
}

final onboardingProvider =
    NotifierProvider<OnboardingViewModel, ({bool busy, AppError? error})>(
      OnboardingViewModel.new,
    );
