import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class Stat {
  const Stat(this.value, this.label);
  final int value;
  final String label;
}

/// Three numbers with labels and vertical dividers (S3, S23).
class StatTriple extends StatelessWidget {
  const StatTriple({super.key, required this.stats});

  final List<Stat> stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final cells = <Widget>[];
    for (var i = 0; i < stats.length; i++) {
      if (i > 0) cells.add(const VerticalDivider(width: kSpaceMd));
      cells.add(Expanded(
        child: Semantics(
          label: '${stats[i].value} ${stats[i].label}',
          excludeSemantics: true,
          child: Column(children: [
            Text('${stats[i].value}', style: statNumberStyle.copyWith(color: scheme.onSurface)),
            Text(stats[i].label, style: label, textAlign: TextAlign.center),
          ]),
        ),
      ));
    }
    return IntrinsicHeight(child: Row(children: cells));
  }
}
