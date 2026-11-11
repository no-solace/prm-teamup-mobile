import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../services/crash_service.dart';

/// Owner: Cuong. Fatal errors are wired in main.dart (FlutterError.onError,
/// PlatformDispatcher.onError); this class covers user ID, keys and non-fatals.
class FirebaseCrashService implements CrashService {
  FirebaseCrashService({FirebaseCrashlytics? crashlytics}) : _injected = crashlytics;

  final FirebaseCrashlytics? _injected;

  /// Resolved lazily: `FirebaseCrashlytics.instance` throws when Firebase is
  /// not initialised, and that must not break the provider that reads it.
  late final FirebaseCrashlytics _c =
      _injected ?? FirebaseCrashlytics.instance;

  @override
  Future<void> setUser({required String uid, required String role}) async {
    await _c.setUserIdentifier(uid);
    await _c.setCustomKey('role', role);
  }

  @override
  Future<void> setClass(String? classId) => _c.setCustomKey('class_id', classId ?? 'none');

  @override
  Future<void> recordNonFatal(Object error, StackTrace? stack, {required String reason}) =>
      _c.recordError(error, stack, reason: reason, fatal: false);

  /// Report appears in the console after the app is opened again.
  @override
  void testCrash() => _c.crash();
}
