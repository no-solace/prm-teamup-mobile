import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../providers/service_providers.dart';
import '../view_state.dart';

/// S3 and the live class summary reused by S23.
class ClassDetailViewModel extends Notifier<ViewState<ClassRoom>> {
  ClassDetailViewModel(this.classId);
  final String classId;
  StreamSubscription<ClassRoom>? _subscription;
  int _generation = 0;

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
          },
          onError: (Object error) {
            if (ref.mounted && generation == _generation) {
              state = Failure(toAppError(error));
            }
          },
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
