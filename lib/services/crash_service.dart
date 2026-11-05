/// Owner: Cuong. Crashlytics wrapper.
abstract interface class CrashService {
  /// User ID + custom keys `role`, `class_id` (Lab 3: at least one key).
  Future<void> setUser({required String uid, required String role});

  Future<void> setClass(String? classId);

  /// Handled error from a real error path (import fails, AI timeout, upload fails).
  Future<void> recordNonFatal(Object error, StackTrace? stack, {required String reason});

  /// Demo area only (S6). Never reachable in normal use.
  void testCrash();
}
