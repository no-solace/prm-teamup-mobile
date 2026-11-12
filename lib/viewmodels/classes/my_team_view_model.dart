import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/student.dart';
import '../../models/team.dart';
import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../auth/session_view_model.dart';

/// Student "My team" tab: only the signed-in student's own team.
final myTeamProvider =
    StreamProvider.autoDispose<({Team team, List<Student> members})>((ref) {
      final user = ref.watch(sessionProvider).value;
      if (user == null || !user.isStudent) {
        return Stream.error(const PermissionDeniedError('Students only'));
      }
      return ref
          .watch(classServiceProvider)
          .watchMyTeam(user.classId!, user.teamId!);
    });
