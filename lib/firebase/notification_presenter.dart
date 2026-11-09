import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract interface class NotificationPresenter {
  Future<String?> initialize(void Function(String payload) onTap);
  Future<void> show(RemoteMessage message, String payload);
  Future<void> clear();
}

class AndroidNotificationPresenter implements NotificationPresenter {
  AndroidNotificationPresenter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channel = AndroidNotificationChannel(
    'teamup_default',
    'TeamUp updates',
    description: 'Class and proposal notifications',
    importance: Importance.high,
  );
  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<String?> initialize(void Function(String payload) onTap) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_teamup'),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) onTap(response.payload!);
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    final launch = await _plugin.getNotificationAppLaunchDetails();
    return launch?.didNotificationLaunchApp == true
        ? launch?.notificationResponse?.payload
        : null;
  }

  @override
  Future<void> show(RemoteMessage message, String payload) => _plugin.show(
    id: payload.hashCode & 0x7fffffff,
    title:
        message.notification?.title ??
        message.data['title'] as String? ??
        'TeamUp EXE',
    body: message.notification?.body ?? message.data['body'] as String? ?? '',
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_stat_teamup',
      ),
    ),
    payload: payload,
  );

  @override
  Future<void> clear() => _plugin.cancelAll();
}

String notificationPayload({
  required String uid,
  required String id,
  String? route,
}) => jsonEncode({'uid': uid, 'id': id, 'route': route});
