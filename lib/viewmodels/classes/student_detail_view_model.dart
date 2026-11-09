import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../models/student.dart';
import '../../providers/service_providers.dart';
import '../view_state.dart';

typedef StudentKey = ({String classId, String studentId});

class StudentProfile {
  const StudentProfile({required this.student, required this.className});
  final Student student;
  final String className;
}

class StudentDetailViewModel extends Notifier<ViewState<StudentProfile>> {
  StudentDetailViewModel(this.key);
  final StudentKey key;
  int _generation = 0;

  @override
  ViewState<StudentProfile> build() {
    ref.onDispose(() => _generation++);
    unawaited(Future<void>.microtask(retry));
    return const Loading();
  }

  Future<void> retry() async {
    if (!ref.mounted) return;
    final generation = ++_generation;
    state = const Loading();
    final service = ref.read(classServiceProvider);
    try {
      // Future.wait keeps the original service error (record.wait wraps errors
      // in ParallelWaitError, which would hide NotFoundError/NetworkError).
      final values = await Future.wait<Object>([
        service.getStudent(key.classId, key.studentId),
        service.watchClass(key.classId).first,
      ], eagerError: true);
      final student = values[0] as Student;
      final room = values[1] as ClassRoom;
      if (ref.mounted && generation == _generation) {
        state = Data(StudentProfile(student: student, className: room.name));
      }
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        state = Failure(toAppError(error));
      }
    }
  }
}

final studentDetailViewModelProvider = NotifierProvider.autoDispose
    .family<StudentDetailViewModel, ViewState<StudentProfile>, StudentKey>(
      StudentDetailViewModel.new,
    );
