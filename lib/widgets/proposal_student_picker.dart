import 'package:flutter/material.dart';

import '../models/major.dart';
import '../models/student.dart';
import '../theme/app_spacing.dart';
import 'error_banner.dart';
import 'major_filter_chips.dart';
import 'status_view.dart';
import 'student_row.dart';

/// Shared S11/S16 student picker with the S13 size cap and S21 no-result state.
///
/// Lab 2 handoff (S11 + S13):
/// * the meta line reads `team name, N of 6` — N is the team size *after*
///   the selection is applied ("FinLite, 6 of 6");
/// * ticking a student that would push the team past six is refused and
///   shows the inline error "Max 6 members" (S13);
/// * while that error is on screen the confirm button is locked, and
///   unchecking a student clears the error and unlocks the button.
///
/// The single invariant the screen keeps is: **the confirm button is enabled
/// exactly when the error banner is hidden**.
class ProposalStudentPicker extends StatefulWidget {
  const ProposalStudentPicker({
    super.key,
    required this.students,
    required this.selected,
    required this.capacity,
    required this.onChanged,
    this.teamName,
    this.currentSize = 0,
    this.onLimit,
    this.onValidityChanged,
  });

  final List<Student> students;
  final Set<String> selected;

  /// Remaining places on the team: `TeamRules.maxMembers - currentSize`.
  final int capacity;

  final ValueChanged<Set<String>> onChanged;

  /// Name of the team the members are added to (S11: "FinLite, 6 of 6").
  final String? teamName;

  /// Members already in the team, excluding the ones selected here.
  final int currentSize;

  final VoidCallback? onLimit;

  /// Reports whether the current selection is acceptable. The caller locks
  /// its confirm button while this is false (S13: "nút Add bị khóa").
  final ValueChanged<bool>? onValidityChanged;

  /// True when the team is already full: the error banner stays visible and
  /// the caller disables its confirm button.
  bool get isAtCapacity => capacity <= 0;

  /// "FinLite, 6 of 6" — the Lab 2 meta line for S11 and S13.
  String get metaLabel {
    final size = currentSize + selected.length;
    return teamName == null ? '$size of 6' : '$teamName, $size of 6';
  }

  @override
  State<ProposalStudentPicker> createState() => _ProposalStudentPickerState();
}

class _ProposalStudentPickerState extends State<ProposalStudentPicker> {
  Major? _major;
  String _query = '';
  bool _limitReached = false;

  @override
  void initState() {
    super.initState();
    // The team is already full before the user picks anybody: the error and
    // the locked button must be visible from the first frame.
    if (widget.isAtCapacity) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onValidityChanged?.call(false),
      );
    }
  }

  void _change(Student student, bool checked) {
    if (student.hasTeam) return;
    final next = {...widget.selected};
    if (checked && !next.contains(student.mssv)) {
      if (next.length >= widget.capacity) {
        // S13: the pick is refused, the reason stays on screen and the
        // confirm button is locked until the user fixes the selection.
        widget.onLimit?.call();
        setState(() => _limitReached = true);
        widget.onValidityChanged?.call(false);
        return;
      }
      next.add(student.mssv);
    } else if (!checked) {
      next.remove(student.mssv);
    }
    setState(() => _limitReached = false);
    widget.onValidityChanged?.call(!widget.isAtCapacity);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.students
        .where(
          (student) =>
              (_major == null || student.major == _major) &&
              (student.fullName.toLowerCase().contains(_query) ||
                  student.mssv.toLowerCase().contains(_query)),
        )
        .toList();
    final atCapacity = _limitReached || widget.isAtCapacity;
    return Column(
      children: [
        Padding(
          padding: kScreenPadding,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search name or student ID',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
          ),
        ),
        MajorFilterChips(
          selected: _major,
          onSelected: (value) => setState(() => _major = value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpaceMd,
            vertical: kSpaceSm,
          ),
          child: Text(widget.metaLabel),
        ),
        if (atCapacity)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: kSpaceMd),
            child: ErrorBanner(message: 'Max 6 members'),
          ),
        Expanded(
          child: filtered.isEmpty
              ? const StatusView(
                  icon: Icons.search_off,
                  title: 'No student results',
                  message: 'Try a different search or major.',
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final student = filtered[index];
                    return StudentRow(
                      student: student,
                      locked: student.hasTeam,
                      checked: widget.selected.contains(student.mssv),
                      onChecked: (value) => _change(student, value),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
