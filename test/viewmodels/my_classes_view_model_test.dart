import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/class_room.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/fakes/fake_class_service.dart';
import 'package:teamup_exe/viewmodels/classes/my_classes_view_model.dart';
import 'package:teamup_exe/viewmodels/view_state.dart';

/// Reference ViewModel test: every owner copies this shape (D16).
class _FailingClassService extends FakeClassService {
  @override
  Stream<List<ClassRoom>> watchMyClasses() => Stream.error(const NetworkError());
}

ProviderContainer _container({FakeClassService? classes}) {
  final c = ProviderContainer(
    overrides: fakeOverrides(classService: classes ?? FakeClassService(latency: Duration.zero)),
  );
  addTearDown(c.dispose);
  return c;
}

/// Keeps the autoDispose provider alive and returns the state after the stream emits.
Future<ViewState<List<ClassRoom>>> _settle(ProviderContainer c) async {
  final sub = c.listen(myClassesViewModelProvider, (_, _) {});
  addTearDown(sub.close);
  await pumpEventQueue();
  return c.read(myClassesViewModelProvider);
}

void main() {
  test('starts in Loading', () {
    final c = _container();
    final sub = c.listen(myClassesViewModelProvider, (_, _) {});
    addTearDown(sub.close);
    expect(c.read(myClassesViewModelProvider), isA<Loading<List<ClassRoom>>>());
  });

  test('emits Data with the sample classes', () async {
    final state = await _settle(_container());
    expect(state, isA<Data<List<ClassRoom>>>());
    expect((state as Data<List<ClassRoom>>).value, isNotEmpty);
  });

  test('maps a network error to Failure(NetworkError)', () async {
    final state = await _settle(_container(classes: _FailingClassService()));
    expect(state, isA<Failure<List<ClassRoom>>>());
    expect((state as Failure<List<ClassRoom>>).error, isA<NetworkError>());
  });
}
