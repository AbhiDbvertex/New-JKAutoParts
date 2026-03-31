
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jkautomed/users/customer/product_change_listeners.dart';

import '../../ajugnu_constants.dart';
import '../../ajugnu_navigations.dart';
import '../../models/ajugnu_order.dart';
import '../../models/ajugnu_product.dart';
import '../common/AjugnuFlushbar.dart';
import '../common/backend/ajugnu_auth.dart';
import '../common/backend/api_handler.dart';
import '../common/common_widgets.dart';
import 'backend/cart_repository.dart';

class CustomerOrderPageScreen extends StatefulWidget {
final String? orderId;
  const CustomerOrderPageScreen({super.key,this.orderId,});

  @override
  State<StatefulWidget> createState() {
    return CustomerOrderPageState();
  }
}

class CustomerOrderPageState extends State<CustomerOrderPageScreen> {
  List<AjugnuOrder>? orderList;

  void onProductChange(AjugnuProduct product, bool completeProduct) {
    for (AjugnuOrder order in (orderList ?? [])) {
      for (var orderSupplier in order.orderSupplier) {
        int index =
            orderSupplier.products.indexWhere((prod) => prod.id == product.id);
        if (index > -1) {
          setState(() {
            orderSupplier.products[index].isRated = product.isRated;
          });
          return;
        }
      }
    }
  }

  // Future<void> fetchOrders() async {
  //    CartRepository().getOrders(widget.orderId).then((results) {
  //     if (results.isNotEmpty) {
  //       if(widget.orderId !=null && widget.orderId!.isNotEmpty){
  //         print("Abhi:- get orderId: 1 ${widget.orderId}");
  //         final filteredOrder=results.firstWhere(
  //           (order) => order.orderID==widget.orderId,
  //           orElse: () => null as AjugnuOrder,
  //         );
  //         setState(() {
  //           orderList=filteredOrder != null ? [filteredOrder]:[];
  //         });
  //       }
  //         else{
  //         setState(() {
  //           orderList = results;
  //         });
  //       }
  //
  //     } else {
  //       setState(() {
  //         orderList = [];
  //       });
  //     }
  //   }, onError: (error) {
  //     adebug(error);
  //     setState(() {
  //       orderList = [];
  //     });
  //   });
  //   ProductChangeListeners.addListener(onProductChange);
  // }

  Future<void> fetchOrders() async {
    CartRepository().getOrders(/*widget.orderId*/).then((results) {
      print("Abhi:- orders count: ${results.length}");

      setState(() {
        orderList = results; // 🔥 no check, no filter
      });
    }, onError: (error) {
      adebug(error);
      setState(() {
        orderList = [];
      });
    });

    ProductChangeListeners.addListener(onProductChange);
  }

  @override
  void dispose() {
    ProductChangeListeners.removeListener(onProductChange);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () => fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    print("Abhi:- get orderId: ${widget.orderId}");
    return Scaffold(
        backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
        appBar: CommonWidgets.appbar(
          'Order History',
          systemUiOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: AjugnuTheme.appColorScheme.onPrimary,
            statusBarColor: AjugnuTheme.appColorScheme.onPrimary,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
        body: orderList == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : orderList!.isEmpty
                ? Center(
                    child: Card(
                      elevation: 0,
                      color: AjugnuTheme.appColorScheme.surface,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1,
                            vertical: MediaQuery.of(context).size.width * 0.05),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/empty_list.png',
                              height: MediaQuery.of(context).size.width * 0.3,
                              width: MediaQuery.of(context).size.width * 0.3,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CommonWidgets.text(
                                  'You have not placed any order yet.',
                                  alignment: TextAlign.center,
                                  textColor: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemBuilder: (context, index0) => Card(
                        color: Color.fromARGB(
                          255,
                          228,
                          244,
                          214,
                        ),
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 6),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CommonWidgets.text(
                                              orderList![index0].orderID,
                                              fontSize: 15,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                        CommonWidgets.text(orderList![index0].date,
                                            fontFamily: 'Poly',
                                            fontSize: 17,
                                            textColor: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text.rich(TextSpan(
                                              text: "Payment Type: ",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  fontFamily: 'Poly'),
                                              children: [
                                                TextSpan(
                                                  text: orderList![index0]
                                                      .paymentMethod
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      fontFamily: 'Poly'),
                                                )
                                              ])),
                                        ),
                                        Visibility(
                                          visible: orderList![index0]
                                              .orderSupplier
                                              .first
                                              .status
                                              .toString()
                                              .trim() ==
                                              "order" ||
                                              orderList![index0]
                                                  .orderSupplier
                                                  .first
                                                  .status
                                                  .toString()
                                                  .trim() ==
                                                  "cancelled"
                                              ? true
                                              : false,
                                          child: InkWell(
                                            onTap: orderList![index0]
                                                .orderSupplier
                                                .first
                                                .status
                                                .toString()
                                                .trim() ==
                                                "order"
                                                ? () {
                                              //debugPrint("${orderList![index0].orderID}");
                                              onCancelRequest(
                                                  "${orderList![index0].id}");
                                            }
                                                : null,
                                            child: CommonWidgets.text(
                                                orderList![index0]
                                                    .orderSupplier
                                                    .first
                                                    .status
                                                    .toString()
                                                    .trim() ==
                                                    "order"
                                                    ? "Cancel Order"
                                                    : "Order Canceled",
                                                textColor: Colors.red,
                                                fontSize: 12,
                                                maxLines: 1,
                                                overflow: TextOverflow
                                                    .ellipsis),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                CommonWidgets.text(
                                    "Total ₹${orderList![index0].orderSupplier.map((e) => e.totalAmount).reduce((a, b) => a + b)}",
                                    textColor: Colors.green,
                                    fontSize: 15,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index1) => Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  color: Colors.white,
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6, left: 6),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text.rich(
                                                        TextSpan(
                                                            text:
                                                                "Supplier Name: ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15.4,
                                                                fontFamily:
                                                                    'Poly'),
                                                            children: [
                                                              TextSpan(
                                                                text: orderList![
                                                                        index0]
                                                                    .orderSupplier[
                                                                        index1]
                                                                    .fullName,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15.4,
                                                                    fontFamily:
                                                                        'Poly'),
                                                              )
                                                            ]),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    const SizedBox(height: 6),
                                                    CommonWidgets.text(
                                                        "Verification Code: ${orderList![index0].orderSupplier[index1].verificationId}",
                                                        fontFamily: 'Poly',
                                                        fontSize: 15.4,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 5),
                                                CommonWidgets.text('Sub Total',
                                                    fontFamily: 'Poly',
                                                    fontSize: 15.4,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                const SizedBox(height: 5),
                                                CommonWidgets.text(
                                                    "₹${orderList![index0].orderSupplier[index1].totalAmount.toString()}",
                                                    fontSize: 13,
                                                    textColor: Colors.green,
                                                    fontWeight: FontWeight.w500,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ],
                                            )
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: orderList![index0]
                                                            .orderSupplier[
                                                                index1]
                                                            .status ==
                                                        'order'
                                                    ? Colors.grey
                                                        .withOpacity(0.5)
                                                    : orderList![index0].orderSupplier[index1].status ==
                                                            'delivered'
                                                        ? const Color.fromARGB(
                                                            255, 152, 244, 183)
                                                        : orderList![index0]
                                                                    .orderSupplier[
                                                                        index1]
                                                                    .status ==
                                                                'cancelled'
                                                            ? const Color(
                                                    0xFFFF9D9D)
                                                            : const Color.fromARGB(
                                                                180,
                                                                255,
                                                                149,
                                                                0),
                                                borderRadius:
                                                    BorderRadius.circular(200)),
                                            margin: const EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 6)
                                                .copyWith(bottom: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            child: CommonWidgets.text(
                                                orderList![index0]
                                                            .orderSupplier[
                                                                index1]
                                                            .status ==
                                                        'order'
                                                    ? 'Order Placed'
                                                    : orderList![index0]
                                                                .orderSupplier[
                                                                    index1]
                                                                .status ==
                                                            'delivered'
                                                        ? 'Delivered'
                                                        : orderList![index0]
                                                                    .orderSupplier[
                                                                        index1]
                                                                    .status ==
                                                                'cancelled'
                                                            ? "Cancelled"
                                                            : 'On The Way',
                                                fontFamily: 'Poly',
                                                textColor: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ),
                                        ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: orderList![index0]
                                              .orderSupplier[index1]
                                              .products
                                              .length,
                                          itemBuilder: (context, index2) =>
                                              Card.outlined(
                                            color: Colors.white,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2, vertical: 8),
                                            elevation: 0,
                                            clipBehavior: Clip.hardEdge,
                                            child: Row(
                                              children: [
                                                CachedNetworkImage(
                                                  width: 100,
                                                  height: 100,
                                                  imageUrl: orderList![index0]
                                                          .orderSupplier[index1]
                                                          .products[index2]
                                                          .productImages
                                                          .firstOrNull ??
                                                      '',
                                                  placeholderFadeInDuration:
                                                      Duration.zero,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context,
                                                          error) =>
                                                      Container(
                                                          color:
                                                              Colors.black12),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Container(
                                                          color: Colors.black12,
                                                          child: const Icon(Icons
                                                              .image_not_supported)),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CommonWidgets.text(
                                                            orderList![index0]
                                                                .orderSupplier[
                                                                    index1]
                                                                .products[
                                                                    index2]
                                                                .productName,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        Text.rich(TextSpan(
                                                            text: "Quantity: ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 17,
                                                                fontFamily:
                                                                    'Poly'),
                                                            children: [
                                                              TextSpan(
                                                                text: orderList![index0]
                                                                    .orderSupplier[
                                                                        index1]
                                                                    .products[
                                                                        index2]
                                                                    .quantity
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        17,
                                                                    fontFamily:
                                                                        'Poly'),
                                                              )
                                                            ])),
                                                        Text.rich(TextSpan(
                                                            text: "Price: ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 17,
                                                                fontFamily:
                                                                    'Poly'),
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    "₹${orderList![index0].orderSupplier[index1].products[index2].price}",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        17,
                                                                    fontFamily:
                                                                        'Poly'),
                                                              )
                                                            ]))
                                                        // CommonWidgets.text("Quantity: ${ordersList[index].products[index2].quantity}", textColor: Colors.grey),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                orderList![index0]
                                                                .orderSupplier[
                                                                    index1]
                                                                .products[
                                                                    index2]
                                                                .isRated ==
                                                            false &&
                                                        orderList![index0]
                                                                .orderSupplier[
                                                                    index1]
                                                                .status ==
                                                            'delivered'
                                                    ? SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.17,
                                                        child: Center(
                                                          child: Card(
                                                            color: const Color(
                                                                0xff040A05),
                                                            shape: RoundedRectangleBorder(
                                                                side: const BorderSide(
                                                                    color: Color(
                                                                        0xffABFFE7),
                                                                    width: 1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14)),
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 6),
                                                            clipBehavior:
                                                                Clip.hardEdge,
                                                            child: InkWell(
                                                              onTap: () => AjugnuNavigations.customerRatingScreen(
                                                                  productId: orderList![index0]
                                                                      .orderSupplier[
                                                                          index1]
                                                                      .products[
                                                                          index2]
                                                                      .id),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        10),
                                                                child: CommonWidgets.text(
                                                                    'Rate',
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox()
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                itemCount:
                                    orderList![index0].orderSupplier.length,
                              )
                            ],
                          ),
                        )),
                    itemCount: orderList?.length,
                  ));
  }

  Future<void> cancelOrder(String orderID) async {
    if (orderID.isNotEmpty) {
      CommonWidgets.showProgress();

      AjugnuAuth().cancelOrder(orderID).then((msg) {
        CommonWidgets.removeProgress();
        if (msg != null) {
          Navigator.pop(context);
          AjugnuFlushbar.showSuccess(context, '${msg}');
        }
      }, onError: (error) {
        CommonWidgets.removeProgress();
        AjugnuFlushbar.showError(
            context, 'Something went wrong while canceling order.');
      });
    } else {
      AjugnuFlushbar.showError(context, 'OrderID not found!');
    }
  }

  void onCancelRequest(String? orderID) {
    showDialog(
        context: context,
        useSafeArea: true,
        builder: (dialogContext) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(60))),
                    padding: const EdgeInsets.only(
                        top: 25, left: 24, bottom: 45, right: 24),
                    child: Column(
                      children: [
                        Card(
                          color: Theme.of(context).colorScheme.surface,
                          elevation: 0,
                          clipBehavior: Clip.hardEdge,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1000))),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                left: 36, top: 28, bottom: 28, right: 28),
                            child: Image(
                              image:
                                  AssetImage('assets/images/user_logout.png'),
                              height: 120,
                              width: 120,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                            alignment: Alignment.center,
                            child: Text('Are you sure to cancel order?',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AjugnuTheme.appColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 30),
                                      elevation: 5),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                    cancelOrder(orderID!);
                                  },
                                  child: const Text('YES',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))),
                              const Spacer(),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          side: BorderSide(
                                              color: AjugnuTheme.appColorScheme
                                                  .inversePrimary,
                                              width: 1)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 30),
                                      elevation: 5),
                                  onPressed: () {
                                    Navigator.of(context).pop('dialog');
                                  },
                                  child: const Text('NO',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)))
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
