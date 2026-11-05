import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, tonal, text, destructive }

/// Lab 2 "Button" (primary / tonal / text) + destructive (S17, S24).
/// 48dp high, full width by default, spinner when [loading].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
    this.semanticsLabel,
  });

  final String label;

  /// Null disables the button (for example S13 Add, S25 Approve).
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;
  final bool expand;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onTap = loading ? null : onPressed;
    final child = loading
        ? SizedBox.square(
            dimension: kSpaceLg - kSpaceXs,
            child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary),
          )
        : Text(label);

    Widget button = switch (variant) {
      AppButtonVariant.primary => icon == null
          ? FilledButton(onPressed: onTap, child: child)
          : FilledButton.icon(onPressed: onTap, icon: Icon(icon), label: child),
      AppButtonVariant.tonal => icon == null
          ? FilledButton.tonal(onPressed: onTap, child: child)
          : FilledButton.tonalIcon(onPressed: onTap, icon: Icon(icon), label: child),
      AppButtonVariant.text => TextButton(onPressed: onTap, child: child),
      AppButtonVariant.destructive => FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          child: child,
        ),
    };

    if (expand) button = SizedBox(width: double.infinity, child: button);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: button,
    );
  }
}
