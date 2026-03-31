// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../Modelss/notification_model.dart';
// import '../Services/Api_Service.dart';
// import 'order_history_screen.dart';
// // import '../services/api_service.dart';
// import 'package:shimmer/shimmer.dart';
//
//
// class NotificationScreen extends StatefulWidget {
//   // final String userId = "69439d65d7e7f996d33d1471"; // Tumhara user ID yahan daalo ya login se lo
//
//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen> {
//   // late Future<NotificationResponse> _notificationsFuture;
//   late Future<NotificationResponse?> _notificationsFuture;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _notificationsFuture = ApiService.getNotifications();
//   }
//
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
//
//     if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else {
//       return DateFormat('dd MMM').format(date);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notifications'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: FutureBuilder<NotificationResponse?>(
//         future: _notificationsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return notificationShimmer();
//           }
//
//           if (!snapshot.hasData || snapshot.data == null) {
//             return Center(child: Text("No notifications"));
//           }
//
//           return ListView.builder(
//             itemCount: snapshot.data!.notifications.length,//Delivered
//             itemBuilder: (context, index) {
//               // final noti = notifications[index];
//               final noti = snapshot.data!.notifications[index];
//
//               return Padding(
//                 padding: EdgeInsets.only(bottom: 12,left: 12,right: 5,top: 12),
//                 child: InkWell(
//                   onTap: (){
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=> OrderHistoryScreen()));
//                   },
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Coin Icon
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Color(0xFFFFD700), // Gold color
//                           shape: BoxShape.circle,
//                         ),
//                         child: Image.asset("assets/images/splacelogo.png",fit: BoxFit.cover,)
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               noti.title,
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             SizedBox(height: 4),
//                             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     noti.message,
//                                     style: TextStyle(color: Colors.grey[700]),
//                                     maxLines: 2,
//                                   ),
//                                 ), Text(
//                                   "View Detail",
//                                   style: TextStyle(color: Colors.purple),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               _formatDate(noti.createdAt),
//                               style: TextStyle(color: Colors.grey, fontSize: 12),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // View Details button (optional, screenshot mein nahi hai lekin add kar sakte ho)
//                       // TextButton(onPressed: () {}, child: Text('View Details', style: TextStyle(color: Colors.blue))),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//   Widget notificationShimmer() {
//     return ListView.builder(
//       itemCount: 6,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           child: Shimmer.fromColors(
//             baseColor: Colors.grey.shade300,
//             highlightColor: Colors.grey.shade100,
//             child: Row(
//               children: [
//                 Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(height: 14, width: double.infinity, color: Colors.white),
//                       SizedBox(height: 8),
//                       Container(height: 12, width: double.infinity, color: Colors.white),
//                       SizedBox(height: 6),
//                       Container(height: 12, width: 120, color: Colors.white),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../Modelss/notification_model.dart';
import '../Services/Api_Service.dart';
import 'order_history_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<NotificationResponse?> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getNotifications();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<NotificationResponse?>(
        future: _future,
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _shimmer();
          }

          // no data / error
          if (!snapshot.hasData || snapshot.data == null) {
            return _emptyUI("No notification found");
          }

          final list = snapshot.data!.notifications;

          // empty list
          if (list.isEmpty) {
            return _emptyUI("No notification found");
          }

          // list
          return ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final noti = list[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderHistoryScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFD700),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noti.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              noti.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _timeAgo(noti.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "View",
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyUI(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_off, size: 60, color: Colors.grey),
          SizedBox(height: 8),
          Text("No notification found"),
        ],
      ),
    );
  }

  Widget _shimmer() {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
