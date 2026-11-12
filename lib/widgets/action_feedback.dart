import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_error.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// "Tue 18/11 09:30" (no intl dependency for one format).
String shortDateTime(DateTime d) =>
    '${const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1]} '
    '${_two(d.day)}/${_two(d.month)} ${_two(d.hour)}:${_two(d.minute)}';

/// User-facing text for an error from a provider or action.
String errorText(Object error) =>
    error is AppError ? error.message : 'Something went wrong';

void showMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

/// Runs a write and reports the outcome in a SnackBar. True on success.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (success != null && context.mounted) showMessage(context, success);
    return true;
  } catch (e) {
    if (context.mounted) {
      showMessage(context, errorText(e));
    }
    return false;
  }
}

/// Opens a Google Meet link or a file URL in the matching app / browser.
Future<void> openLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  var ok = false;
  try {
    ok = uri != null &&
        uri.scheme == 'https' &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // No app can open it; reported below.
  }
  if (!ok && context.mounted) showMessage(context, 'Could not open the link');
}
