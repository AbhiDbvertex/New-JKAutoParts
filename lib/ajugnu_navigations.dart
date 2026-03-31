// import 'package:jkautomed/ajugnu_constants.dart';
// import 'package:jkautomed/models/ajugnu_product.dart';
// import 'package:jkautomed/users/common/AjugnuFlushbar.dart';
// import 'package:jkautomed/users/common/change_password_screen.dart';
// import 'package:jkautomed/users/common/forgot_password_screen.dart';
// import 'package:jkautomed/users/common/information_screen.dart';
// import 'package:jkautomed/users/common/location_selector_screen.dart';
// import 'package:jkautomed/users/common/sign_in_screen.dart';
// import 'package:jkautomed/users/common/sign_up_screen.dart';
// import 'package:jkautomed/users/common/splash_screen.dart';
// import 'package:jkautomed/users/common/verification_screen.dart';
// import 'package:jkautomed/users/customer/customer_category_product_screen.dart';
// import 'package:jkautomed/users/customer/customer_edit_profile_screen.dart';
// import 'package:jkautomed/users/customer/customer_favourite_screen.dart';
// import 'package:jkautomed/users/customer/customer_home_screen.dart';
// import 'package:jkautomed/users/customer/customer_item_detail_screen.dart';
// import 'package:jkautomed/users/customer/customer_notifications_screen.dart';
// import 'package:jkautomed/users/customer/customer_order_page_screen.dart';
// import 'package:jkautomed/users/customer/customer_rating_screen.dart';
// import 'package:jkautomed/users/customer/customer_search_screen.dart';
// import 'package:jkautomed/users/customer/featured_products_screen.dart';
// import 'package:jkautomed/users/customer/order_placed_screen.dart';
// import 'package:jkautomed/users/supplier/add_bank_details_screen.dart';
// import 'package:jkautomed/users/supplier/qr_code_scan_screen.dart';
// import 'package:jkautomed/users/supplier/supplier_add_product_screen.dart';
// import 'package:jkautomed/users/supplier/supplier_edit_product_screen.dart';
// import 'package:jkautomed/users/supplier/supplier_edit_profile_screen.dart';
// import 'package:jkautomed/users/supplier/supplier_home_screen.dart';
// import 'package:jkautomed/users/supplier/supplier_item_detail_screen.dart';
// import 'package:jkautomed/users/supplier/supplier_notifications_screen.dart';
// import 'package:jkautomed/users/supplier/supplier_order_page_screen.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:new_version_plus/new_version_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'main.dart';
//
// class AjugnuNavigations {
//   static final NewVersionPlus newVersionPlus = NewVersionPlus(
//     // Optional: agar tumhe specific app ID dena hai to yahan daal sakte ho
//     // androidId: "com.jkautomed.yourapp",
//     // iOSId: "1234567890",
//   );
//   static const int typePush = 2801;
//   static const int typePopAndPush = 2802;
//   static const int typeRemoveAllAndPush = 2803;
//
//   static Future<VersionStatus?> getUpdateStatus() async {
//     final status = await newVersionPlus.getVersionStatus();
//
//     print("ishwarupdate: ${{
//       'canUpdate': status?.canUpdate,
//       'localVersion': status?.localVersion,
//       'storeVersion': status?.storeVersion,
//       'appStoreLink': status?.appStoreLink
//     }}");
//
//     return status;
//   }
//
//   static Future<void> perform(NavigatorState navigator, int type, Widget widget) {
//     MaterialPageRoute route = MaterialPageRoute(
//         builder: (context) => Stack(
//           fit: StackFit.expand,
//           children: [
//             widget,
//             // FutureBuilder(
//             //     future: getUpdateStatus(),
//             //     builder: (context, snapshot) {
//             //       return snapshot.data?.canUpdate == true
//             //           ? GestureDetector(
//             //         onTap: () {},
//             //         child: Container(
//             //             color: Colors.black12,
//             //             child: AlertDialog(
//             //               title: const Text("Update Available"),
//             //               content: Text(
//             //                   'You are using previous version of $ajugnuAppName v${snapshot.data?.localVersion}, you are required to update to latest version of $ajugnuAppName v${snapshot.data?.storeVersion}.${snapshot.data?.releaseNotes == null && (snapshot.data?.releaseNotes?.isNotEmpty ?? false) ? '' : "\n\nWhat's new:\n${snapshot.data?.releaseNotes?.split('- ').join('\n- ')}"}'),
//             //               actions: [
//             //                 TextButton(
//             //                     onPressed: () async {
//             //                       try {
//             //                         if (!await launchUrl(Uri.parse(
//             //                             snapshot.data?.appStoreLink ??
//             //                                 ''))) {
//             //                           AjugnuFlushbar.showError(
//             //                               getAjungnuGlobalContext(),
//             //                               "Something went wrong");
//             //                         }
//             //                       } catch (er) {
//             //                         AjugnuFlushbar.showError(
//             //                             getAjungnuGlobalContext(),
//             //                             "Something went wrong");
//             //
//             //                       }
//             //                     },
//             //                     child: const Text('Update'))
//             //               ],
//             //             )),
//             //       )
//             //           : const SizedBox.shrink();
//             //     })
//           ],
//         ));
//     if (type == typePush) {
//       return navigator.push(route);
//     } else if (type == typePopAndPush) {
//       return navigator.pushReplacement(route);
//     } else if (type == typeRemoveAllAndPush) {
//       return navigator.pushAndRemoveUntil(route, (route) => false);
//     }
//     return Future.error("No route found");
//   }
//
//   static void launcher({int type = typeRemoveAllAndPush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SplashScreen());
//     }
//   }
//
//   static void signInScreen({int type = typeRemoveAllAndPush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       if (kDebugMode)
//         print("ishwar:temp mounted");
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SignInScreen());
//     }
//   }
//
//   static void signUpScreen({int type = typeRemoveAllAndPush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SignUpScreen());
//     }
//   }
//
//   // static void verificationScreen({int type = typeRemoveAllAndPush, BuildContext? context, required String phoneNumber, required String email, bool otpSent = false}) {
//   //   if (context != null || isAjugnuGlobalContextMounted()) {
//   //     perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, VerificationScreen(phoneNumber: phoneNumber, email: email, otpSent: otpSent ,));
//   //   }
//   // }
//
//   static void verificationScreen({
//     int type = typeRemoveAllAndPush,
//     BuildContext? context,
//     required String phoneNumber,
//     required String email,
//     String? otp,       // <--- NEW
//     bool otpSent = false,
//   }) {
//     perform(
//       Navigator.of(context ?? getAjungnuGlobalContext()),
//       type,
//       VerificationScreen(
//         phoneNumber: phoneNumber,
//         email: email,
//         otpSent: otpSent,
//         otp: otp,               // <-- pass
//       ),
//     );
//   }
//
//
//   static void featuredProducts({int type = typeRemoveAllAndPush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const FeaturedProductsScreen());
//     }
//   }
//
//   static void forgotPasswordScreen({int type = typePush, BuildContext? context, required String phoneNumber}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, ForgotPasswordScreen(phoneNumber: phoneNumber));
//     }
//   }
//
//   static void supplierHomeScreen({int type = typeRemoveAllAndPush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type,  SupplierHomeScreen());
//     }
//   }
//
//   static void customerHomeScreen({int type = typeRemoveAllAndPush, BuildContext? context, int pageIndex = 1,bool? showRandoomProductPopup=false}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerHomeScreen(pageIndex: pageIndex,showRandomProducts: showRandoomProductPopup,));
//     }
//   }
//
//   static void supplierAddProductScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SupplierAddProductScreen());
//     }
//   }
//
//   static void supplierEditProfileScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SupplierEditProfileScreen());
//     }
//   }
//
//   static void customerEditProfileScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const CustomerEditProfileScreen());
//     }
//   }
//
//   static void changePasswordScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const ChangePasswordScreen());
//     }
//   }
//
//   static void informationScreen({int type = typePush, BuildContext? context, String title = ''}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, InformationScreen(title));
//     }
//   }
//
//   static void supplierItemDetailScreen({int type = typePush, BuildContext? context, required AjugnuProduct product}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierItemDetailScreen(product: product));
//     }
//   }
//
//   static void customerItemDetailScreen( {int type = typePush, BuildContext? context, required AjugnuProduct product, }) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerItemDetailScreen(product: product,));
//     }
//   }
//
//   static void supplierEditProductScreen({int type = typePush, BuildContext? context, required AjugnuProduct product}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierEditProductScreen(product: product));
//     }
//   }
//
//   static void supplierOrderPageScreen({String? orderId, int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierOrderPageScreen(orderId:orderId));
//     }
//   }
//
//   static void customerOrderPageScreen({String? orderId,int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type,  CustomerOrderPageScreen(orderId: orderId));
//     }
//   }
//
//   static void supplierAddBankDetailsScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const AddBankDetailsScreen());
//     }
//   }
//
//   // static void qrCodeScanScreen({int type = typePush, BuildContext? context}) {
//   //   if (context != null || isAjugnuGlobalContextMounted()) {
//   //     perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const QrCodeScanScreen());
//   //   }
//   // }
//
//   static void orderPlacedScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const OrderPlacedScreen());
//     }
//   }
//
//   static void customerSearchScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const CustomerSearchScreen());
//     }
//   }
//
//   static void customerFavouriteScreen({int type = typePush, BuildContext? context}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const CustomerFavouriteScreen());
//     }
//   }
//
//   static void customerNotificationsScreen({int type = typePush, BuildContext? context, required Function() onNotificationRead}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerNotificationsScreen(onNotificationRead: onNotificationRead));
//     }
//   }
//
//   static void supplierNotificationsScreen({int type = typePush, BuildContext? context, required Function() onNotificationRead}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierNotificationsScreen(onNotificationRead: onNotificationRead));
//     }
//   }
//
//   static Future<void> locationSelectorScreen({int type = typePush, BuildContext? context, Function()? onLocationChanged, bool forceToSelect = false}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       return perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, LocationSelectorScreen(onLocationChanged: onLocationChanged, forceToSelect: forceToSelect,));
//     }
//     return Future.error("Invalid context");
//   }
//
//   static void customerCategoryProductScreen({int type = typePush, BuildContext? context, required String categoryName, required String categoryID}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerCategoryProductScreen(categoryName: categoryName, categoryID: categoryID));
//     }
//   }
//
//   static void customerRatingScreen({int type = typePush, BuildContext? context, required String productId}) {
//     if (context != null || isAjugnuGlobalContextMounted()) {
//       perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerRatingScreen(productId: productId));
//     }
//   }
// }

import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/models/ajugnu_product.dart';
import 'package:jkautomed/users/common/AjugnuFlushbar.dart';
import 'package:jkautomed/users/common/change_password_screen.dart';
import 'package:jkautomed/users/common/forgot_password_screen.dart';
import 'package:jkautomed/users/common/information_screen.dart';
import 'package:jkautomed/users/common/location_selector_screen.dart';
import 'package:jkautomed/users/common/sign_in_screen.dart';
import 'package:jkautomed/users/common/sign_up_screen.dart';
import 'package:jkautomed/users/common/splash_screen.dart';
import 'package:jkautomed/users/common/verification_screen.dart';
import 'package:jkautomed/users/customer/customer_category_product_screen.dart';
import 'package:jkautomed/users/customer/customer_edit_profile_screen.dart';
import 'package:jkautomed/users/customer/customer_favourite_screen.dart';
import 'package:jkautomed/users/customer/customer_home_screen.dart';
import 'package:jkautomed/users/customer/customer_item_detail_screen.dart';
import 'package:jkautomed/users/customer/customer_notifications_screen.dart';
import 'package:jkautomed/users/customer/customer_order_page_screen.dart';
import 'package:jkautomed/users/customer/customer_rating_screen.dart';
import 'package:jkautomed/users/customer/customer_search_screen.dart';
import 'package:jkautomed/users/customer/featured_products_screen.dart';
import 'package:jkautomed/users/customer/order_placed_screen.dart';
import 'package:jkautomed/users/supplier/add_bank_details_screen.dart';
import 'package:jkautomed/users/supplier/qr_code_scan_screen.dart';
import 'package:jkautomed/users/supplier/supplier_add_product_screen.dart';
import 'package:jkautomed/users/supplier/supplier_edit_product_screen.dart';
import 'package:jkautomed/users/supplier/supplier_edit_profile_screen.dart';
import 'package:jkautomed/users/supplier/supplier_home_screen.dart';
import 'package:jkautomed/users/supplier/supplier_item_detail_screen.dart';
import 'package:jkautomed/users/supplier/supplier_notifications_screen.dart';
import 'package:jkautomed/users/supplier/supplier_order_page_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Ye important hai – main.dart se ajugnuGlobalContext access karne ke liye
import '../main.dart';
import 'JKAutoMed/screens/order_history_screen.dart';

class AjugnuNavigations {

  // YE DO FUNCTIONS ADD KIYE HAIN – ERROR KHATAM
  static bool isAjugnuGlobalContextMounted() {
    return ajugnuGlobalContext.currentContext != null &&
        ajugnuGlobalContext.currentContext!.mounted;
  }

  static BuildContext getAjungnuGlobalContext() {
    return ajugnuGlobalContext.currentContext!;
  }
  // ====================================================

  // static final NewVersionPlus newVersionPlus = NewVersionPlus(
  //   // Optional: agar specific app ID dena ho to yahan daal do
  //   // androidId: "com.jkautomed.yourapp",
  //   // iOSId: "1234567890",
  // );

  static const int typePush = 2801;
  static const int typePopAndPush = 2802;
  static const int typeRemoveAllAndPush = 2803;

  // static Future<VersionStatus?> getUpdateStatus() async {
  //   final status = await newVersionPlus.getVersionStatus();
  //
  //   print("ishwarupdate: ${{
  //     'canUpdate': status?.canUpdate,
  //     'localVersion': status?.localVersion,
  //     'storeVersion': status?.storeVersion,
  //     'appStoreLink': status?.appStoreLink
  //   }}");
  //
  //   return status;
  // }

  static Future<void> perform(NavigatorState navigator, int type, Widget widget) {
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            widget,
            // FutureBuilder(
            //     future: getUpdateStatus(),
            //     builder: (context, snapshot) {
            //       return snapshot.data?.canUpdate == true
            //           ? GestureDetector(
            //               onTap: () {},
            //               child: Container(
            //                   color: Colors.black12,
            //                   child: AlertDialog(
            //                     title: const Text("Update Available"),
            //                     content: Text(
            //                         'You are using previous version of $ajugnuAppName v${snapshot.data?.localVersion}, you are required to update to latest version of $ajugnuAppName v${snapshot.data?.storeVersion}.${snapshot.data?.releaseNotes == null && (snapshot.data?.releaseNotes?.isNotEmpty ?? false) ? '' : "\n\nWhat's new:\n${snapshot.data?.releaseNotes?.split('- ').join('\n- ')}"}'),
            //                     actions: [
            //                       TextButton(
            //                           onPressed: () async {
            //                             try {
            //                               if (!await launchUrl(Uri.parse(
            //                                   snapshot.data?.appStoreLink ??
            //                                       ''))) {
            //                                 AjugnuFlushbar.showError(
            //                                     getAjungnuGlobalContext(),
            //                                     "Something went wrong");
            //                               }
            //                             } catch (er) {
            //                               AjugnuFlushbar.showError(
            //                                   getAjungnuGlobalContext(),
            //                                   "Something went wrong");
            //                             }
            //                           },
            //                           child: const Text('Update'))
            //                     ],
            //                   )),
            //             )
            //           : const SizedBox.shrink();
            //     })
          ],
        ));
    if (type == typePush) {
      return navigator.push(route);
    } else if (type == typePopAndPush) {
      return navigator.pushReplacement(route);
    } else if (type == typeRemoveAllAndPush) {
      return navigator.pushAndRemoveUntil(route, (route) => false);
    }
    return Future.error("No route found");
  }
  //Dart is an object-oriented programming language developed by Google.
  // It is used to build applications and is the primary language for the Flutter framework.
  static void launcher({int type = typeRemoveAllAndPush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SplashScreen());
    }
  }

  static void signInScreen({int type = typeRemoveAllAndPush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      if (kDebugMode) print("ishwar:temp mounted");
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SignInScreen());
    }
  }

  static void signUpScreen({int type = typeRemoveAllAndPush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SignUpScreen());
    }
  }
  //StatelessWidget is immutable and does not change during runtime,
  // whereas StatefulWidget is mutable and can rebuild its UI when its state changes using setState().

  static void verificationScreen({
    int type = typeRemoveAllAndPush,
    BuildContext? context,
    required String phoneNumber,
    required String email,
    String? otp,
    bool otpSent = false,
  }) {
    perform(
      Navigator.of(context ?? getAjungnuGlobalContext()),
      type,
      VerificationScreen(
        phoneNumber: phoneNumber,
        email: email,
        otpSent: otpSent,
        otp: otp,
      ),
    );
  }

  static void featuredProducts({int type = typeRemoveAllAndPush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const FeaturedProductsScreen());
    }
  }

  static void forgotPasswordScreen({int type = typePush, BuildContext? context, required String phoneNumber}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, ForgotPasswordScreen(phoneNumber: phoneNumber));
    }
  }

  static void supplierHomeScreen({int type = typeRemoveAllAndPush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierHomeScreen());
    }
  }

  static void customerHomeScreen({int type = typeRemoveAllAndPush, BuildContext? context, int pageIndex = 1, bool? showRandoomProductPopup = false}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerHomeScreen(pageIndex: pageIndex, showRandomProducts: showRandoomProductPopup));
    }
  }

  static void supplierAddProductScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SupplierAddProductScreen());
    }
  }

  static void supplierEditProfileScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const SupplierEditProfileScreen());
    }
  }

  static void customerEditProfileScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const CustomerEditProfileScreen());
    }
  }
  //
  static void changePasswordScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const ChangePasswordScreen());
    }
  }

  static void informationScreen({int type = typePush, BuildContext? context, String title = ''}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, InformationScreen(title));
    }
  }

  static void supplierItemDetailScreen({int type = typePush, BuildContext? context, required AjugnuProduct product}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierItemDetailScreen(product: product));
    }
  }

  static void customerItemDetailScreen({int type = typePush, BuildContext? context, required AjugnuProduct product}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerItemDetailScreen(product: product));
    }
  }

  static void supplierEditProductScreen({int type = typePush, BuildContext? context, required AjugnuProduct product}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierEditProductScreen(product: product));
    }
  }

  static void supplierOrderPageScreen({String? orderId, int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierOrderPageScreen(orderId: orderId));
    }
  }

  static void customerOrderPageScreen({String? orderId, int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerOrderPageScreen(orderId: orderId));
    }
  }

  static void supplierAddBankDetailsScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const AddBankDetailsScreen());
    }
  }

  static void orderPlacedScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const OrderPlacedScreen());
    }
  }

  static void customerSearchScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const CustomerSearchScreen());
    }
  }

  static void customerFavouriteScreen({int type = typePush, BuildContext? context}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, const CustomerFavouriteScreen());
    }
  }

  static void customerNotificationsScreen({int type = typePush, BuildContext? context, required Function() onNotificationRead}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, OrderHistoryScreen()) /*CustomerNotificationsScreen(onNotificationRead: onNotificationRead))*/;
    }
  }

  static void supplierNotificationsScreen({int type = typePush, BuildContext? context, required Function() onNotificationRead}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, SupplierNotificationsScreen(onNotificationRead: onNotificationRead));
    }
  }

  static Future<void> locationSelectorScreen({int type = typePush, BuildContext? context, Function()? onLocationChanged, bool forceToSelect = false}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      return perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, LocationSelectorScreen(onLocationChanged: onLocationChanged, forceToSelect: forceToSelect));
    }
    return Future.error("Invalid context");
  }

  static void customerCategoryProductScreen({int type = typePush, BuildContext? context, required String categoryName, required String categoryID}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerCategoryProductScreen(categoryName: categoryName, categoryID: categoryID));
    }
  }

  static void customerRatingScreen({int type = typePush, BuildContext? context, required String productId}) {
    if (context != null || isAjugnuGlobalContextMounted()) {
      perform(Navigator.of(context ?? getAjungnuGlobalContext()), type, CustomerRatingScreen(productId: productId));
    }
  }
}