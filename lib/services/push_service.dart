import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api.dart';

/// Push notification service using FCM v1.
/// Server: push.php with FCM HTTP v1 + VAPID dual support.
/// Flutter sends its FCM token to server as "fcm:<token>" endpoint.
class PushService {
  static final _local = FlutterLocalNotificationsPlugin();
  static String? fcmToken;

  static const _channel = AndroidNotificationChannel(
    'rqwst_main',
    'Rqwst',
    description: 'طلبات، عروض، رسائل، مكالمات',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> init() async {
    await Firebase.initializeApp();

    // Android notification channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Local notifications init
    await _local.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));

    // Show local notification when app is in foreground
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
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
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
      );
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    // Get token and register with server
    fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _registerWithServer(fcmToken!);
    }

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      fcmToken = token;
      _registerWithServer(token);
    });
  }

  /// Request permission (iOS needs explicit request)
  static Future<String> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) await _registerWithServer(fcmToken!);
        return 'granted';
      case AuthorizationStatus.denied:
        return 'denied';
      default:
        return 'default';
    }
  }

  /// Register FCM token with server as "fcm:<token>" subscription.
  /// Server's push.subscribe action stores it and routes via FCM v1.
  static Future<void> _registerWithServer(String token) async {
    try {
      await ApiService.call('push.subscribe', {
        'fcm_token': token,
        // Send as subscription object so server.php case 'push.subscribe' accepts it
        'subscription': '{"endpoint":"fcm:$token","keys":{}}',
      });
    } catch (_) {
      // Non-fatal — app works without push
    }
  }

  /// Show a local notification manually (e.g. from in-app polling)
  static Future<void> show(String title, String body) async {
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
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
