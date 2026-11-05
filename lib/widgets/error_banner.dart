import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Inline error with icon + text (S13 "Max 6 members", S25 "Needs at least 5
/// members (now 4)", S22 wrong file). Never colour alone.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: 'Error: $message',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kSpaceMd),
        decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: radius(kRadiusSm)),
        child: Row(children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: kSpaceSm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer)),
          ),
        ]),
      ),
    );
  }
}
