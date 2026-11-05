import 'package:flutter/material.dart';

import '../models/major.dart';
import '../theme/app_spacing.dart';

/// Filter by major: All, SE, AI, MKT, GD (S4, S11, S16). Single choice.
/// [selected] null means "All". Scrolls horizontally, 48dp touch target.
class MajorFilterChips extends StatelessWidget {
  const MajorFilterChips({super.key, required this.selected, required this.onSelected});

  final Major? selected;
  final ValueChanged<Major?> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, Major? value) => FilterChip(
          label: Text(label),
          selected: selected == value,
          showCheckmark: true,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (_) => onSelected(value),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: kSpaceMd),
      child: Row(
        children: [
          chip('All', null),
          for (final m in Major.values) ...[const SizedBox(width: kSpaceSm), chip(m.code, m)],
        ],
      ),
    );
  }
}
