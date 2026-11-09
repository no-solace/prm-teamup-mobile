import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/class_room.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/class_detail_view_model.dart';
import '../../viewmodels/classes/import_class_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/stat_triple.dart';
import '../../widgets/status_view.dart';
import '../../widgets/view_state_builder.dart';
import 'class_detail_screen.dart';
import 'flow_a_layout.dart';

/// S23. A direct/deep-linked visit without a completed import offers S22.
class ImportResultScreen extends ConsumerWidget {
  const ImportResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(importClassViewModelProvider);
    final result = importState.result;
    if (result == null) {
      return FlowAScaffold(
        title: 'Import result',
        body: StatusView(
          icon: Icons.upload_file,
          title: 'No import yet',
          actionLabel: 'Import class list',
          onAction: () => context.go(Routes.importClass),
        ),
      );
    }
    final classState = ref.watch(classDetailViewModelProvider(result.classId));
    final room = classState is Data<ClassRoom> ? classState.value : null;
    final className = room?.name ?? importState.preview?.className ?? 'class';
    return FlowAScaffold(
      title: 'Import result',
      body: ListView(
        padding: kScreenPadding,
        children: [
          AppCard(
            child: StatTriple(
              stats: [
                Stat(result.imported, 'imported'),
                Stat(result.inAGroup, 'in a group'),
                Stat(result.available, 'available'),
              ],
            ),
          ),
          const SizedBox(height: kSpaceLg),
          if (result.available == 0) ...[
            StatusView(
              icon: Icons.check_circle_outline,
              title: 'All matched',
              message: 'No students available after import.',
              actionLabel: 'View proposals',
              onAction: () => context.go(Routes.proposals),
            ),
          ] else
            ViewStateBuilder<ClassRoom>(
              state: classState,
              onRetry: () => ref
                  .read(classDetailViewModelProvider(result.classId).notifier)
                  .retry(),
              data: (_, room) => ClassDestinations(room: room),
            ),
          const SizedBox(height: kSpaceLg),
          FlowANote(
            title: 'Filtered automatically',
            message:
                '${result.inAGroup} students already in a group and teams with 6 members are hidden.',
          ),
        ],
      ),
      bottom: AppButton(
        label: 'Open $className',
        onPressed: () => context.go(Routes.classDetail(result.classId)),
      ),
    );
  }
}
