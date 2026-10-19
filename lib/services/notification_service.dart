import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodie/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.incrementUnreadCount();

  // Notification payloads are displayed by FCM itself while the app is in the
  // background. Data-only messages need a local notification.
  if (message.notification == null) {
    final notifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await notifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: DarwinInitializationSettings(),
      ),
    );
    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(NotificationService.highPriorityChannel);

    final title = message.data['title'] ?? 'Foodie Alert';
    final body = message.data['body'] ?? 'You have a new update!';
    await notifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationService.highPriorityChannel.id,
          NotificationService.highPriorityChannel.name,
          channelDescription:
              NotificationService.highPriorityChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          autoCancel: true,
        ),
      ),
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const unreadCountKey = 'unread_notification_count';

  static Future<void> incrementUnreadCount() async {
    final preferences = await SharedPreferences.getInstance();
    final currentCount = preferences.getInt(unreadCountKey) ?? 0;
    await preferences.setInt(unreadCountKey, currentCount + 1);
  }

  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel highPriorityChannel =
      AndroidNotificationChannel(
        'foodie_high_importance_channel',
        'Foodie Alerts',
        description: 'Used for important foodie order & flash sale popups.',
        importance: Importance.max,
        playSound: true,
      );

  Future<void> initialize({
    required void Function() onNotificationTapped,
  }) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        onNotificationTapped();
      },
    );

    final androidNotifications = localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidNotifications?.createNotificationChannel(highPriorityChannel);

    final messaging = FirebaseMessaging.instance;
    final messagingSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final localPermissionGranted = await androidNotifications
        ?.requestNotificationsPermission();
    if (messagingSettings.authorizationStatus ==
            AuthorizationStatus.denied ||
        localPermissionGranted == false) {
      debugPrint(
        'Notifications are disabled. Enable notifications for Foodie in '
        'the device settings.',
      );
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    final token = await messaging.getToken();
    debugPrint('FCM DEVICE TOKEN: $token');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          highPriorityChannel.id,
          highPriorityChannel.name,
          channelDescription: highPriorityChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
