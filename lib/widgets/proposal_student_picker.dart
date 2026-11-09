import 'package:flutter/material.dart';

import '../models/major.dart';
import '../models/student.dart';
import '../theme/app_spacing.dart';
import 'major_filter_chips.dart';
import 'status_view.dart';
import 'student_row.dart';

/// Shared S11/S16 student picker with the S13 size cap and S21 no-result state.
class ProposalStudentPicker extends StatefulWidget {
  const ProposalStudentPicker({
    super.key,
    required this.students,
    required this.selected,
    required this.capacity,
    required this.onChanged,
    this.onLimit,
  });

  final List<Student> students;
  final Set<String> selected;
  final int capacity;
  final ValueChanged<Set<String>> onChanged;
  final VoidCallback? onLimit;

  @override
  State<ProposalStudentPicker> createState() => _ProposalStudentPickerState();
}

class _ProposalStudentPickerState extends State<ProposalStudentPicker> {
  Major? _major;
  String _query = '';

  void _change(Student student, bool checked) {
    if (student.hasTeam) return;
    final next = {...widget.selected};
    if (checked && !next.contains(student.mssv)) {
      if (next.length >= widget.capacity) {
        widget.onLimit?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A team can have at most 6 members')),
        );
        return;
      }
      next.add(student.mssv);
    } else if (!checked) {
      next.remove(student.mssv);
    }
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
          child: Text(
            '${widget.selected.length} of ${widget.capacity} places selected',
          ),
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
