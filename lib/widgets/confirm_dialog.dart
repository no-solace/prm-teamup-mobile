import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Lab 2 dialog (confirmation / destructive): S12 Approve, S17 Discard, S24 Remove.
/// Returns true when the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actionsPadding: const EdgeInsets.fromLTRB(kSpaceLg, 0, kSpaceLg, kSpaceMd),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelLabel)),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}
