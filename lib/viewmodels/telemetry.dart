import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/service_providers.dart';
import '../services/app_error.dart';

/// Runs an observability call (Analytics, Crashlytics). A tracking outage must
/// never break the user's action, so errors are swallowed.
Future<void> bestEffort(FutureOr<void> Function() action) async {
  try {
    await action();
  } catch (_) {
    // Best effort by design.
  }
}

/// Records a handled (non-fatal) error from a real failure path in Crashlytics.
/// Mistakes the user can fix themselves (validation) and cancellations are not
/// reported: they are not defects.
Future<void> reportHandledError(
  Ref ref,
  Object error,
  StackTrace stack, {
  required String reason,
}) {
  if (error is ValidationError || error is CancelledError) {
    return Future.value();
  }
  return bestEffort(
    () => ref
        .read(crashServiceProvider)
        .recordNonFatal(error, stack, reason: reason),
  );
}
