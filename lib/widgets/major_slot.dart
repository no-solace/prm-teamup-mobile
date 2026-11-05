import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../models/major.dart';
import '../theme/app_spacing.dart';

enum MajorSlotKind { filled, proposed, open }

/// One "ô ngành" (S5, S9, S10, S20, S25): filled = member, proposed = new member
/// (with +), open = dashed empty slot.
class MajorSlot extends StatelessWidget {
  const MajorSlot({super.key, this.major, this.kind = MajorSlotKind.filled, this.size = kMajorSlotSmall});

  final Major? major;
  final MajorSlotKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme.labelLarge;
    final label = major?.code ?? '';

    final semantic = switch (kind) {
      MajorSlotKind.filled => 'Member, $label',
      MajorSlotKind.proposed => 'Proposed member, $label',
      MajorSlotKind.open => 'Open slot',
    };

    final Widget box = switch (kind) {
      MajorSlotKind.filled => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: radius(kRadiusSm)),
          child: Text(label, style: text?.copyWith(color: scheme.onSecondaryContainer)),
        ),
      MajorSlotKind.proposed => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: radius(kRadiusSm),
            border: Border.all(color: scheme.primary, width: 2),
          ),
          child: Text('+$label', style: text?.copyWith(color: scheme.onPrimaryContainer)),
        ),
      MajorSlotKind.open => DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(kRadiusSm),
            color: scheme.outline,
            dashPattern: const [4, 3],
            padding: EdgeInsets.zero,
          ),
          child: SizedBox(width: size - 2, height: size - 2),
        ),
    };
    return Semantics(label: semantic, child: ExcludeSemantics(child: box));
  }
}

/// A row of up to 6 slots, never scrolls horizontally (S5 constraint).
class MajorSlotRow extends StatelessWidget {
  const MajorSlotRow({
    super.key,
    required this.members,
    this.proposed = const [],
    this.size = kMajorSlotSmall,
    this.showOpenSlots = true,
  });

  final List<Major> members;
  final List<Major> proposed;
  final double size;
  final bool showOpenSlots;

  @override
  Widget build(BuildContext context) {
    final filled = members.length + proposed.length;
    final open = showOpenSlots ? (TeamRules.maxMembers - filled).clamp(0, TeamRules.maxMembers) : 0;
    return Wrap(
      spacing: kSpaceSm,
      runSpacing: kSpaceSm,
      children: [
        for (final m in members) MajorSlot(major: m, size: size),
        for (final m in proposed) MajorSlot(major: m, kind: MajorSlotKind.proposed, size: size),
        for (var i = 0; i < open; i++) MajorSlot(kind: MajorSlotKind.open, size: size),
      ],
    );
  }
}
