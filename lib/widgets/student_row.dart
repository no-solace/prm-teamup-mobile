import 'package:flutter/material.dart';

import '../models/student.dart';

/// Student list row (S4 plain, S11/S16 with checkbox, S16 locked "In a team").
class StudentRow extends StatelessWidget {
  const StudentRow({
    super.key,
    required this.student,
    this.onTap,
    this.checked,
    this.onChecked,
    this.locked = false,
    this.trailing,
  });

  final Student student;
  final VoidCallback? onTap;

  /// Non-null shows a checkbox.
  final bool? checked;
  final ValueChanged<bool>? onChecked;

  /// Locked rows show a lock icon + "In a team", not just a faded look (S16).
  final bool locked;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = [student.major.code, if (student.semester != null) student.semester].join(', ');
    final avatar = CircleAvatar(
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
      child: Text(student.fullName.isEmpty ? '?' : student.fullName[0]),
    );

    final Widget? end = locked
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_outline, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('In a team', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
          ])
        : checked != null
            ? Checkbox(value: checked, onChanged: (v) => onChecked?.call(v ?? false))
            : trailing;

    return Semantics(
      label: 'Student: ${student.fullName}, ${student.major.code}${locked ? ', in a team' : ''}',
      checked: checked,
      enabled: !locked,
      child: ListTile(
        enabled: !locked,
        leading: avatar,
        title: Text(student.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        trailing: end,
        onTap: locked ? null : (checked != null ? () => onChecked?.call(!(checked ?? false)) : onTap),
      ),
    );
  }
}
