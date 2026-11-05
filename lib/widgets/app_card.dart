import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Lab 2 "Card": elevation 0, outlineVariant border, whole card tappable.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.semanticsLabel, this.padding = kScreenPadding});

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kTouchTarget),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    if (semanticsLabel == null) return card;
    return Semantics(button: onTap != null, label: semanticsLabel, child: card);
  }
}
