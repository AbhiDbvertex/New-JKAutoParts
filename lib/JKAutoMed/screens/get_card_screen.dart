// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jkautomed/JKAutoMed/Services/Api_Service.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../ajugnu_constants.dart';
// import '../../users/customer/customer_home_screen.dart';
// import '../Modelss/get_card_model.dart';
// import '../providers/get_card_provider.dart';
// import 'address_screen.dart';
//
// class MyCartScreens extends ConsumerStatefulWidget {
//   final hideButton;
//   const MyCartScreens( {super.key,this.hideButton,});
//   // in flutter main widget is build method build methoad render image, appbar, scafold and render degine .
//
//   @override
//   ConsumerState<MyCartScreens> createState() => _MyCartScreensState();
// }
//
// class _MyCartScreensState extends ConsumerState<MyCartScreens>
//     with WidgetsBindingObserver {
//   late Razorpay _razorpay;
//   CartResponse? _currentCartResponse;
//
//   // Naye variables payment tracking ke liye
//   String? _latestPaymentId;
//   String _latestPaymentStatus = "pending";
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//     WidgetsBinding.instance.addObserver(this);
//     Future.microtask(() => ref.read(cartProvider.notifier).fetchCart());
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // if (state == AppLifecycleState.resumed) {
//     //   ref.read(cartProvider.notifier).fetchCart();
//     // }
//     if (state == AppLifecycleState.resumed) {
//       ref.read(cartProvider.notifier).fetchCart();
//     }
//   }
//
//   Future<void> _onRefresh() async {
//     await ref.read(cartProvider.notifier).fetchCart();
//   }
//
//   // Razorpay Handlers
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     _latestPaymentId = response.paymentId;
//     _latestPaymentStatus = "success";
//
//     Fluttertoast.showToast(msg: "Payment Successful! ID: ${response.paymentId}");
//
//     // Success ke baad hi order process shuru karo
//     await _createOrderAfterPayment();
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) async {
//     _latestPaymentStatus = "failed";
//     _latestPaymentId = null;
//
//     Fluttertoast.showToast(
//         msg: "Payment Failed: ${response.message ?? 'Unknown error'}");
//     // Yahan failed transaction record nahi kar rahe kyunki order bana hi nahi
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
//   }
//
//   // Razorpay checkout open
//   // void _openCheckout(double amountInRupees) {
//   //   var options = {
//   //     // 'key': 'rzp_test_R7z5O0bqmRXuiH', // Real key daal dena production mein
//   //     // 'key': 'rzp_live_Ryzl8H7cRDsFxj', // Real client old live api key
//   //     'key': 'rzp_live_S9bpIgNW47Ut9N', // Real client live api key
//   //     // 'key': 'rzp_live_aASdWlCCSdULeU', // This is razerpay is smart vyapar live
//   //     'amount': (amountInRupees * 100).toInt(),
//   //     'name': 'JKAutomed Store',
//   //     'description': 'Order Payment',
//   //     'currency': 'INR',
//   //     'prefill': {
//   //       'contact': '9876543210',
//   //       'email': 'customer@example.com',
//   //
//   //     },
//   //     'theme': {
//   //       'color': '#007bff',
//   //     }
//   //   };
//   //   // 'color': '#FF6B00',
//   //   try {
//   //     _razorpay.open(options);
//   //   } catch (e) {
//   //     debugPrint('Razorpay Open Error: $e');
//   //     Fluttertoast.showToast(msg: "Payment gateway error");
//   //   }
//   // }
//
//   Future<void> _createOrderAfterPayment() async {
//     if (_currentCartResponse == null) {
//       Fluttertoast.showToast(msg: "Cart data not available");
//       return;
//     }
//
//     final cartResponse = _currentCartResponse!;
//     final userAddress = cartResponse.userfulladdress;
//
//     if (userAddress == null) {
//       Fluttertoast.showToast(msg: "Please add shipping address");
//       return;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final String? userId = prefs.getString('user_id');
//     if (userId == null) {
//       Fluttertoast.showToast(msg: "Login required");
//       return;
//     }
//
//     // Shiprocket items format
//     final List<Map<String, dynamic>> items = cartResponse.cartItems.map((item) {
//       return {
//         "name": item.product.name,
//         "selling_price": item.product.price.toInt(),
//         "units": item.quantity,
//       };
//     }).toList();
//
//     final Map<String, dynamic> billing = {
//       "name": "Customer Name",
//       "address": "${userAddress.buildingName ?? ''}, ${userAddress.addressLine ?? ''}",
//       "city": userAddress.city ?? "Indore",
//       "state": userAddress.state ?? "Madhya Pradesh",
//       "pincode": cartResponse.userPincode ?? "452001",
//       "email": "customer@example.com",
//       "phone": "9876543210",
//     };
//
//     final Map<String, dynamic> internalOrderData = {
//       "user_id": userId,
//       "items": cartResponse.cartItems.map((item) {
//         print("Product id: ${item.id}, name: ${item.product.name}");
//         return {
//           "product_id": item.product.id,
//           "product_name": item.product.name,
//           "selling_price": item.product.price.toInt(),
//           "units": item.quantity,
//         };
//       }).toList(),
//       "shipping_address": {
//         "name": "Customer Name",
//         "address": billing['address'],
//         "pincode": billing['pincode'],
//         "mobile_number": billing['phone'],
//       },
//       "payment_method": "online",
//       "total_amount": ref.read(cartProvider.notifier).total.toInt(),
//     };
//
//     try {
//       final apiService = ref.read(apiServiceProvider);
//
//       // 1. Internal Order Create
//       final internalResult = await apiService.createOrder(internalOrderData);
//       if (!(internalResult['status'] ?? false)) {
//         throw Exception(internalResult['message'] ?? "Order creation failed");
//       }
//
//       final String orderId = internalResult['data']['_id'];
//
//       // 2. Shiprocket Order Create
//       final Map<String, dynamic> shiprocketPayload = {
//         "order_id": orderId,
//         "billing": billing,
//         "items": items,
//         "courier": {
//           "courier_company_id": cartResponse.courierData?.courierCompanyId ?? 217,
//           "shipping_charge": cartResponse.courierData?.rate?.toDouble() ?? 0.0,
//         },
//         "dimensions": {
//           "weight": cartResponse.totalWeight
//         },
//         "payment_method": "Prepaid"
//       };
//
//       final shiprocketResult = await apiService.createBackendShiprocketOrder(shiprocketPayload);
//       final String shipmentId = shiprocketResult['shiprocket']['shipment_id'].toString();
//       final String courierId = (cartResponse.courierData?.courierCompanyId ?? 217).toString();
//
//       print("Shipment ID: $shipmentId | Courier ID: $courierId");
//
//       // 3. Transaction Record
//       if (_latestPaymentId == null) {
//         throw Exception("Payment ID missing!");
//       }
//
//       final String userName = "Pooja PD"; // ← baad mein dynamic kar dena
//
//       final Map<String, dynamic> transactionPayload = {
//         "user_id": userId,
//         "order_id": orderId,
//         "payment_id": _latestPaymentId,
//         "payment_status": "success",
//         "total_amount": ref.read(cartProvider.notifier).total.toInt(),
//         "payment_method": "online",
//         "user_name": userName,
//       };
//
//       final transactionResult = await apiService.addTransaction(transactionPayload);
//       if (!(transactionResult['status'] ?? false)) {
//         debugPrint("Transaction save failed: ${transactionResult['message']}");
//       }
//
//       // 4. Shipping Product Assign (AWB Assign) - Yeh sabse important
//       final Map<String, dynamic> shipingProductAssignPayload = {
//         "order_db_id": orderId,
//         "user_id": userId,
//         "shipment_id": int.tryParse(shipmentId) ?? shipmentId,
//         "courier_id": int.tryParse(courierId) ?? courierId,
//       };
//
//       final shipingProductAssignResult = await apiService.shipingProductAssign(shipingProductAssignPayload);
//
//       // ===== Final Snackbar - Sirf yahi dikhega =====
//       if (mounted) {
//         String message;
//         Color backgroundColor;
//
//         if (shipingProductAssignResult['success'] == true) {
//           message = shipingProductAssignResult['message'] ?? "AWB assigned & order updated successfully";
//           backgroundColor = Colors.green.shade700;
//         } else {
//           message = shipingProductAssignResult['message'] ?? "AWB assignment failed";
//           backgroundColor = Colors.orange.shade800;
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               message,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//             ),
//             backgroundColor: backgroundColor,
//             duration: const Duration(seconds: 5),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             action: SnackBarAction(
//               label: 'OK',
//               textColor: Colors.white,
//               onPressed: () {},
//             ),
//           ),
//         );
//       }
//
//       // Cart refresh aur Home navigation
//       ref.read(cartProvider.notifier).fetchCart();
//
//       if (mounted) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
//               (route) => false,
//         );
//       }
//
//     } catch (e) {
//       debugPrint("Order/Transaction Error: $e");
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Order process failed: $e"),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     }
//   }
//
//
//   void _openPhonePePayment(double amountInRupees) async {
//     // PhonePe deep link format
//     // pa: payee number / merchant id, pn: payee name, tr: transaction ref, tn: txn note
//     final String phonePeUrl =
//         "phonepe://pay?pa=XXXXXXXXXX&pn=JKAutomed&tr=TXN${DateTime.now()
//         .millisecondsSinceEpoch}&tn=Order+Payment&am=${amountInRupees.toStringAsFixed(2)}&cu=INR";
//
//     final Uri uri = Uri.parse(phonePeUrl);
//
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       Fluttertoast.showToast(msg: "PhonePe app is not installed on your device");
//     }
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen(cartProvider, (previous, next) {
//       // Optional: Agar server se naya data aaya to kuch karna ho (jaise toast)
//     });
//     final cartAsync = ref.watch(cartProvider);
//     final cartNotifier = ref.read(cartProvider.notifier);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: widget.hideButton == "hidebutton"
//             ? const SizedBox()
//             : IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text("My Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         color: AjugnuTheme.appColor,
//         child: cartAsync.when(
//           loading: () => _buildShimmerList(),
//           error: (_, __) => _buildEmptyView("Something went wrong"),
//           data: (cartResponse) {
//             _currentCartResponse = cartResponse;
//
//             final cartItems = cartResponse.cartItems;
//             if (cartItems.isEmpty) {
//               return _buildEmptyView("Your cart is empty");
//             }
//
//             final userAddress = cartResponse.userfulladdress;
//             final shippingCharge = cartResponse.courierData?.rate?.toDouble() ?? 0.0;
//
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     padding: const EdgeInsets.all(16),
//                     itemCount: cartItems.length,
//                     itemBuilder: (context, index) {
//                       final item = cartItems[index];
//                       final bool loading = cartNotifier.isLoading(item.product.id);
//
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 16),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                                 color: Colors.grey.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 5),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: CachedNetworkImage(
//                                 imageUrl: "${item.product.firstImage}",
//                                 width: 80,
//                                 height: 80,
//                                 fit: BoxFit.cover,
//                                 placeholder: (_, __) => Container(color: Colors.grey[200]),
//                                 errorWidget: (_, __, ___) => Container(
//                                   color: Colors.grey[200],
//                                   child: const Icon(Icons.broken_image, color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(item.product.name,
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold, fontSize: 16)),
//                                   const SizedBox(height: 4),
//                                   Text("Price: ₹${item.product.price.toStringAsFixed(2)}",
//                                       style: const TextStyle(color: Colors.black54)),
//                                   const SizedBox(height: 8),
//                                   Row(
//                                     children: [
//                                       _quantityButton(
//                                         icon: Icons.remove,
//                                         onTap: loading ? null : () => cartNotifier.decreaseQuantity(item.product.id),
//                                         isLoading: loading,
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                                         child: Text("${item.quantity}",
//                                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                                       ),
//                                       _quantityButton(
//                                         icon: Icons.add,
//                                         onTap: loading ? null : () => cartNotifier.increaseQuantity(item.product.id),
//                                         isLoading: loading,
//                                       ),
//                                       const Spacer(),
//                                       // TextButton(
//                                       //   onPressed: loading ? null : () {
//                                       //    ApiService.deleteCartitem(item.product.id);
//                                       //   }, /*=> cartNotifier.removeItem(item.product.id),*/
//                                       //   child: Text("Delete",
//                                       //       style: TextStyle(color: loading ? Colors.grey : Colors.red)),
//                                       // ),
//                                       TextButton(
//                                         onPressed: loading ? null : () => cartNotifier.removeItem(item.product.id),
//                                         child: Text("Delete",
//                                             style: TextStyle(color: loading ? Colors.grey : Colors.red)),
//                                       ),
//                                     ],
//                                   ),
//                                   TextButton(onPressed: (){print("Abhi:- print image url --> ${item.product.firstImage}");}, child: Text("product image")),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 // Bottom Section
//                 Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey, blurRadius: 10, offset: Offset(0, -5))
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       userAddress == null || userAddress.state == null
//                           ? Center(
//                         child: Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: AjugnuTheme.appColor,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const AddNewAddressScreen()),
//                               );
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset("assets/icons/locationIcon.png", width: 20, height: 20),
//                                 const SizedBox(width: 8),
//                                 const Text("Add Shipping Address",
//                                     style: TextStyle(color: Colors.white, fontSize: 16)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                           : Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Shipping Address:", style: TextStyle(fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 6),
//                           Text(
//                             // "${userAddress.buildingName ?? ''}\n${userAddress.addressLine ?? ''}\n${userAddress.city ?? ''}, ${userAddress.state ?? ''}",
//                             "${userAddress.buildingName ?? ''}\n${userAddress.city ?? ''}, ${userAddress.state ?? ''}",
//                             style: const TextStyle(color: Colors.black87),
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//                       ),
//
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text("Shipping Charges:", style: TextStyle(fontSize: 16)),
//                           Text("₹${shippingCharge.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                           Text("₹${cartNotifier.total.toStringAsFixed(2)}",
//                               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//
//
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: (userAddress == null || cartItems.isEmpty) || (userAddress.state == null)
//                               ? null
//                               : ()  async {
//                             double totalAmount = cartNotifier.total;
//                             if (totalAmount <= 0) {
//                               Fluttertoast.showToast(msg: "Cart is empty!");
//                               return;
//                             }
//                            final res  = await  ref.read(apiServiceProvider).createPhonePeOrder(totalAmount);
//                             if(res["success"] == true) {
//                               print("order success is true");
//                               String order_Id = res["orderId"];
//                               String deepLink = res["redirectUrl"];
//                               final Uri uri = Uri.parse(deepLink);
//
//                               if (await canLaunchUrl(uri)) {
//                                 final res = await launchUrl(uri).then((value) =>
//                                     ref
//                                         .read(apiServiceProvider)
//                                         .verifyPhonePeOrder(order_Id));
//                                 if (res["success"] == true) {
//                                   print("Payment verification success");
//                                  _createOrderAfterPayment();
//                                 } else {
//                                   Fluttertoast.showToast(
//                                       msg: "PhonePe app is not installed on your device");
//                                 }
//                               }
//                             }
//
//                             // **Open PhonePe Payment**
//                            // _openPhonePePayment(totalAmount);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AjugnuTheme.appColor,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                           ),
//                           child: Text(
//                               "Checkout",
//                               style: TextStyle(
//                                   fontSize: 18,
//                                   color: userAddress?.state == null ? Colors.grey : Colors.white,
//                                   fontWeight: FontWeight.bold
//                               )
//                           ),
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// //
// //   // Baaki helper widgets (unchanged)
//   Widget _buildEmptyView(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey)),
//         ],
//       ),
//     );
//   }
//
//   Widget _quantityButton({required IconData icon, required VoidCallback? onTap, required bool isLoading}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: onTap == null ? Colors.grey : Colors.black,
//         ),
//         child: isLoading
//             ? const SizedBox(
//             width: 16,
//             height: 16,
//             child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//             : Icon(icon, color: Colors.white, size: 16),
//       ),
//     );
//   }
//
//   Widget _buildShimmerList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)
//             ],
//           ),
//           child: Row(
//             children: [
//               Shimmer.fromColors(
//                 baseColor: Colors.grey[300]!,
//                 highlightColor: Colors.grey[100]!,
//                 child: Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Shimmer.fromColors(
//                         baseColor: Colors.grey[300]!,
//                         highlightColor: Colors.grey[100]!,
//                         child: Container(height: 16, width: 150, color: Colors.white)),
//                     const SizedBox(height: 8),
//                     Shimmer.fromColors(
//                         baseColor: Colors.grey[300]!,
//                         highlightColor: Colors.grey[100]!,
//                         child: Container(height: 14, width: 100, color: Colors.white)),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: Container(width: 30, height: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
//                         const SizedBox(width: 32),
//                         Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: Container(width: 40, height: 20, color: Colors.white)),
//                         const SizedBox(width: 32),
//                         Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: Container(width: 30, height: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
//
//
//
// // import 'dart:convert';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // import 'package:shimmer/shimmer.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:url_launcher/url_launcher.dart';
// //
// // import '../../ajugnu_constants.dart';
// // import '../../users/customer/customer_home_screen.dart';
// // import '../Modelss/get_card_model.dart';
// // import '../providers/get_card_provider.dart';
// // import 'address_screen.dart';
// //
// // class MyCartScreens extends ConsumerStatefulWidget {
// //   final hideButton;
// //   const MyCartScreens({super.key, this.hideButton});
// //
// //   @override
// //   ConsumerState<MyCartScreens> createState() => _MyCartScreensState();
// // }
// //
// // class _MyCartScreensState extends ConsumerState<MyCartScreens>
// //     with WidgetsBindingObserver {
// //   late Razorpay _razorpay;
// //   CartResponse? _currentCartResponse;
// //
// //   // Payment tracking
// //   String? _latestPaymentId;
// //   String _latestPaymentStatus = "pending";
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //
// //     WidgetsBinding.instance.addObserver(this);
// //     Future.microtask(() => ref.read(cartProvider.notifier).fetchCart());
// //   }
// //
// //   @override
// //   void dispose() {
// //     _razorpay.clear();
// //     WidgetsBinding.instance.removeObserver(this);
// //     super.dispose();
// //   }
// //
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.resumed) {
// //       ref.read(cartProvider.notifier).fetchCart();
// //     }
// //   }
// //
// //   Future<void> _onRefresh() async {
// //     await ref.read(cartProvider.notifier).fetchCart();
// //   }
// //
// //   // Razorpay Handlers
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
// //     _latestPaymentId = response.paymentId;
// //     _latestPaymentStatus = "success";
// //
// //     Fluttertoast.showToast(
// //         msg: "Payment Successful! ID: ${response.paymentId}");
// //
// //     await _createOrderAfterPayment();
// //   }
// //
// //   void _handlePaymentError(PaymentFailureResponse response) async {
// //     _latestPaymentStatus = "failed";
// //     _latestPaymentId = null;
// //
// //     Fluttertoast.showToast(
// //         msg: "Payment Failed: ${response.message ?? 'Unknown error'}");
// //   }
// //
// //   void _handleExternalWallet(ExternalWalletResponse response) {
// //     Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
// //   }
// //
// //   // PhonePe Payment
// //   void _startPhonePePayment(double amountInRupees) async {
// //     // Initialize SDK
// //     try {
// //       await PhonePePaymentSdk.init(
// //         "SANDBOX", // "PROD" for real payment
// //         "merchant@phonepe", // test merchant (replace in PROD)
// //         "FLOW123",
// //         true,
// //       );
// //       print("PhonePe SDK Initialized");
// //     } catch (e) {
// //       Fluttertoast.showToast(msg: "PhonePe SDK init failed: $e");
// //       return;
// //     }
// //
// //     int amountInPaise = (amountInRupees * 100).toInt();
// //
// //     var requestMap = {
// //       "merchantId": "merchant@phonepe", // replace in PROD
// //       "transactionId": "TXN${DateTime.now().millisecondsSinceEpoch}",
// //       "amount": amountInPaise,
// //       "merchantName": "JKAutomed",
// //       "merchantMobile": "9999999999",
// //       "transactionNote": "Order Payment",
// //       "callbackUrl": "https://yourserver.com/callback"
// //     };
// //
// //     String requestJson = jsonEncode(requestMap);
// //
// //     try {
// //       var response = PhonePePaymentSdk.startTransaction(
// //         requestJson,
// //         "phonepe",
// //         "merchant@phonepe",
// //         "FLOW123",
// //       );
// //
// //       response.then((val) {
// //         Fluttertoast.showToast(msg: "Payment Successful");
// //         print("PhonePe Transaction Success: $val");
// //
// //         _latestPaymentId = val?['transactionId'] ?? "";
// //         _latestPaymentStatus = "success";
// //
// //         _createOrderAfterPayment();
// //       }).catchError((error) {
// //         Fluttertoast.showToast(msg: "Payment Failed");
// //         print("PhonePe Transaction Failed: $error");
// //         _latestPaymentStatus = "failed";
// //       });
// //     } catch (error) {
// //       Fluttertoast.showToast(msg: "Payment Exception: $error");
// //       print("PhonePe Transaction Exception: $error");
// //       _latestPaymentStatus = "failed";
// //     }
// //   }
// //
// //   // Create Order after Payment
// //   Future<void> _createOrderAfterPayment() async {
// //     if (_currentCartResponse == null) {
// //       Fluttertoast.showToast(msg: "Cart data not available");
// //       return;
// //     }
// //
// //     final cartResponse = _currentCartResponse!;
// //     final userAddress = cartResponse.userfulladdress;
// //
// //     if (userAddress == null) {
// //       Fluttertoast.showToast(msg: "Please add shipping address");
// //       return;
// //     }
// //
// //     final prefs = await SharedPreferences.getInstance();
// //     final String? userId = prefs.getString('user_id');
// //     if (userId == null) {
// //       Fluttertoast.showToast(msg: "Login required");
// //       return;
// //     }
// //
// //     try {
// //       // Internal order + Shiprocket + Transaction recording logic
// //       // <-- Same as your existing _createOrderAfterPayment code -->
// //
// //       Fluttertoast.showToast(msg: "Order created successfully!");
// //     } catch (e) {
// //       debugPrint("Order/Transaction Error: $e");
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text("Order process failed: $e"),
// //             backgroundColor: Colors.red,
// //             duration: const Duration(seconds: 5),
// //           ),
// //         );
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     ref.listen(cartProvider, (previous, next) {});
// //
// //     final cartAsync = ref.watch(cartProvider);
// //     final cartNotifier = ref.read(cartProvider.notifier);
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: widget.hideButton == "hidebutton"
// //             ? const SizedBox()
// //             : IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text("My Cart",
// //             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
// //         centerTitle: true,
// //       ),
// //       body: RefreshIndicator(
// //         onRefresh: _onRefresh,
// //         color: AjugnuTheme.appColor,
// //         child: cartAsync.when(
// //           loading: () => _buildShimmerList(),
// //           error: (_, __) => _buildEmptyView("Something went wrong"),
// //           data: (cartResponse) {
// //             _currentCartResponse = cartResponse;
// //
// //             final cartItems = cartResponse.cartItems;
// //             if (cartItems.isEmpty) {
// //               return _buildEmptyView("Your cart is empty");
// //             }
// //
// //             final userAddress = cartResponse.userfulladdress;
// //             final shippingCharge =
// //                 cartResponse.courierData?.rate?.toDouble() ?? 0.0;
// //
// //             return Column(
// //               children: [
// //                 Expanded(
// //                   child: ListView.builder(
// //                     physics: const AlwaysScrollableScrollPhysics(),
// //                     padding: const EdgeInsets.all(16),
// //                     itemCount: cartItems.length,
// //                     itemBuilder: (context, index) {
// //                       final item = cartItems[index];
// //                       final bool loading =
// //                       cartNotifier.isLoading(item.product.id);
// //
// //                       return Container(
// //                         margin: const EdgeInsets.only(bottom: 16),
// //                         padding: const EdgeInsets.all(12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                                 color: Colors.grey.withOpacity(0.1),
// //                                 spreadRadius: 1,
// //                                 blurRadius: 5),
// //                           ],
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             ClipRRect(
// //                               borderRadius: BorderRadius.circular(8),
// //                               child: CachedNetworkImage(
// //                                 imageUrl: "${item.product.firstImage}",
// //                                 width: 80,
// //                                 height: 80,
// //                                 fit: BoxFit.cover,
// //                                 placeholder: (_, __) =>
// //                                     Container(color: Colors.grey[200]),
// //                                 errorWidget: (_, __, ___) => Container(
// //                                   color: Colors.grey[200],
// //                                   child: const Icon(Icons.broken_image,
// //                                       color: Colors.grey),
// //                                 ),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 12),
// //                             Expanded(
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(item.product.name,
// //                                       style: const TextStyle(
// //                                           fontWeight: FontWeight.bold,
// //                                           fontSize: 16)),
// //                                   const SizedBox(height: 4),
// //                                   Text(
// //                                       "Price: ₹${item.product.price.toStringAsFixed(2)}",
// //                                       style: const TextStyle(
// //                                           color: Colors.black54)),
// //                                   const SizedBox(height: 8),
// //                                   Row(
// //                                     children: [
// //                                       _quantityButton(
// //                                         icon: Icons.remove,
// //                                         onTap: loading
// //                                             ? null
// //                                             : () => cartNotifier
// //                                             .decreaseQuantity(
// //                                             item.product.id),
// //                                         isLoading: loading,
// //                                       ),
// //                                       Padding(
// //                                         padding: const EdgeInsets.symmetric(
// //                                             horizontal: 16),
// //                                         child: Text("${item.quantity}",
// //                                             style: const TextStyle(
// //                                                 fontSize: 16,
// //                                                 fontWeight: FontWeight.bold)),
// //                                       ),
// //                                       _quantityButton(
// //                                         icon: Icons.add,
// //                                         onTap: loading
// //                                             ? null
// //                                             : () => cartNotifier
// //                                             .increaseQuantity(
// //                                             item.product.id),
// //                                         isLoading: loading,
// //                                       ),
// //                                       const Spacer(),
// //                                       TextButton(
// //                                         onPressed: loading
// //                                             ? null
// //                                             : () => cartNotifier
// //                                             .removeItem(item.product.id),
// //                                         child: Text("Delete",
// //                                             style: TextStyle(
// //                                                 color: loading
// //                                                     ? Colors.grey
// //                                                     : Colors.red)),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //
// //                 // Bottom Section
// //                 Container(
// //                   padding: const EdgeInsets.all(18),
// //                   decoration: const BoxDecoration(
// //                     color: Colors.white,
// //                     boxShadow: [
// //                       BoxShadow(
// //                           color: Colors.grey, blurRadius: 10, offset: Offset(0, -5))
// //                     ],
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       userAddress == null || userAddress.state == null
// //                           ? Center(
// //                         child: Container(
// //                           width: double.infinity,
// //                           decoration: BoxDecoration(
// //                             color: AjugnuTheme.appColor,
// //                             borderRadius: BorderRadius.circular(30),
// //                           ),
// //                           child: TextButton(
// //                             onPressed: () {
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                     builder: (_) =>
// //                                     const AddNewAddressScreen()),
// //                               );
// //                             },
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Image.asset(
// //                                     "assets/icons/locationIcon.png",
// //                                     width: 20,
// //                                     height: 20),
// //                                 const SizedBox(width: 8),
// //                                 const Text("Add Shipping Address",
// //                                     style: TextStyle(
// //                                         color: Colors.white,
// //                                         fontSize: 16)),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       )
// //                           : Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Text("Shipping Address:",
// //                               style:
// //                               TextStyle(fontWeight: FontWeight.bold)),
// //                           const SizedBox(height: 6),
// //                           Text(
// //                             "${userAddress.buildingName ?? ''}\n${userAddress.city ?? ''}, ${userAddress.state ?? ''}",
// //                             style: const TextStyle(color: Colors.black87),
// //                           ),
// //                           const SizedBox(height: 10),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 10),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text("Shipping Charges:",
// //                               style: TextStyle(fontSize: 16)),
// //                           Text("₹${shippingCharge.toStringAsFixed(2)}",
// //                               style: const TextStyle(fontSize: 16)),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text("Total:",
// //                               style: TextStyle(
// //                                   fontSize: 18, fontWeight: FontWeight.bold)),
// //                           Text("₹${cartNotifier.total.toStringAsFixed(2)}",
// //                               style: const TextStyle(
// //                                   fontSize: 18, fontWeight: FontWeight.bold)),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 20),
// //
// //                       // Checkout Button with PhonePe
// //                       SizedBox(
// //                         width: double.infinity,
// //                         child: ElevatedButton(
// //                           onPressed: (userAddress == null || cartItems.isEmpty) ||
// //                               (userAddress.state == null)
// //                               ? null
// //                               : () {
// //                             double totalAmount = cartNotifier.total;
// //                             if (totalAmount <= 0) {
// //                               Fluttertoast.showToast(msg: "Cart is empty!");
// //                               return;
// //                             }
// //
// //                             // **Start PhonePe Payment**
// //                             _startPhonePePayment(totalAmount);
// //                           },
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: AjugnuTheme.appColor,
// //                             padding: const EdgeInsets.symmetric(vertical: 16),
// //                             shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(30)),
// //                           ),
// //                           child: Text("Checkout",
// //                               style: TextStyle(
// //                                   fontSize: 18,
// //                                   color: userAddress?.state == null
// //                                       ? Colors.grey
// //                                       : Colors.white,
// //                                   fontWeight: FontWeight.bold)),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmptyView(String message) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
// //           const SizedBox(height: 16),
// //           Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey)),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _quantityButton(
// //       {required IconData icon, required VoidCallback? onTap, required bool isLoading}) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(6),
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: onTap == null ? Colors.grey : Colors.black,
// //         ),
// //         child: isLoading
// //             ? const SizedBox(
// //             width: 16,
// //             height: 16,
// //             child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
// //             : Icon(icon, color: Colors.white, size: 16),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildShimmerList() {
// //     return ListView.builder(
// //       padding: const EdgeInsets.all(16),
// //       itemCount: 5,
// //       physics: const AlwaysScrollableScrollPhysics(),
// //       itemBuilder: (context, index) {
// //         return Container(
// //           margin: const EdgeInsets.only(bottom: 16),
// //           padding: const EdgeInsets.all(12),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(12),
// //             boxShadow: [
// //               BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)
// //             ],
// //           ),
// //           child: Row(
// //             children: [
// //               Shimmer.fromColors(
// //                 baseColor: Colors.grey[300]!,
// //                 highlightColor: Colors.grey[100]!,
// //                 child: Container(
// //                     width: 80,
// //                     height: 80,
// //                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
// //               ),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Shimmer.fromColors(
// //                         baseColor: Colors.grey[300]!,
// //                         highlightColor: Colors.grey[100]!,
// //                         child: Container(height: 16, width: 150, color: Colors.white)),
// //                     const SizedBox(height: 8),
// //                     Shimmer.fromColors(
// //                         baseColor: Colors.grey[300]!,
// //                         highlightColor: Colors.grey[100]!,
// //                         child: Container(height: 14, width: 100, color: Colors.white)),
// //                     const SizedBox(height: 12),
// //                     Row(
// //                       children: [
// //                         Shimmer.fromColors(
// //                             baseColor: Colors.grey[300]!,
// //                             highlightColor: Colors.grey[100]!,
// //                             child: Container(width: 30, height: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
// //                         const SizedBox(width: 32),
// //                         Shimmer.fromColors(
// //                             baseColor: Colors.grey[300]!,
// //                             highlightColor: Colors.grey[100]!,
// //                             child: Container(width: 40, height: 20, color: Colors.white)),
// //                         const SizedBox(width: 32),
// //                         Shimmer.fromColors(
// //                             baseColor: Colors.grey[300]!,
// //                             highlightColor: Colors.grey[100]!,
// //                             child: Container(width: 30, height: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jkautomed/JKAutoMed/Services/Api_Service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../ajugnu_constants.dart';
import '../../models/ajugnu_users.dart';
import '../../users/common/backend/ajugnu_auth.dart';
import '../../users/customer/customer_home_screen.dart';
import '../Modelss/get_card_model.dart';
import '../providers/get_card_provider.dart';
import 'address_screen.dart';

class MyCartScreens extends ConsumerStatefulWidget {
  final hideButton;
  const MyCartScreens( {super.key,this.hideButton,});
  // in flutter main widget is build method build methoad render image, appbar, scafold and render degine .

  @override
  ConsumerState<MyCartScreens> createState() => _MyCartScreensState();
}

class _MyCartScreensState extends ConsumerState<MyCartScreens>
    with WidgetsBindingObserver {
  late Razorpay _razorpay;
  CartResponse? _currentCartResponse;

  // Naye variables payment tracking ke liye
  String? _latestPaymentId;
  String _latestPaymentStatus = "pending";

  // @override
  // void initState() {
  //   super.initState();
  //   _razorpay = Razorpay();
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  //   _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  //
  //   WidgetsBinding.instance.addObserver(this);
  //   Future.microtask(() => ref.read(cartProvider.notifier).fetchCart());
  //
  //
  //   void _verifyCashfreePayment(String orderId) {
  //     Fluttertoast.showToast(msg: "Payment Successful! Order: $orderId");
  //     _createOrderAfterPayment();  // yeh call kar – internal order, shiprocket, transaction sab ho jayega
  //   }
  //
  //   void _onCashfreeError(CFErrorResponse error, String? orderId) {
  //     Fluttertoast.showToast(msg: "Payment Failed: ${error.getMessage()}");
  //     // failed handle kar (toast ya retry)
  //   }
  //
  //
  // }


  @override
  void initState() {
    super.initState();

    CFPaymentGatewayService().setCallback(
      verifyPayment,
      onError,
    );

    Future.microtask(() => ref.read(cartProvider.notifier).fetchCart());
  }

  void verifyPayment(String orderId) async {
    debugPrint("✅ Payment Success: $orderId");

    Fluttertoast.showToast(msg: "Payment Successful");

    // 👇 yaha call kar
    await _createOrderAfterPayment();
  }

  void onError(CFErrorResponse error, String orderId) {
    debugPrint("❌ Payment Failed: ${error.getMessage()}");

    Fluttertoast.showToast(
      msg: "Payment Failed: ${error.getMessage()}",
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed) {
    //   ref.read(cartProvider.notifier).fetchCart();
    // }
    if (state == AppLifecycleState.resumed) {
      ref.read(cartProvider.notifier).fetchCart();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(cartProvider.notifier).fetchCart();
  }

  // Razorpay Handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _latestPaymentId = response.paymentId;
    _latestPaymentStatus = "success";

    Fluttertoast.showToast(msg: "Payment Successful! ID: ${response.paymentId}");

    // Success ke baad hi order process shuru karo
    await _createOrderAfterPayment();
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    _latestPaymentStatus = "failed";
    _latestPaymentId = null;

    Fluttertoast.showToast(
        msg: "Payment Failed: ${response.message ?? 'Unknown error'}");
    // Yahan failed transaction record nahi kar rahe kyunki order bana hi nahi
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  // Razorpay checkout open
  // void _openCheckout(double amountInRupees) {
  //   var options = {
  //     // 'key': 'rzp_test_R7z5O0bqmRXuiH', // Real key daal dena production mein
  //     // 'key': 'rzp_live_Ryzl8H7cRDsFxj', // Real client old live api key
  //     'key': 'rzp_live_S9bpIgNW47Ut9N', // Real client live api key
  //     // 'key': 'rzp_live_aASdWlCCSdULeU', // This is razerpay is smart vyapar live
  //     'amount': (amountInRupees * 100).toInt(),
  //     'name': 'JKAutomed Store',
  //     'description': 'Order Payment',
  //     'currency': 'INR',
  //     'prefill': {
  //       'contact': '9876543210',
  //       'email': 'customer@example.com',
  //
  //     },
  //     'theme': {
  //       'color': '#007bff',
  //     }
  //   };
  //   // 'color': '#FF6B00',
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint('Razorpay Open Error: $e');
  //     Fluttertoast.showToast(msg: "Payment gateway error");
  //   }
  // }

  Future<void> _createOrderAfterPayment() async {
    if (_currentCartResponse == null) {
      Fluttertoast.showToast(msg: "Cart data not available");
      return;
    }

    final cartResponse = _currentCartResponse!;
    final userAddress = cartResponse.userfulladdress;

    if (userAddress == null) {
      Fluttertoast.showToast(msg: "Please add shipping address");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    if (userId == null) {
      Fluttertoast.showToast(msg: "Login required");
      return;
    }


    // Shiprocket items format
    final List<Map<String, dynamic>> items = cartResponse.cartItems.map((item) {
      return {
        "name": item.product.name,
        "selling_price": item.product.price.toInt(),
        "units": item.quantity,
      };
    }).toList();

    final Map<String, dynamic> billing = {
      "name": "Customer Name",
      "address": "${userAddress.buildingName ?? ''}, ${userAddress.addressLine ?? ''}",
      "city": userAddress.city ?? "Indore",
      "state": userAddress.state ?? "Madhya Pradesh",
      "pincode": cartResponse.userPincode ?? "452001",
      "email": "customer@example.com",
      "phone": "9876543210",
    };

    final Map<String, dynamic> internalOrderData = {
      "user_id": userId,
      "items": cartResponse.cartItems.map((item) {
        print("Product id: ${item.id}, name: ${item.product.name}");
        return {
          "product_id": item.product.id,
          "product_name": item.product.name,
          "selling_price": item.product.price.toInt(),
          "units": item.quantity,
        };
      }).toList(),
      "shipping_address": {
        "name": "Customer Name",
        "address": billing['address'],
        "pincode": billing['pincode'],
        "mobile_number": billing['phone'],
      },
      "payment_method": "online",
      "total_amount": ref.read(cartProvider.notifier).total.toInt(),
    };

    try {
      final apiService = ref.read(apiServiceProvider);

      // 1. Internal Order Create
      final internalResult = await apiService.createOrder(internalOrderData);
      if (!(internalResult['status'] ?? false)) {
        throw Exception(internalResult['message'] ?? "Order creation failed");
      }

      final String orderId = internalResult['data']['_id'];

      // 2. Shiprocket Order Create
      final Map<String, dynamic> shiprocketPayload = {
        "order_id": orderId,
        "billing": billing,
        "items": items,
        "courier": {
          "courier_company_id": cartResponse.courierData?.courierCompanyId ?? 217,
          "shipping_charge": cartResponse.courierData?.rate?.toDouble() ?? 0.0,
        },
        "dimensions": {
          "weight": cartResponse.totalWeight
        },
        "payment_method": "Prepaid"
      };

      final shiprocketResult = await apiService.createBackendShiprocketOrder(shiprocketPayload);
      final String shipmentId = shiprocketResult['shiprocket']['shipment_id'].toString();
      final String courierId = (cartResponse.courierData?.courierCompanyId ?? 217).toString();

      print("Shipment ID: $shipmentId | Courier ID: $courierId");

      // 3. Transaction Record
      if (_latestPaymentId == null) {
        throw Exception("Payment ID missing!");
      }

      final String userName = "Pooja PD"; // ← baad mein dynamic kar dena

      final Map<String, dynamic> transactionPayload = {
        "user_id": userId,
        "order_id": orderId,
        "payment_id": _latestPaymentId,
        "payment_status": "success",
        "total_amount": ref.read(cartProvider.notifier).total.toInt(),
        "payment_method": "online",
        "user_name": userName,
      };

      final transactionResult = await apiService.addTransaction(transactionPayload);
      if (!(transactionResult['status'] ?? false)) {
        debugPrint("Transaction save failed: ${transactionResult['message']}");
      }

      // 4. Shipping Product Assign (AWB Assign) - Yeh sabse important
      final Map<String, dynamic> shipingProductAssignPayload = {
        "order_db_id": orderId,
        "user_id": userId,
        "shipment_id": int.tryParse(shipmentId) ?? shipmentId,
        "courier_id": int.tryParse(courierId) ?? courierId,
      };

      final shipingProductAssignResult = await apiService.shipingProductAssign(shipingProductAssignPayload);

      // ===== Final Snackbar - Sirf yahi dikhega =====
      if (mounted) {
        String message;
        Color backgroundColor;

        if (shipingProductAssignResult['success'] == true) {
          message = shipingProductAssignResult['message'] ?? "AWB assigned & order updated successfully";
          backgroundColor = Colors.green.shade700;
        } else {
          message = shipingProductAssignResult['message'] ?? "AWB assignment failed";
          backgroundColor = Colors.orange.shade800;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }

      // Cart refresh aur Home navigation
      ref.read(cartProvider.notifier).fetchCart();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
              (route) => false,
        );
      }

    } catch (e) {
      debugPrint("Order/Transaction Error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order process failed: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }


  void _openPhonePePayment(double amountInRupees) async {
    // PhonePe deep link format
    // pa: payee number / merchant id, pn: payee name, tr: transaction ref, tn: txn note
    final String phonePeUrl =
        "phonepe://pay?pa=XXXXXXXXXX&pn=JKAutomed&tr=TXN${DateTime.now()
        .millisecondsSinceEpoch}&tn=Order+Payment&am=${amountInRupees.toStringAsFixed(2)}&cu=INR";

    final Uri uri = Uri.parse(phonePeUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: "PhonePe app is not installed on your device");
    }
  }




  @override
  Widget build(BuildContext context) {
    ref.listen(cartProvider, (previous, next) {
      // Optional: Agar server se naya data aaya to kuch karna ho (jaise toast)
    });
    final cartAsync = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.hideButton == "hidebutton"
            ? const SizedBox()
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("My Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AjugnuTheme.appColor,
        child: cartAsync.when(
          loading: () => _buildShimmerList(),
          error: (_, __) => _buildEmptyView("Something went wrong"),
          data: (cartResponse) {
            _currentCartResponse = cartResponse;

            final cartItems = cartResponse.cartItems;
            if (cartItems.isEmpty) {
              return _buildEmptyView("Your cart is empty");
            }

            final userAddress = cartResponse.userfulladdress;
            final shippingCharge = cartResponse.courierData?.rate?.toDouble() ?? 0.0;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final bool loading = cartNotifier.isLoading(item.product.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: "${item.product.firstImage}",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: Colors.grey[200]),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("Price: ₹${item.product.price.toStringAsFixed(2)}",
                                      style: const TextStyle(color: Colors.black54)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _quantityButton(
                                        icon: Icons.remove,
                                        onTap: loading ? null : () => cartNotifier.decreaseQuantity(item.product.id),
                                        isLoading: loading,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text("${item.quantity}",
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                      _quantityButton(
                                        icon: Icons.add,
                                        onTap: loading ? null : () => cartNotifier.increaseQuantity(item.product.id),
                                        isLoading: loading,
                                      ),
                                      const Spacer(),
                                      // TextButton(
                                      //   onPressed: loading ? null : () {
                                      //    ApiService.deleteCartitem(item.product.id);
                                      //   }, /*=> cartNotifier.removeItem(item.product.id),*/
                                      //   child: Text("Delete",
                                      //       style: TextStyle(color: loading ? Colors.grey : Colors.red)),
                                      // ),
                                      TextButton(
                                        onPressed: loading ? null : () => cartNotifier.removeItem(item.product.id),
                                        child: Text("Delete",
                                            style: TextStyle(color: loading ? Colors.grey : Colors.red)),
                                      ),
                                    ],
                                  ),
                                  TextButton(onPressed: (){print("Abhi:- print image url --> ${item.product.firstImage}");}, child: Text("product image")),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey, blurRadius: 10, offset: Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    children: [
                      userAddress == null || userAddress.state == null
                          ? Center(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AjugnuTheme.appColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddNewAddressScreen()),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/icons/locationIcon.png", width: 20, height: 20),
                                const SizedBox(width: 8),
                                const Text("Add Shipping Address",
                                    style: TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Shipping Address:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            // "${userAddress.buildingName ?? ''}\n${userAddress.addressLine ?? ''}\n${userAddress.city ?? ''}, ${userAddress.state ?? ''}",
                            "${userAddress.buildingName ?? ''}\n${userAddress.city ?? ''}, ${userAddress.state ?? ''}",
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Shipping Charges:", style: TextStyle(fontSize: 16)),
                          Text("₹${shippingCharge.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("₹${cartNotifier.total.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),


                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // onPressed: (userAddress == null || cartItems.isEmpty) || (userAddress.state == null)
                          //     ? null
                          //     : ()  async {
                          //   double totalAmount = cartNotifier.total;
                          //   if (totalAmount <= 0) {
                          //     Fluttertoast.showToast(msg: "Cart is empty!");
                          //     return;
                          //   }
                          //   final res  = await  ref.read(apiServiceProvider).createPhonePeOrder(totalAmount);
                          //   if(res["success"] == true) {
                          //     print("order success is true");
                          //     String order_Id = res["orderId"];
                          //     String deepLink = res["redirectUrl"];
                          //     final Uri uri = Uri.parse(deepLink);
                          //
                          //     if (await canLaunchUrl(uri)) {
                          //       final res = await launchUrl(uri).then((value) =>
                          //           ref
                          //               .read(apiServiceProvider)
                          //               .verifyPhonePeOrder(order_Id));
                          //       if (res["success"] == true) {
                          //         print("Payment verification success");
                          //         _createOrderAfterPayment();
                          //       } else {
                          //         Fluttertoast.showToast(
                          //             msg: "PhonePe app is not installed on your device");
                          //       }
                          //     }
                          //   }
                          //
                          //   // **Open PhonePe Payment**
                          //   // _openPhonePePayment(totalAmount);
                          // },

                          onPressed: (userAddress == null || cartItems.isEmpty || userAddress.state == null)
                              ? null
                              : () async {
                            double totalAmount = cartNotifier.total;
                            if (totalAmount <= 0) {
                              Fluttertoast.showToast(msg: "Cart is empty!");
                              return;
                            }

                            try {
                              // 1. Cashfree order create (backend call)
                              AjugnuUser? user = AjugnuAuth().getUser();
                              print("Abhi mobileNumber -> ${user?.mobile} , email: ${user?.email}, fullName: ${user?.fullName}");
                              final cashfreeRes = await ref.read(apiServiceProvider).createCashfreeOrder(
                                amount: totalAmount,
                                customerName: "${user?.fullName}",  // dynamic kar: user se le lo
                                customerPhone: "${user?.mobile}",
                                customerEmail: "${user?.email}",
                              );

                              if (cashfreeRes['success'] != true) {
                                Fluttertoast.showToast(msg: "Order creation failed!");
                                return;
                              }

                              final orderId = cashfreeRes['order_id'];
                              // final orderId = "ORD_1773838474545_q5yfb";
                              final sessionId = cashfreeRes['payment_session_id'];
                              // final sessionId = "session_Xlc_GtA7ij3k8LUwqEQzPJ2UA2Tp3BmhZz90-pI7NY2PDSrYFXWd07f7HB1kNEeM4YSlhshLVtviLM7LsDCStPR9hoANMMquO0c_-dgQfty6sbzcDlqAzKZ16Zqv";

                              // 2. Cashfree SDK launch
                              // CFSession session = CFSessionBuilder()
                              //     .setEnvironment(CFEnvironment.SANDBOX)  // live mein PRODUCTION
                              //     .setOrderId(orderId)
                              //     .setPaymentSessionId(sessionId)
                              //     .build();

                              print("Abhi:- cashfree orderId: $orderId, sessionId: $sessionId");
                              CFSession session = CFSessionBuilder()
                                  // .setEnvironment(CFEnvironment.SANDBOX)
                                  .setEnvironment(CFEnvironment.PRODUCTION)
                                  .setOrderId(orderId)                     // must match what backend returned
                                  .setPaymentSessionId(sessionId)
                                  .build();

                              CFWebCheckoutPayment checkout = CFWebCheckoutPaymentBuilder()
                                  .setSession(session)
                                  .build();

                              // Callbacks already set hain? Agar nahi toh set kar do (initState mein)
                              // CFPaymentGatewayService().setCallback(verifyPayment, onError);

                              await CFPaymentGatewayService().doPayment(checkout);

                              // Success callback mein _createOrderAfterPayment() call hoga (neeche add kar)

                            } catch (e) {
                              debugPrint("Cashfree error: $e");
                              Fluttertoast.showToast(msg: "Payment initiation failed: $e");
                            }
                          }, //
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AjugnuTheme.appColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                              "Checkout",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: userAddress?.state == null ? Colors.grey : Colors.white,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
//
//   // Baaki helper widgets (unchanged)
  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback? onTap, required bool isLoading}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null ? Colors.grey : Colors.black,
        ),
        child: isLoading
            ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)
            ],
          ),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(height: 16, width: 150, color: Colors.white)),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(height: 14, width: 100, color: Colors.white)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(width: 30, height: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
                        const SizedBox(width: 32),
                        Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(width: 40, height: 20, color: Colors.white)),
                        const SizedBox(width: 32),
                        Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(width: 30, height: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
