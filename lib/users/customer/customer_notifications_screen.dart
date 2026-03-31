// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';
// import '../../ajugnu_constants.dart';
// import '../../ajugnu_navigations.dart';
// import '../../main.dart';
// import '../../models/ajugnu_order_notification.dart';
// import '../common/common_widgets.dart';
// import 'backend/cart_repository.dart';
//
// class CustomerNotificationsScreen extends StatefulWidget {
//   final Function() onNotificationRead;
//
//   const CustomerNotificationsScreen({super.key, required this.onNotificationRead});
//
//   @override
//   State<StatefulWidget> createState() {
//     return CustomerNotificationsState();
//   }
// }
//
// class CustomerNotificationsState extends State<CustomerNotificationsScreen> {
//   List<AjugnuOrderNotification>? orderNotifications;
//
//   void fetchOrderNotifications() {
//     CartRepository().getOrderNotifications().then((results) {
//       widget.onNotificationRead();
//       if (results.isNotEmpty) {
//         setState(() {
//           orderNotifications = results.where((r) => !r.title.toLowerCase().contains('product sold') && !r.message.contains("new transaction")).toList();
//         });
//       } else {
//         setState(() {
//           orderNotifications = [];
//         });
//       }
//     }, onError: (error) {
//       setState(() {
//         orderNotifications = [];
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 10), () => fetchOrderNotifications());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
//         appBar: CommonWidgets.appbar('Notifications', systemUiOverlayStyle: SystemUiOverlayStyle(
//             systemNavigationBarIconBrightness: Brightness.dark,
//             systemNavigationBarColor: AjugnuTheme.appColorScheme.onPrimary
//         )),
//         // body: SingleChildScrollView(
//         //   child: orderNotifications != null && orderNotifications!.isNotEmpty ? ProductsGridList(products: [AjugnuProduct.dummy(), AjugnuProduct.dummy()]) : orderNotifications == null ? ProductsGridList(products: [AjugnuProduct.dummy()]) : CommonWidgets.text('empty')
//         // ),
//       body: orderNotifications == null ? ListView(
//         children: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map<Widget>((index) => Column(
//           children: [
//             Divider(height: 1, color: Colors.grey.shade200),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 children: [
//                   Shimmer.fromColors(
//                     baseColor: Colors.grey.withOpacity(0.3),
//                     highlightColor: Colors.white,
//                     child: Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           color: Colors.green.shade500
//                       ),
//                       height: 65,
//                       width: 60
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Shimmer.fromColors(
//                             baseColor: Colors.grey.withOpacity(0.3),
//                             highlightColor: Colors.white,
//                             child: Container(margin: const EdgeInsets.all(1.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)), child: CommonWidgets.text('Title', textColor: Colors.green, fontSize: 16, overflow: TextOverflow.ellipsis, maxLines: 1))
//                         ),
//                         Shimmer.fromColors(
//                             baseColor: Colors.grey.withOpacity(0.3),
//                             highlightColor: Colors.white,
//                             child: Container(margin: const EdgeInsets.all(1.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)), child: CommonWidgets.text('This is long message.', textColor: Colors.black, fontSize: 15, fontFamily: 'Poly', overflow: TextOverflow.ellipsis, maxLines: 3))
//                         ),
//                       ],
//                     ),
//                   ),
//                   Shimmer.fromColors(
//                     baseColor: Colors.grey.withOpacity(0.3),
//                     highlightColor: Colors.white,
//                     child: Card(
//                       color: Colors.black,
//                       elevation: 0,
//                       margin: EdgeInsets.zero,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           side: const BorderSide(color: Color.fromARGB(255, 121, 255, 217))
//                       ),
//                       clipBehavior: Clip.hardEdge,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 6),
//                         child: IconButton(
//                             style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
//                             onPressed: () {
//
//                             },
//                             icon: CommonWidgets.text('View', textColor: Colors.white)
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12)
//                 ],
//               ),
//             ),
//             Divider(height: 1, color: Colors.grey.shade200),
//           ],
//         )).toList()
//       ) : orderNotifications?.isEmpty == true ? Center(
//           child: Card(
//             elevation: 0,
//             color: AjugnuTheme.appColorScheme.surface,
//             margin: EdgeInsets.symmetric(horizontal: 18),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.width * 0.05),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset(
//                     'assets/icons/no_notification.png',
//                     height: MediaQuery.of(context).size.width * 0.3,
//                     width: MediaQuery.of(context).size.width * 0.3,
//                     color: Colors.grey,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: CommonWidgets.text('You do not have notifications currently.', alignment: TextAlign.center, textColor: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           )
//       ) : ListView.builder(
//         itemBuilder: (context, index) => Padding(
//           padding: const EdgeInsets.only(top: 10, left: 8),
//           child: Column(
//             children: [
//               Divider(height: 1, color: Colors.grey.shade200),
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         color: orderNotifications![index].title.toLowerCase().contains('order status')/*=="Your order has been cancelled."*/?Colors.red.shade200:Colors.green
//                       ),
//                       height: 65,
//                       width: 60,
//                       child: Icon(orderNotifications![index].title.toLowerCase().contains('order status')?Icons.error_outline:Icons.done_sharp, color: Colors.white, size: 30),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CommonWidgets.text(orderNotifications![index].title, textColor: Colors.green, fontSize: 16, overflow: TextOverflow.ellipsis, maxLines: 1),
//                           orderNotifications![index].orderId.isNotEmpty
//                               ? CommonWidgets.text("OrderID ${orderNotifications![index].orderId}" , fontFamily: 'Poly', fontSize: 15, textColor: Colors.black87)
//                               :SizedBox(),
//
//                           CommonWidgets.text(orderNotifications![index].message, textColor: Colors.black, fontSize: 15, fontFamily: 'Poly', overflow: TextOverflow.ellipsis, maxLines: 3),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         CommonWidgets.text(formatTimestamp(orderNotifications?[index].date ?? DateTime.now()), fontFamily: 'Poly', fontSize: 15, textColor: Colors.black87),
//
//                         if (orderNotifications?[index].orderId.isNotEmpty ?? false) Card(
//                             color: Colors.black,
//                             margin: EdgeInsets.only(top: 5),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 side: BorderSide(color: Color.fromARGB(255, 121, 255, 217))
//                             ),
//                             clipBehavior: Clip.hardEdge,
//                             child: InkWell(
//                               onTap: () => AjugnuNavigations.customerOrderPageScreen(orderId:orderNotifications![index].orderId),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
//                                 child: CommonWidgets.text('View', textColor: Colors.white),
//                               ),
//                             ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 2)
//                   ],
//                 ),
//               ),
//               Divider(height: 1, color: Colors.grey.shade200),
//             ],
//           ),
//         ),
//         itemCount: orderNotifications?.length ?? 0,
//       ),
//     );
//   }
//
//   String formatTimestamp(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
//
//     if (difference.inDays == 0) {
//       // Today
//       return DateFormat('h:mm a').format(dateTime); // e.g., "12:10 PM"
//     } else if (difference.inDays < 30) {
//       // Within the last month
//       return DateFormat('EEE, MMM d').format(dateTime); // e.g., "Monday, Aug 12"
//     } else if (now.year == dateTime.year) {
//       // Within the current year
//       return DateFormat('EEE, MMM d').format(dateTime); // e.g., "Monday, Aug 12"
//     } else {
//       // Older
//       return DateFormat('EEE, MMM d, y').format(dateTime); // e.g., "Monday, Aug 12, 2024"
//     }
//   }
// }