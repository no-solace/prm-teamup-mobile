import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/proposal_student_picker.dart';
import '../../widgets/status_view.dart';
import '../flow_a/flow_a_layout.dart';

/// S16/S20/S21. A manual proposal is saved as pending for mentor review.
class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({
    super.key,
    required this.classId,
    this.teamId,
    this.studentId,
  });
  final String classId;
  final String? teamId;
  final String? studentId;

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  String? _teamId;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _teamId = widget.teamId;
    _selected = {if (widget.studentId != null) widget.studentId!};
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(proposalTeamsProvider(widget.classId));
    final students = ref.watch(proposalStudentsProvider(widget.classId));
    final busy = ref.watch(proposalActionProvider);
    final options = teams.value?.where((team) => !team.isFull).toList();
    final selectedTeam = options
        ?.where((team) => team.id == _teamId)
        .firstOrNull;
    final capacity = selectedTeam == null ? 0 : 6 - selectedTeam.size;
    final validStudentIds = students.value
        ?.where((student) => !student.hasTeam)
        .map((student) => student.mssv)
        .toSet();
    final validSelection = _selected
        .where((id) => validStudentIds?.contains(id) ?? false)
        .take(capacity)
        .toSet();

    return FlowAScaffold(
      title: 'Add student manually',
      body: teams.isLoading || students.isLoading
          ? const Center(child: CircularProgressIndicator())
          : teams.hasError || students.hasError
          ? StatusView.error(
              message: '${teams.error ?? students.error}',
              onRetry: () {
                ref.invalidate(proposalTeamsProvider(widget.classId));
                ref.invalidate(proposalStudentsProvider(widget.classId));
              },
            )
          : options == null || options.isEmpty
          ? const StatusView(
              icon: Icons.check_circle_outline,
              title: 'All teams are full',
            )
          : Column(
              children: [
                Padding(
                  padding: kScreenPadding,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedTeam?.id,
                    decoration: const InputDecoration(
                      labelText: 'Select a team',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final team in options)
                        DropdownMenuItem(
                          value: team.id,
                          child: Text('${team.name} (${team.size}/6)'),
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _teamId = value;
                      if (widget.studentId == null) _selected.clear();
                    }),
                  ),
                ),
                Expanded(
                  child: selectedTeam == null
                      ? const StatusView(
                          icon: Icons.groups_outlined,
                          title: 'Choose a team first',
                        )
                      : ProposalStudentPicker(
                          students: students.value!,
                          selected: validSelection,
                          capacity: capacity,
                          onChanged: (value) =>
                              setState(() => _selected = value),
                        ),
                ),
              ],
            ),
      bottom: AppButton(
        label: 'Create proposal',
        loading: busy,
        onPressed: selectedTeam == null || validSelection.isEmpty || busy
            ? null
            : () async {
                try {
                  final proposal = await ref
                      .read(proposalActionProvider.notifier)
                      .createManual(
                        widget.classId,
                        selectedTeam.id,
                        validSelection.toList()..sort(),
                      );
                  if (context.mounted) context.go(Routes.proposal(proposal.id));
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(toAppError(error).message)),
                    );
                  }
                }
              },
      ),
    );
  }
}
