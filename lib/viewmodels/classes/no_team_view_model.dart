import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/major.dart';
import '../../models/student.dart';
import '../../providers/service_providers.dart';
import '../view_state.dart';

class NoTeamState {
  const NoTeamState({this.students = const Loading(), this.major});

  final ViewState<List<Student>> students;
  final Major? major;

  List<Student> get visibleStudents => switch (students) {
    Data(:final value) =>
      value.where((s) => major == null || s.major == major).toList(),
    _ => const [],
  };
}

/// Filters only unassigned students; a major filter never changes the source.
class NoTeamViewModel extends Notifier<NoTeamState> {
  NoTeamViewModel(this.classId);
  final String classId;
  StreamSubscription<List<Student>>? _subscription;
  int _generation = 0;

  @override
  NoTeamState build() {
    ref.onDispose(() {
      _generation++;
      unawaited(_subscription?.cancel());
    });
    _listen();
    return const NoTeamState();
  }

  void _listen() {
    final generation = ++_generation;
    unawaited(_subscription?.cancel());
    _subscription = ref
        .read(classServiceProvider)
        .watchStudents(classId)
        .listen(
          (students) {
            if (!ref.mounted || generation != _generation) return;
            final available = students.where((s) => !s.hasTeam).toList();
            state = NoTeamState(
              students: available.isEmpty ? const Empty() : Data(available),
              major: state.major,
            );
          },
          onError: (Object error) {
            if (!ref.mounted || generation != _generation) return;
            state = NoTeamState(
              students: Failure(toAppError(error)),
              major: state.major,
            );
          },
        );
  }

  void selectMajor(Major? major) =>
      state = NoTeamState(students: state.students, major: major);

  void retry() {
    state = NoTeamState(major: state.major);
    _listen();
  }
}

final noTeamViewModelProvider = NotifierProvider.autoDispose
    .family<NoTeamViewModel, NoTeamState, String>(NoTeamViewModel.new);
