import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/proposal.dart';
import '../../models/student.dart';
import '../../models/team.dart';
import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../view_state.dart';

/// Entire read/propose/save operation is bounded, not only the matcher call.
final matchingTimeoutProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 30),
);

class MatchingViewModel extends Notifier<ViewState<List<Proposal>>> {
  MatchingViewModel(this.classId);
  final String classId;
  int _generation = 0;
  bool _running = false;

  @override
  ViewState<List<Proposal>> build() {
    ref.onDispose(() => _generation++);
    unawaited(Future<void>.microtask(start));
    return const Loading();
  }

  bool _active(int generation) => ref.mounted && generation == _generation;

  Future<void> start() async {
    if (!ref.mounted || _running) return;
    _running = true;
    final generation = ++_generation;
    state = const Loading();
    final classes = ref.read(classServiceProvider);
    final matcher = ref.read(matchingServiceProvider);
    final proposals = ref.read(proposalServiceProvider);
    try {
      final result = await (() async {
        final values = await Future.wait<Object>([
          classes.watchStudents(classId).first,
          classes.watchTeams(classId).first,
        ], eagerError: true);
        final students = values[0] as List<Student>;
        final teams = values[1] as List<Team>;
        if (!_active(generation)) return <Proposal>[];
        final result = await matcher.propose(
          classId: classId,
          students: students,
          teams: teams,
        );
        // A timeout, Cancel or Back may have happened while propose was awaiting.
        if (!_active(generation)) return <Proposal>[];
        return proposals.savePending(classId, result);
      })().timeout(ref.read(matchingTimeoutProvider));
      if (_active(generation)) {
        state = result.isEmpty ? const Empty() : Data(result);
      }
    } on TimeoutException {
      if (_active(generation)) {
        _running = false;
        _generation++;
        state = const Failure(
          TimeoutAppError(
            'Matching timed out. Check your connection and try again.',
          ),
        );
      }
    } catch (error) {
      if (_active(generation)) state = Failure(toAppError(error));
    } finally {
      if (_active(generation)) _running = false;
    }
  }

  /// Underlying interface has no cancellation token; discard late completions.
  void cancel() {
    _generation++;
    _running = false;
  }
}

final matchingViewModelProvider = NotifierProvider.autoDispose
    .family<MatchingViewModel, ViewState<List<Proposal>>, String>(
      MatchingViewModel.new,
    );
