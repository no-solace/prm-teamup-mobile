import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase/background_notification_handler.dart';
import 'firebase/fcm_notification_service.dart';
import 'firebase/firebase_config_service.dart';
import 'firebase_options.dart';
import 'providers/service_providers.dart';

/// FCM background handler: must be top-level and annotated (D10).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await keepBackgroundNotification(message);
}

/// The submitted build: real Firebase services only (D6, C10).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics catches Flutter and async errors (Lab 3: Crashlytics).
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode || const bool.fromEnvironment('CRASHLYTICS_DEBUG'));
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final config = FirebaseConfigService();
  final notifications = FcmNotificationService();

  runApp(ProviderScope(
    overrides: [
      configServiceProvider.overrideWithValue(config),
      notificationServiceProvider.overrideWithValue(notifications),
    ],
    child: const TeamUpApp(),
  ));

  // After runApp: being offline must never block the first screen (D10).
  unawaited(config.init());
  unawaited(notifications.start());
}
