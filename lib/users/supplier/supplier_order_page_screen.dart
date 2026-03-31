import 'package:jkautomed/main.dart';
import 'package:jkautomed/users/common/AjugnuFlushbar.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:jkautomed/users/supplier/backend/product_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ajugnu_constants.dart';
import '../../models/ajugnu_order.dart';
import '../common/backend/api_handler.dart';

class SupplierOrderPageScreen extends StatefulWidget {
  final String?orderId;
  const SupplierOrderPageScreen({super.key,this.orderId});

  @override
  State<StatefulWidget> createState() {
    return SupplierOrderPageState();
  }

}

class SupplierOrderPageState extends State<SupplierOrderPageScreen> {
  List<AjugnuOrder>? orderList;
  Future<void> fetchOrders() async {
    ProductRepository().getOrders().then((results) {
      if (results.isNotEmpty) {

        if(widget.orderId !=null && widget.orderId!.isNotEmpty){
          final filteredOrder=results.firstWhere(
            (order) =>order.orderID== widget.orderId ,
            orElse: () => null as AjugnuOrder,
          );
          setState(() {
            orderList=filteredOrder !=null ? [filteredOrder]:[];
          });
        } else{
          setState(() {
            orderList = results;
          });
        }
      } else {
        setState(() {
          orderList = [];
        });
      }
    }, onError: (error) {
      adebug(error);
      setState(() {
        orderList = [];
      });
    });
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () => fetchOrders());
  }


  @override
  Widget build(BuildContext context) {
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
        body: orderList == null ? const Center(
          child: CircularProgressIndicator(),
        ) : orderList!.isEmpty ? Center(
          child: Card(
            elevation: 0,
            color: AjugnuTheme.appColorScheme.surface,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.width * 0.05),
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
                    child: CommonWidgets.text('No one ordered your product yet..', alignment: TextAlign.center, textColor: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ) : ListView.builder(
          itemBuilder: (context, index0) => Card.outlined(
              color: Color.fromARGB(255, 246, 246, 246),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16, left: 8, bottom: 2),
                                child: CommonWidgets.text(orderList![index0].orderID, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8, ),
                                child: CommonWidgets.text(orderList![index0].date, maxLines: 1, overflow: TextOverflow.ellipsis, textColor: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CommonWidgets.text('Payment Type', fontFamily: 'Poly', fontSize: 17, fontWeight: FontWeight.w500, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5),
                              CommonWidgets.text(orderList![index0].paymentMethod.toUpperCase(), fontSize: 13, textColor: Colors.green, fontWeight: FontWeight.w500, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index1) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child:orderList![index0].orderSupplier[index1].status.toString()=="cancelled"?Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text("Cancelled",style: TextStyle(color: Colors.red)),
                                ):StatusDropdown(order: orderList![index0]),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CommonWidgets.text('Total Amount', fontFamily: 'Poly', fontSize: 17, fontWeight: FontWeight.w500),
                                    const SizedBox(height: 5),
                                    CommonWidgets.text("₹${orderList![index0].orderSupplier[index1].totalAmount.toString()}", fontSize: 13, textColor: Colors.green, fontWeight: FontWeight.w500, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: orderList![index0].orderSupplier[index1].products.length,
                            itemBuilder: (context, index2) => Card.outlined(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                              elevation: 0,
                              clipBehavior: Clip.hardEdge,
                              child:  Row(
                                children: [
                                  CachedNetworkImage(
                                    width: 100,
                                    height: 100,
                                    imageUrl: orderList![index0].orderSupplier[index1].products[index2].productImages.firstOrNull ?? '',
                                    placeholderFadeInDuration: Duration.zero,
                                    fit: BoxFit.cover,
                                    placeholder: (context, error) => Container(color: Colors.black12),
                                    errorWidget: (context, url, error) => Container(color: Colors.black12, child: const Icon(Icons.image_not_supported)),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CommonWidgets.text(orderList![index0].orderSupplier[index1].products[index2].productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text.rich(
                                              TextSpan(
                                                  text: "Quantity: ",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 17,
                                                      fontFamily: 'Poly'
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: orderList![index0].orderSupplier[index1].products[index2].quantity.toString(),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 17,
                                                          fontFamily: 'Poly'
                                                      ),
                                                    )
                                                  ]
                                              )
                                          ),
                                          Text.rich(
                                              TextSpan(
                                                  text: "Price: ",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 17,
                                                      fontFamily: 'Poly'
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "₹${orderList![index0].orderSupplier[index1].products[index2].price}",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 17,
                                                          fontFamily: 'Poly'
                                                      ),
                                                    )
                                                  ]
                                              )
                                          )
                                          // CommonWidgets.text("Quantity: ${ordersList[index].products[index2].quantity}", textColor: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      itemCount: orderList![index0].orderSupplier.length,
                    )
                  ],
                ),
              )
          ),
          itemCount: orderList?.length,
        )
    );
  }

}

class StatusDropdown extends StatefulWidget {
  final AjugnuOrder order;

  const StatusDropdown({super.key, required this.order});

  @override
  State<StatefulWidget> createState() {
    return StatusState();
  }

}

class StatusState extends State<StatusDropdown> {
  bool isPending() => widget.order.orderSupplier.firstOrNull?.status == 'order' || widget.order.orderSupplier.firstOrNull?.status == 'pending';
  bool isOnTheWay() => widget.order.orderSupplier.firstOrNull?.status == 'ontheway';
  bool isCompleted() => widget.order.orderSupplier.firstOrNull?.status == 'delivered';

  String refineStatus(String status) => status.toLowerCase().replaceAll('pending', 'order').replaceAll(' ', '');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
          ),
          color: isCompleted() ? const Color.fromARGB(255, 152, 244, 183) : isOnTheWay() ? const Color.fromARGB(255, 255, 149, 0).withOpacity(0.5) : Colors.grey.withOpacity(0.5),
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: PopupMenuButton<String>(
              tooltip: 'Order Status',
              // icon: Icon(Icons.keyboard_arrow_down_sharp),
              onSelected: (value) {
                // Handle menu selection
                if (value == 'delivered' && (isPending() || isOnTheWay())) {
                  showDeliveryVerificationDialog();
                } else if (isPending() && value == 'on the way'){
                  CommonWidgets.showProgress();
                  ProductRepository().updateOrderStatus(widget.order.orderSupplier.first.products.first.id, widget.order.id, refineStatus(value)).then((message) {
                    CommonWidgets.removeProgress();
                    setState(() {
                      widget.order.orderSupplier.firstOrNull?.status = refineStatus(value);
                    });
                  }, onError: (error) {
                    CommonWidgets.removeProgress();
                    AjugnuFlushbar.showError(getAjungnuGlobalContext(), error.toString());
                  });
                } else if (widget.order.orderSupplier.firstOrNull?.status != refineStatus(value)) {
                  AjugnuFlushbar.showError(context, 'You can\'t revert order status.');
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
              ),
              itemBuilder: (BuildContext context) {
                return {'pending', 'on the way', 'delivered'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text("${choice.substring(0, 1).toUpperCase()}${choice.substring(1).toLowerCase()}"),
                  );
                }).toList();
              },
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: CommonWidgets.text(
                        isPending() ? 'Pending' : isOnTheWay() ? 'On the way' : 'Delivered',
                        fontFamily: 'Poly',
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        alignment: TextAlign.center,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down)
                ],
              ),
            ),
          )
      ),
    );
  }

  void showDeliveryVerificationDialog() {
    String code = '';

    void update() {
      Navigator.of(context).pop();
      if (widget.order.orderSupplier.firstOrNull?.verificationId == code) {
        setState(() {
          widget.order.orderSupplier.firstOrNull?.status = refineStatus('delivered');
        });
        CommonWidgets.showProgress();
        ProductRepository().updateOrderStatus(widget.order.orderSupplier.first.products.first.id, widget.order.id, refineStatus('delivered')).then((message) {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showSuccess(getAjungnuGlobalContext(), 'Item delivered successfully');
        }, onError: (error) {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showError(getAjungnuGlobalContext(), error.toString());
        });
      } else {
        AjugnuFlushbar.showError(getAjungnuGlobalContext(), 'Wrong code');
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter verification code from customer\'s order page to verify product is genuinely delivered'),
              TextField(
                maxLines: 1,
                onEditingComplete: () => update(),
                onChanged: (v) => code = v,
                decoration: const InputDecoration(
                    labelText: 'Verification Code',
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Verify'),
              onPressed: () => update(),
            ),
          ],
        );
      },
    );
  }
}