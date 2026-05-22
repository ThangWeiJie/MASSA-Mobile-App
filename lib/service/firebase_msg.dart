import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> handleNotification(RemoteMessage msg) async {
  print("I have been fired");
}

class FirebaseMsg {
  final msgService = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initFCM() async {
    await msgService.requestPermission();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
        settings: const InitializationSettings(android: android)
    );

    const channel = AndroidNotificationChannel(
      'defaultChannel',
      'General Notifications',
      importance: Importance.high
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    var token = await msgService.getToken();
    print("Token: $token");

    FirebaseMessaging.onBackgroundMessage(handleNotification);
    FirebaseMessaging.onMessage.listen((msg) {
      handleNotification(msg);
      _showNotification(msg);
    });
  }

  Future<void> _showNotification(RemoteMessage msg) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'defaultChannel',
        'General Notifications',
        importance: Importance.high,
        priority: Priority.high
      )
    );

    await _localNotifications.show(id: 0, title: msg.notification?.title, body: msg.notification?.body, notificationDetails: details);
  }
}