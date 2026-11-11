import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/service_providers.dart';
import '../services/analytics_service.dart';

/// Instrumentation helpers shared by every ViewModel.
///
/// Lab 3 requires two things that must never break a user flow:
///
/// * Analytics events (docs/analytics-plan.md) are recorded on the happy path
///   and are best effort: a tracking outage must not roll back a committed
///   roster or block a sign-in.
/// * Crashlytics receives one non-fatal report for every handled error that
///   comes from a real error path (import failure, AI timeout, upload failure).
///
/// Both are wrapped here so no ViewModel repeats the try/catch boilerplate.
extension InstrumentationRef on Ref {
  /// Runs an analytics call without letting it fail the caller.
  Future<void> trackAnalytics(
    Future<void> Function(AnalyticsService analytics) action,
  ) async {
    try {
      await action(read(analyticsServiceProvider));
    } catch (_) {
      // Tracking is best effort and must not interrupt the user flow.
    }
  }

  /// Records a handled error on Crashlytics. `reason` becomes the report
  /// context shown in the console next to the custom keys.
  Future<void> trackNonFatal(
    Object error,
    StackTrace? stack, {
    required String reason,
  }) async {
    try {
      await read(crashServiceProvider).recordNonFatal(
        error,
        stack,
        reason: reason,
      );
    } catch (_) {
      // Crashlytics is best effort; the user still sees the in-app message.
    }
  }
}
