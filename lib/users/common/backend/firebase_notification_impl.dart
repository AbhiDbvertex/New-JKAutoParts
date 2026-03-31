// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:jkautomed/ajugnu_navigations.dart';
// import 'package:jkautomed/firebase_options.dart';
// import 'package:jkautomed/users/common/backend/ajugnu_auth.dart';
// import 'package:jkautomed/users/common/backend/api_handler.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
//
// String firebaseNotificationToken = '';
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//
//   adebug('${message.data}', tag: 'Firebase Notification background');
//   String? title = message.data['title'];
//   String? body = message.data['body'];
//   String? imageUrl = message.data['imageUrl'];
//
//   await initializeFirebase();
//
//   if (title != null && body != null) {
//     showNotification(
//         generateUniqueId(message.messageId ?? 'default'),
//         title,
//         body,
//         imageUrl
//     );
//   }
// }
//
// @pragma('vm:entry-point')
// Future<void> _handleBackgroundNotificationResponse(
//     NotificationResponse notificationResponse) async {
//   adebug('onDidReceiveBackgroundNotificationResponse',
//       tag: notificationResponse.payload ?? 'its null');
//   _handleNotification(notificationResponse.payload ?? '');
// }
//
// Future<void> showNotification(
//     int id, String title, String body, String? imageUrl) async {
//   String? localImagePath;
//   BigPictureStyleInformation? bigPictureStyleInformation;
//
//   // Check if imageUrl is not null or empty
//   if (imageUrl != null && imageUrl.isNotEmpty) {
//     try {
//       final response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         // Save the image to a temporary directory
//         final Directory tempDir = await getTemporaryDirectory();
//         final File file = File('${tempDir.path}/downloaded_image_${id}.jpg');
//         await file.writeAsBytes(response.bodyBytes);
//         localImagePath = file.path;
//
//         // Create BigPictureStyleInformation only if the image was successfully downloaded
//         bigPictureStyleInformation = BigPictureStyleInformation(
//           FilePathAndroidBitmap(localImagePath),
//           contentTitle: title,
//           summaryText: body,
//           htmlFormatContent: true,
//           htmlFormatContentTitle: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('Failed to load image: $e');
//     }
//   }
//
//   // Create AndroidNotificationDetails with or without the big picture style
//   AndroidNotificationDetails androidPlatformChannelSpecifics =
//   AndroidNotificationDetails(
//     'ajugnu_push_notifications',
//     'ajugnuAppName',
//     channelDescription: 'Notifications of ajugnu.',
//     importance: Importance.max,
//     priority: Priority.high,
//     styleInformation: bigPictureStyleInformation,
//     largeIcon: localImagePath != null
//         ? FilePathAndroidBitmap(localImagePath)
//         : null, // Set large icon only if image exists
//   );
//
//   NotificationDetails platformChannelSpecifics =
//   NotificationDetails(android: androidPlatformChannelSpecifics);
//
//   await flutterLocalNotificationsPlugin.show(
//       id, title, body, platformChannelSpecifics,
//       payload: jsonEncode({'title': title, 'body': body}));
// }
//
//
// Future<String> initializeFirebaseNotifications() async {
//   final messaging = FirebaseMessaging.instance;
//
//   await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);
//
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) {
//     adebug('onDidReceiveNotificationResponse',
//         tag: notificationResponse.payload ?? 'its null');
//     _handleNotification(notificationResponse.payload ?? '');
//   },
//       onDidReceiveBackgroundNotificationResponse:
//           _handleBackgroundNotificationResponse);
//
//   FirebaseMessaging.onMessage.listen((message) {
//
//     adebug('${message.data}', tag: 'Firebase Notification foreground');
//     String? title = message.data['title'];
//     String? body = message.data['body'];
//     String? imageUrl = message.data['imageUrl'];
//
//
//     if (title != null && body != null) {
//       showNotification(
//           generateUniqueId(message.messageId ?? 'default'),
//           title,
//           body,
//          imageUrl
//       );
//     }
//   }, onError: (error) => adebug('$error'));
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   firebaseNotificationToken = await messaging.getToken() ?? "invalid token";
//   adebug(firebaseNotificationToken, tag: 'Firebase Token');
//
//   FirebaseMessaging.onMessageOpenedApp.listen((msg) {
//     adebug('onMessageOpenedApp');
//
//     _handleNotification(msg.data['title'] ?? '');
//   });
//   var msg = await messaging.getInitialMessage();
//   if (msg?.data != null) {
//     adebug('getInitialMessage');
//     _handleNotification(msg?.data['title'] ?? '');
//   } else {
//     adebug(await messaging.getInitialMessage(), tag: 'getInitialMessage');
//   }
//
//   final NotificationAppLaunchDetails? notificationAppLaunchDetails =
//       await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
//   if (notificationAppLaunchDetails != null &&
//       notificationAppLaunchDetails.didNotificationLaunchApp) {
//     adebug('launched by notification');
//     if (notificationAppLaunchDetails.notificationResponse != null) {
//       _handleBackgroundNotificationResponse(
//           notificationAppLaunchDetails.notificationResponse!);
//     }
//   }
//
//   return firebaseNotificationToken;
// }
//
// void _handleNotification(String message, [String? role]) {
//   role ??= AjugnuAuth().getUser()?.role;
//   if (role == 'user') {
//     // AjugnuNavigations.customerOrderPageScreen();
//     AjugnuNavigations.customerNotificationsScreen(onNotificationRead: (){});
//     // Navigator.push(context, MaterialPageRoute(builder: ()))
//   } else if (role == 'supplier') {
//     if (message.toLowerCase().contains('product sold')) {
//       adebug('user', tag: '_handleNotification($message)');
//       // AjugnuNavigations.supplierOrderPageScreen();
//       AjugnuNavigations.supplierNotificationsScreen(onNotificationRead: (){});
//     } else {
//       adebug('supplier', tag: '_handleNotification($message)');
//       AjugnuNavigations.supplierNotificationsScreen(onNotificationRead: () {});
//     }
//   } else {
//     adebug('else(${role})', tag: '_handleNotification($message)');
//     role = ['placed', 'on the way', 'delivered']
//             .any((keyword) => message.toLowerCase().contains(keyword))
//         ? 'user'
//         : 'supplier';
//     _handleNotification(message, role);
//   }
// }
//
// int generateUniqueId(String inputString) {
//   const prime = 31;
//   int hash = 0;
//   for (int i = 0; i < inputString.length; i++) {
//     hash = (prime * hash + inputString.codeUnitAt(i)) % 2147483647;
//   }
//   return hash;
// }
//
// Future<void> initializeFirebase() async {
//   try {
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   } catch (error) {
//     adebug(error);
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:jkautomed/ajugnu_navigations.dart';
import 'package:jkautomed/firebase_options.dart';
import 'package:jkautomed/users/common/backend/ajugnu_auth.dart';
import 'package:jkautomed/users/common/backend/api_handler.dart'; // agar zarurat ho

// Global variables
String firebaseNotificationToken = '';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Flag jo batata hai ki yeh naya notification click se aaya hai
bool _shouldNavigateFromNotification = false;
String? _lastNotificationPayload;

// Background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String? title = message.data['title'];
  String? body = message.data['body'];
  String? imageUrl = message.data['imageUrl'];

  if (title != null && body != null) {
    await showNotification(
      generateUniqueId(message.messageId ?? DateTime.now().toString()),
      title,
      body,
      imageUrl,
    );
  }
}

// Background response handler
@pragma('vm:entry-point')
Future<void> _handleBackgroundNotificationResponse(
    NotificationResponse notificationResponse) async {
  final payload = notificationResponse.payload;
  if (payload != null && payload.isNotEmpty) {
    _shouldNavigateFromNotification = true;
    _lastNotificationPayload = payload;
    _navigateBasedOnNotification(payload);
  }
}

Future<void> showNotification(
    int id,
    String title,
    String body,
    String? imageUrl,
    ) async {
  String? localImagePath;
  BigPictureStyleInformation? bigPictureStyle;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/notif_img_$id.jpg');
        await file.writeAsBytes(response.bodyBytes);
        localImagePath = file.path;

        bigPictureStyle = BigPictureStyleInformation(
          FilePathAndroidBitmap(localImagePath),
          contentTitle: title,
          summaryText: body,
          htmlFormatContent: true,
          htmlFormatContentTitle: true,
        );
      }
    } catch (e) {
      debugPrint('Image download failed: $e');
    }
  }

  final androidDetails = AndroidNotificationDetails(
    'ajugnu_push_notifications',
    'Ajugnu Notifications',
    channelDescription: 'Important notifications from Ajugnu',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: bigPictureStyle,
    largeIcon: localImagePath != null ? FilePathAndroidBitmap(localImagePath) : null,
    fullScreenIntent: true,
  );

  final platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformDetails,
    payload: jsonEncode({'title': title, 'body': body, 'timestamp': DateTime.now().toIso8601String()}),
  );
}

Future<String> initializeFirebaseNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // Permissions
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Local notifications init
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        _shouldNavigateFromNotification = true;
        _lastNotificationPayload = payload;
        _navigateBasedOnNotification(payload);
      }
    },
    onDidReceiveBackgroundNotificationResponse: _handleBackgroundNotificationResponse,
  );

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final data = message.data;
    final title = data['title']?.toString();
    final body = data['body']?.toString();
    final imageUrl = data['imageUrl']?.toString();

    if (title != null && body != null) {
      showNotification(
        generateUniqueId(message.messageId ?? DateTime.now().toString()),
        title,
        body,
        imageUrl,
      );
    }
  });

  // When app is in background and notification clicked
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final payload = jsonEncode(message.data);
    _shouldNavigateFromNotification = true;
    _navigateBasedOnNotification(payload);
  });

  // App killed state → notification click se khula
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    final payload = jsonEncode(initialMessage.data);
    _shouldNavigateFromNotification = true;
    _navigateBasedOnNotification(payload);
  }

  // Local notification se app launch check
  final launchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp == true &&
      launchDetails?.notificationResponse?.payload != null) {
    final payload = launchDetails!.notificationResponse!.payload!;
    _shouldNavigateFromNotification = true;
    _lastNotificationPayload = payload;
    _navigateBasedOnNotification(payload);
  }

  // Token
  firebaseNotificationToken = (await messaging.getToken()) ?? 'no-token-found';
  debugPrint('FCM Token: $firebaseNotificationToken');

  return firebaseNotificationToken;
}

// Navigation logic
void _navigateBasedOnNotification(String payload) {
  try {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final title = data['title']?.toString()?.toLowerCase() ?? '';

    final user = AjugnuAuth().getUser();
    final role = user?.role ?? 'user';

    if (role == 'user') {
      AjugnuNavigations.customerNotificationsScreen(onNotificationRead: () {});
    } else if (role == 'supplier') {
      if (title.contains('product sold') || title.contains('order')) {
        AjugnuNavigations.supplierNotificationsScreen(onNotificationRead: () {});
      } else {
        AjugnuNavigations.supplierNotificationsScreen(onNotificationRead: () {});
      }
    }

    // Reset flags
    _shouldNavigateFromNotification = false;
    _lastNotificationPayload = null;
  } catch (e) {
    debugPrint('Notification navigation error: $e');
  }
}

// Unique ID generator
int generateUniqueId(String input) {
  const prime = 31;
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    hash = (prime * hash + input.codeUnitAt(i)) % 2147483647;
  }
  return hash;
}

// Firebase init
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
}