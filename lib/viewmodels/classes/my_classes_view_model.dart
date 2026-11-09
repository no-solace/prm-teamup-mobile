import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../providers/service_providers.dart';
import '../view_state.dart';

/// S2 My classes. Owner: Dan.
/// REFERENCE PATTERN for every data-loading screen:
/// 1. build() starts in Loading and subscribes to a service stream;
/// 2. the stream result is mapped to Empty / Data, errors to Failure;
/// 3. retry() re-subscribes (used by the error state's "Try again").
class MyClassesViewModel extends Notifier<ViewState<List<ClassRoom>>> {
  StreamSubscription<List<ClassRoom>>? _sub;

  @override
  ViewState<List<ClassRoom>> build() {
    ref.onDispose(() => _sub?.cancel());
    _listen();
    return const Loading();
  }

  void _listen() {
    _sub?.cancel();
    _sub = ref
        .read(classServiceProvider)
        .watchMyClasses()
        .listen(
          (classes) => state = classes.isEmpty ? const Empty() : Data(classes),
          onError: (Object e) => state = Failure(toAppError(e)),
        );
  }

  void retry() {
    state = const Loading();
    _listen();
  }
}

final myClassesViewModelProvider =
    NotifierProvider.autoDispose<
      MyClassesViewModel,
      ViewState<List<ClassRoom>>
    >(MyClassesViewModel.new);
