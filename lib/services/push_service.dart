import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api.dart';

/// Port of the push notification system from app.js:
/// requestPushPermission(), registerPushSub(), showNotification()
class PushService {
  static final _local = FlutterLocalNotificationsPlugin();
  static String? fcmToken;

  static const _channel = AndroidNotificationChannel(
    'rqwst_main',
    'Rqwst Notifications',
    description: 'Request updates, chat messages, and offers',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> init() async {
    await Firebase.initializeApp();

    // Create Android notification channel
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialize local notifications
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _local.initialize(settings);

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    // Foreground message — show local notification
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        _local.show(
          msg.hashCode,
          n.title,
          n.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id, _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
          ),
        );
      }
    });
  }

  /// Request permission + get token + register with server
  /// Port of requestPushPermission() + registerPushSub()
  static Future<String> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          await _registerWithServer(fcmToken!);
        }
        return 'granted';
      case AuthorizationStatus.denied:
        return 'denied';
      default:
        return 'default';
    }
  }

  /// Send FCM token to server.php → push.subscribe equivalent
  static Future<void> _registerWithServer(String token) async {
    try {
      await ApiService.call('push.subscribe_fcm', {'fcm_token': token});
    } catch (_) {
      // Server may not support FCM yet — non-fatal
    }
  }

  /// Show an in-app or system notification
  /// Port of showNotification(title, body)
  static Future<void> show(String title, String body, {bool force = false}) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          vibrationPattern: Int64List.fromList([0, 200, 100, 200]),
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }
}

/// Must be top-level for Firebase background handler
@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

// Dart doesn't have Int64List in dart:core — need typed_data
class Int64List {
  static List<int> fromList(List<int> list) => list;
}
