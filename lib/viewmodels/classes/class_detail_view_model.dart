import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../providers/service_providers.dart';
import '../instrumentation.dart';
import '../view_state.dart';

/// S3 and the live class summary reused by S23.
class ClassDetailViewModel extends Notifier<ViewState<ClassRoom>> {
  ClassDetailViewModel(this.classId);
  final String classId;
  StreamSubscription<ClassRoom>? _subscription;
  int _generation = 0;
  bool _viewTracked = false;

  @override
  ViewState<ClassRoom> build() {
    ref.onDispose(() {
      _generation++;
      unawaited(_subscription?.cancel());
    });
    _listen();
    return const Loading();
  }

  void _listen() {
    final generation = ++_generation;
    unawaited(_subscription?.cancel());
    _subscription = ref
        .read(classServiceProvider)
        .watchClass(classId)
        .listen(
          (room) {
            if (ref.mounted && generation == _generation) state = Data(room);
            _trackView(room);
          },
          onError: (Object error) {
            if (ref.mounted && generation == _generation) {
              state = Failure(toAppError(error));
            }
          },
        );
  }

  /// docs/analytics-plan.md: view_item opens once per class detail visit.
  void _trackView(ClassRoom room) {
    if (_viewTracked) return;
    _viewTracked = true;
    unawaited(
      ref.trackAnalytics(
        (analytics) =>
            analytics.logViewItem(itemCategory: 'class', itemId: room.id),
      ),
    );
  }

  void retry() {
    state = const Loading();
    _listen();
  }
}

final classDetailViewModelProvider = NotifierProvider.autoDispose
    .family<ClassDetailViewModel, ViewState<ClassRoom>, String>(
      ClassDetailViewModel.new,
    );
