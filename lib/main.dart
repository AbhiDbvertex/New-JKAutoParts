// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:jkautomed/websiteDoc.dart';
// import 'package:jkautomed/users/common/backend/firebase_notification_impl.dart';
// import 'package:jkautomed/users/common/splash_screen.dart';
// import 'package:new_version_plus/new_version_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'JKAutoMed/Services/Notification_services.dart';
// import 'ajugnu_constants.dart';
//
// GlobalKey<NavigatorState> ajugnuGlobalContext = GlobalKey<NavigatorState>();
//
// final newVersionPlus = NewVersionPlus();
//
//
// bool isAjugnuGlobalContextMounted() {
//   return ajugnuGlobalContext.currentContext != null && ajugnuGlobalContext.currentContext!.mounted;
// }
//
// BuildContext getAjungnuGlobalContext() {
//   return ajugnuGlobalContext.currentContext!;
// }
//
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await initializeFirebase();
// //   runApp( MyApp());
// // }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeFirebase();
//   // Notification service init
//   // await NotificationService().initialize();
//   runApp(
//     ProviderScope(
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   // final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
//   MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // navigatorObservers: [
//       //   FirebaseAnalyticsObserver(analytics: analytics),
//       // ],
//       navigatorKey: ajugnuGlobalContext,
//       title: ajugnuAppName,
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: AjugnuTheme.appColorScheme,
//         useMaterial3: true,
//           fontFamily: 'Aclonica'
//       ),
//
//       home: const SplashScreen(),
//       // home: FavoriteScreen(),
//     );
//   }
// }
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jkautomed/users/common/backend/firebase_notification_impl.dart';
import 'package:jkautomed/users/common/splash_screen.dart';
// import 'package:new_version_plus/new_version_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'JKAutoMed/Services/Notification_services.dart';
import 'ajugnu_constants.dart';

GlobalKey<NavigatorState> ajugnuGlobalContext = GlobalKey<NavigatorState>();

// final newVersionPlus = NewVersionPlus();


bool isAjugnuGlobalContextMounted() {
  return ajugnuGlobalContext.currentContext != null && ajugnuGlobalContext.currentContext!.mounted;
}

BuildContext getAjungnuGlobalContext() {
  return ajugnuGlobalContext.currentContext!;
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeFirebase();
//   runApp( MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  // Notification service init
  await NotificationService().initialize();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(analytics: analytics),
      // ],
      navigatorKey: ajugnuGlobalContext,
      title: ajugnuAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: AjugnuTheme.appColorScheme,
          useMaterial3: true,
          fontFamily: 'Aclonica',
      ),

      home: const SplashScreen(),
      // home: FavoriteScreen(),
    );
  }
}