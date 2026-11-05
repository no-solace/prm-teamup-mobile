import 'package:flutter/material.dart';

import '../models/proposal.dart';

/// "Strong fit" / "Good fit" (S9, S10): icon + text, never colour alone.
class FitChip extends StatelessWidget {
  const FitChip({super.key, required this.fit});

  final ProposalFit fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, icon, bg, fg) = switch (fit) {
      ProposalFit.strong => ('Strong fit', Icons.verified, scheme.tertiaryContainer, scheme.onTertiaryContainer),
      ProposalFit.good => ('Good fit', Icons.thumb_up_alt_outlined, scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return Chip(
      avatar: Icon(icon, size: 18, color: fg),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
      backgroundColor: bg,
      side: BorderSide.none,
    );
  }
}

/// "Added by you" chip on S20.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: icon == null ? null : Icon(icon, size: 18, color: scheme.onSecondaryContainer),
      label: Text(label),
      backgroundColor: scheme.secondaryContainer,
      side: BorderSide.none,
    );
  }
}
