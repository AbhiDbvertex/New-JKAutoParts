// import 'package:jkautomed/ajugnu_constants.dart';
// import 'package:jkautomed/ajugnu_navigations.dart';
// import 'package:jkautomed/models/ajugnu_users.dart';
// import 'package:jkautomed/users/common/backend/ajugnu_auth.dart';
// import 'package:jkautomed/users/common/backend/firebase_notification_impl.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _SplashState();
//   }
// }
//
// class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late AnimationController _vectorController;
//   late AnimationController _exitController;
//
//   late Animation<double> _fadeTransition;
//   late Animation<double> _scaleTransition;
//
//   late Animation<Offset> _vector1SlideTransition;
//   late Animation<Offset> _vector2SlideTransition;
//   late Animation<Offset> _vector3SlideTransition;
//   late Animation<Offset> _vector4SlideTransition;
//   late Animation<Offset> _vector5SlideTransition;
//
//   late Animation<double> _exitTransition;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     _vectorController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 3));
//     _exitController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 750));
//
//     _fadeTransition = Tween<double>(begin: 0, end: 1).animate(_controller);
//     _scaleTransition = Tween<double>(begin: 0.9, end: 1).animate(_controller);
//
//     _vector1SlideTransition = Tween<Offset>(
//             begin: const Offset(1.2, 2.2), end: const Offset(0.43, 1.15))
//         .animate(CurvedAnimation(
//             parent: _vectorController, curve: Curves.elasticInOut));
//     _vector2SlideTransition = Tween<Offset>(
//             begin: const Offset(-1.2, 2.2), end: const Offset(-0.5, 0.9))
//         .animate(CurvedAnimation(
//             parent: _vectorController, curve: Curves.elasticInOut));
//     _vector3SlideTransition = Tween<Offset>(
//             begin: const Offset(-1.2, 2.2), end: const Offset(-0.31, 0.35))
//         .animate(CurvedAnimation(
//             parent: _vectorController, curve: Curves.elasticInOut));
//     _vector4SlideTransition = Tween<Offset>(
//             begin: const Offset(0.3, -1), end: const Offset(0.26, -0.28))
//         .animate(CurvedAnimation(
//             parent: _vectorController, curve: Curves.elasticInOut));
//     _vector5SlideTransition = Tween<Offset>(
//             begin: const Offset(1.6, 0.9), end: const Offset(1.1, 0.8))
//         .animate(CurvedAnimation(
//             parent: _vectorController, curve: Curves.elasticInOut));
//
//     _exitTransition = Tween<double>(begin: 1, end: 0).animate(_exitController);
//
//     _vectorController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _vectorController.reverse();
//         fetchInitialData().then((v) {
//           _exitController.forward();
//         });
//       }
//     });
//
//     _exitController.addStatusListener((status) async {
//       if (status == AnimationStatus.completed) {
//         AjugnuUser? user = AjugnuAuth().getUser();
//         if (user != null) {
//           if (user.role == 'supplier') {
//             AjugnuNavigations.supplierHomeScreen();
//           } else {
//             AjugnuNavigations.customerHomeScreen();
//           }
//         } else {
//           AjugnuNavigations.signInScreen();
//         }
//       }
//     });
//
//     _vectorController.forward();
//     _controller.forward();
//   }
//
//   Future<void> fetchInitialData() async {
//     await AjugnuAuth().initialise();
//     if (AjugnuAuth().getUser() != null) {
//       await initializeFirebaseNotifications();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//
//     double logoSize = width * 0.65;
//
//     double vectorOneSize = width * 1.1;
//     double vectorTwoSize = width * 1.25;
//     double vectorThreeSize = width * 0.73;
//     double vectorFourSize = width * 0.9;
//     double vectorFiveSize = width * 0.6;
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//           systemNavigationBarColor: Colors.black,
//           systemNavigationBarIconBrightness: Brightness.light),
//       child: Scaffold(
//           // primary: false,
//           // extendBodyBehindAppBar: true
//           // extendBody: true,
//           backgroundColor: AjugnuTheme.appColor,
//           body: Stack(
//             children: <Widget>[
//               Container(
//                 decoration: const BoxDecoration(
//                     image: DecorationImage(
//                         image:
//                             AssetImage('assets/images/gradient_background.png'),
//                         fit: BoxFit.cover)),
//                 child: Center(
//                   child: FadeTransition(
//                     opacity: _exitTransition,
//                     child: ScaleTransition(
//                       scale: _scaleTransition,
//                       child: FadeTransition(
//                         opacity: _fadeTransition,
//                         child: Image.asset(
//                           'assets/images/splacelogo.png',
//                           width: logoSize,
//                           height: logoSize,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               FadeTransition(
//                 opacity: _exitTransition,
//                 child: SlideTransition(
//                   position: _vector1SlideTransition,
//                   child: Image.asset(
//                     'assets/images/plant_vector_1.png',
//                     width: vectorOneSize,
//                     height: vectorOneSize,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               FadeTransition(
//                 opacity: _exitTransition,
//                 child: SlideTransition(
//                   position: _vector2SlideTransition,
//                   child: Image.asset(
//                     'assets/images/plant_vector_2.png',
//                     width: vectorTwoSize,
//                     height: vectorTwoSize,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               FadeTransition(
//                 opacity: _exitTransition,
//                 child: SlideTransition(
//                   position: _vector3SlideTransition,
//                   child: Image.asset(
//                     'assets/images/plant_vector_3.png',
//                     width: vectorThreeSize,
//                     height: vectorThreeSize,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               FadeTransition(
//                 opacity: _exitTransition,
//                 child: SlideTransition(
//                   position: _vector4SlideTransition,
//                   child: Image.asset(
//                     'assets/images/plant_vector_4.png',
//                     width: vectorFourSize,
//                     height: vectorFourSize,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               FadeTransition(
//                 opacity: _exitTransition,
//                 child: SlideTransition(
//                   position: _vector5SlideTransition,
//                   child: Image.asset(
//                     'assets/images/plant_vector_5.png',
//                     width: vectorFiveSize,
//                     height: vectorFiveSize,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ],
//           )),
//     );
//   }
//
//   @override
//   void dispose() {
//     _exitController.dispose();
//     _vectorController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_users.dart';
import 'backend/ajugnu_auth.dart';
import 'backend/firebase_notification_impl.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashState();
  }
}

class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeTransition;
  late Animation<double> _scaleTransition;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _fadeTransition = Tween<double>(begin: 0, end: 1).animate(_controller);
    _scaleTransition = Tween<double>(begin: 0.9, end: 1).animate(_controller);

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        AjugnuUser? user = AjugnuAuth().getUser();
        if (user != null) {
          if (user.role == 'supplier') {
            AjugnuNavigations.supplierHomeScreen();
          } else {
            AjugnuNavigations.customerHomeScreen();
          }
        } else {
          AjugnuNavigations.signInScreen();
        }
      }
    });

    fetchInitialData().then((_) {
      _controller.forward();
    });
  }

  Future<void> fetchInitialData() async {
    await AjugnuAuth().initialise();
    if (AjugnuAuth().getUser() != null) {
      await initializeFirebaseNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double logoSize = width * 0.65;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light),
      child: Scaffold(
        // backgroundColor: AjugnuTheme.appColor,
        body: Stack(
          children:[
            Image.asset("assets/images/splaceBackground.png"),
            Center(
            child: ScaleTransition(
                scale: _scaleTransition,
              child: FadeTransition(
                opacity: _fadeTransition,
                child: Image.asset(
                  'assets/images/splacelogo.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ]
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
