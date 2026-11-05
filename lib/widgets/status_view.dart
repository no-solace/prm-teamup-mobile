import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Lab 2 shared "StatusView": Center(Column(Icon, Text, Button)).
/// Used for loading, empty and error states, and for S14, S15, S18, S21.
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  /// Generic error state with "Try again".
  factory StatusView.error({required String message, VoidCallback? onRetry}) => StatusView(
        icon: Icons.error_outline,
        title: message,
        actionLabel: onRetry == null ? null : 'Try again',
        onAction: onRetry,
      );

  /// S18 Offline.
  factory StatusView.offline({VoidCallback? onRetry}) => StatusView(
        icon: Icons.wifi_off,
        title: "You're offline",
        message: 'Check your connection and try again.',
        actionLabel: 'Try again',
        onAction: onRetry,
      );

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(kSpaceLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: kSpaceXl * 2, color: scheme.onSurfaceVariant),
              const SizedBox(height: kSpaceMd),
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              if (message != null) ...[
                const SizedBox(height: kSpaceSm),
                Text(message!, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant), textAlign: TextAlign.center),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: kSpaceLg),
                AppButton(label: actionLabel!, onPressed: onAction),
              ],
              if (secondaryLabel != null) ...[
                const SizedBox(height: kSpaceSm),
                AppButton(label: secondaryLabel!, onPressed: onSecondary, variant: AppButtonVariant.text),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen loading (or use a skeleton where the spec says so).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) => Center(
        child: Semantics(
          label: label ?? 'Loading',
          child: const CircularProgressIndicator(),
        ),
      );
}
