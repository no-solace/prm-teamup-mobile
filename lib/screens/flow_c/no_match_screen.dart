import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_view.dart';
import '../flow_a/flow_a_layout.dart';

/// S15. Matching found no complete suggestion; mentor may create one manually.
class NoMatchScreen extends StatelessWidget {
  const NoMatchScreen({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context) => FlowAScaffold(
    title: 'No match found',
    body: const StatusView(
      icon: Icons.group_off_outlined,
      title: 'No match found',
      message:
          'There are not enough available students for an automatic team. '
          'Choose a team and students manually.',
    ),
    bottom: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          label: 'Add manually',
          onPressed: () => context.push(Routes.addStudent(classId)),
        ),
        const SizedBox(height: kSpaceSm),
        AppButton(
          label: 'View teams',
          variant: AppButtonVariant.tonal,
          onPressed: () => context.push(Routes.needMembers(classId)),
        ),
      ],
    ),
  );
}
