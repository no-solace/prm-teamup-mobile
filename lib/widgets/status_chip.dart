import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum StatusTone { neutral, waiting, good, bad }

/// Small status label for topics and meetings.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.tone = StatusTone.neutral});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      StatusTone.neutral => (s.surfaceContainerHighest, s.onSurfaceVariant),
      StatusTone.waiting => (s.tertiaryContainer, s.onTertiaryContainer),
      StatusTone.good => (s.primaryContainer, s.onPrimaryContainer),
      StatusTone.bad => (s.errorContainer, s.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpaceSm, vertical: kSpaceXs),
      decoration: BoxDecoration(color: bg, borderRadius: radius(kRadiusFull)),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
    );
  }
}
