import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jkautomed/main.dart'; // ajugnuGlobalContext yahan se aata hai

// Agar OrderHistoryScreen ya apne notification screen ka import chahiye to yahan daal dena
// import '../screens/customer_notifications_screen.dart'; // example

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Yeh flag double navigation rokega
  bool _initialNotificationHandled = false;

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Important notifications for Ajugnu',
    importance: Importance.max,
    playSound: true,
  );

  Future<void> initialize() async {
    // Reset flag on every app start (safety)
    _initialNotificationHandled = false;

    // Permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground notification settings
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications initialization
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    );

    // Android channel create
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    // 1. App terminated state se launch (notification tap)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null && !_initialNotificationHandled) {
      _initialNotificationHandled = true;
      _handleMessage(initialMessage);
    }

    // 2. Background se foreground (notification tap)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (!_initialNotificationHandled) {
        _initialNotificationHandled = true;
        _handleMessage(message);
      }
    });

    // 3. Foreground messages (sirf show karo, navigation mat karo)
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background handler register
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Foreground message handler
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: _androidChannel.importance,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data), // JSON payload bhej rahe hain
    );
  }

  // Local notification tap (foreground/background)
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null && !_initialNotificationHandled) {
      _initialNotificationHandled = true;
      _handlePayload(response.payload!);
    }
  }

  // Background notification tap (killed state)
  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
    // Yeh static hona chahiye background ke liye
    if (response.payload != null) {
      // Yahan direct navigation mushkil hai, isliye onMessageOpenedApp par rely karo
      // ya global flag use karo (advanced)
    }
  }

  // Common message handler
  void _handleMessage(RemoteMessage message) {
    _navigateToNotifications(); // Ya apna logic daal do
  }

  // Payload se navigation (local notification ke liye)
  void _handlePayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      // Agar screen type check karna ho to yahan kar sakte ho
      _navigateToNotifications();
    } catch (e) {
      debugPrint('Payload parse error: $e');
      _navigateToNotifications(); // default
    }
  }

  // Yeh function apne hisaab se change kar dena
  void _navigateToNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = ajugnuGlobalContext.currentContext;
      if (context == null || !context.mounted) return;

      // Example: Customer notifications screen
      // Navigator.of(context).push(
      //   MaterialPageRoute(builder: (_) => const CustomerNotificationsScreen()),
      // );

      // Ya tumhare AjugnuNavigations class ka use karo
      // AjugnuNavigations.customerNotificationsScreen(onNotificationRead: () {});

      debugPrint("Navigating to notifications screen from tap");
    });
  }
}

// Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Sirf notification show karo, navigation mat karo
  await NotificationService()._onForegroundMessage(message);
}