import 'dart:convert';

import 'package:jkautomed/ajugnu_constants.dart';
import 'package:jkautomed/ajugnu_navigations.dart';
import 'package:jkautomed/main.dart';
import 'package:jkautomed/users/common/backend/api_handler.dart';
import 'package:jkautomed/users/common/common_widgets.dart';
import 'package:jkautomed/users/customer/backend/cart_repository.dart';
import 'package:jkautomed/users/customer/backend/razorpay_manager.dart';
import 'package:jkautomed/users/customer/product_change_listeners.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/ajugnu_cart_product.dart';
import '../../models/ajugnu_product.dart';
import '../common/AjugnuFlushbar.dart';
import '../common/backend/ajugnu_auth.dart';
import '../common/form_validator.dart';

class MyCartScreen extends StatefulWidget {
  final Function()? onExitCallbacks;

  const MyCartScreen.CardScreen({super.key, this.onExitCallbacks});

  @override
  State<StatefulWidget> createState() {
    return MyCartState();
  }
}

class MyCartState extends State<MyCartScreen> {
  List<AjugnuCartProduct>? products;
  String postalCode = '';

  var addressForm = AddressForm();
  String _paymentMethod = 'Online';
  var totalAmount = 0.0;
  bool isProductsQuantity = true;

  @override
  void initState() {
    super.initState();

    RazorpayManager().setCallbacks(
      onPaymentSuccess,
      onPaymentError,
      externalWalletCallback: onHandleExternalWallet,
    );

    Future.delayed(const Duration(seconds: 0), () => fetchCartProducts());
  }

  // void fetchCartProducts() {
  //   // if (CartRepository().doesCartProductsAvailableLocally()) {
  //   //   setState(() {
  //   //     if (CartRepository().cartProducts!.isEmpty) {
  //   //       products = [];
  //   //     } else {
  //   //       products = CartRepository().cartProducts!;
  //   //     }
  //   //   });
  //   // } else {
  //     CartRepository().getCartProducts().then((products) {
  //
  //
  //       setState(() {
  //         if (products.isEmpty ) {
  //           this.products = [];
  //         } else {
  //           this.products = products;
  //         }
  //       });
  //     }, onError: (error) {
  //       setState(() {
  //         this.products = [];
  //       });
  //     });
  //  // }
  // }
  Future<void> fetchCartProducts() async {
    CartRepository().getCartProducts().then(
      (result) {
        //CommonWidgets.removeProgress();
        setState(() {
          if (result.cartProducts.isEmpty) {
            this.products = []; // No products to display
          } else {
            this.products = result.cartProducts; // Set valid products
          }
          // Check for quantity adjustments and notify user
          for (var product in result.cartProducts) {
            int originalQty =
                product.originalQuantity ?? 0; // Default to 0 if null
            adebug(
              "original :${product.originalQuantity} , produduct: ${product.quantity}",
              tag: "yash",
            );
            if (product.quantity < originalQty) {
              // AjugnuFlushbar.showWarning(
              //     context,
              //     //"Quantity of ${product.product.productName} reduced from ${originalQty} to ${product.quantity} due to limited stock.",
              //     "Only ${product.quantity} units of ${product.product.productName} are in stock,"
              //         " but you selected $originalQty. \nPlease adjust the quantity to proceed with checkout."
              // );
              AjugnuFlushbar.showDialogs(
                context,
                title: "Stock Limit Reached",
                message:
                    "Oops! A few products in your cart have limited stock. Kindly check the quantities before continuing ...",
              );
              adebug(
                "Only ${product.quantity} units of ${product.product.productName} are in stock, "
                "but you selected $originalQty. \nPlease adjust the quantity to proceed with checkout.",
                tag: "Stock Issue",
              );

              isProductsQuantity = false;
              return;
            } else {
              isProductsQuantity = true;
            }
          }
          adebug("above: for excluded", tag: "yashhiiiii");
          // Notify user about excluded products
          for (var excluded in result.excludedProducts) {
            adebug("in exclude for loop: ", tag: "yashhiiiiiii");
            String productName = excluded['name'];
            String reason = excluded['reason'];
            adebug("resoun: $reason", tag: "yashhiiiiii");
            if (reason == "inactive") {
              adebug("call inactive: ", tag: "yashhi");

              AjugnuFlushbar.showDialogs(
                context,
                title: "Removed",
                message:
                    "$productName is no longer active and has been removed from your cart.",
              );
            } else if (reason == "deleted") {
              AjugnuFlushbar.showDialogs(
                context,
                title: "Warning",
                message:
                    "$productName has been deleted and removed from your cart.",
              );
            } else if (reason == "out of stock") {
              AjugnuFlushbar.showDialogs(
                context,
                title: "Removed",
                message:
                    "$productName is out of stock and has been removed from your cart.",
              );
            }
          }
        });
      },
      onError: (error) {
        setState(() {
          this.products = []; // Clear products on error
        });
        CommonWidgets.removeProgress();
        if (error.toString().contains("No valid items found in cart")) {
          adebug("No valid items found in cart", tag: "onError");
        } else {
          AjugnuFlushbar.showError(
            context,
            error.toString(),
          ); // Show error message
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    addressForm.addressController.dispose();
    addressForm.remarkController.dispose();
    addressForm.mobileNumberController.dispose();
    addressForm.nameController.dispose();
    // addressForm.postalCodeController.dispose();
  }

  Future<void> onPaymentSuccess(PaymentSuccessResponse response) async {
    // Future.delayed(const Duration(milliseconds: 10), () {
    //   CommonWidgets.showProgress();
    //   adebug(response,tag: "onPaymentSuccess");
    //   checkoutAndPay(addTransaction: true, paymentResponse: response,totalAmountValue: 0);
    // });
    CommonWidgets.showProgress();
    try {
      adebug(
        "Payment success triggered: ${response.paymentId}",
        tag: "yash razorpay",
      );

      final captureResponse = await RazorpayManager().capture(
        response.paymentId!,
        totalAmount * 100,
      );
      adebug(
        "Payment captured successfully , Response: $captureResponse",
        tag: "yash razorpay",
      );

      checkoutAndPay(
        addTransaction: true,
        paymentResponse: response,
        totalAmountValue: 0,
      );
    } catch (e) {
      CommonWidgets.removeProgress();
      adebug("Capture failed: $e", tag: "yash razorpay");
      // if (e.toString().contains("already captured")) {
      //   adebug("Payment already captured, proceeding with checkout",
      //       tag: "yash razorpay");
      //   await checkoutAndPay(addTransaction: true,
      //       paymentResponse: response,
      //       totalAmountValue: 0);
      // } else {
      AjugnuFlushbar.showError(
        getAjungnuGlobalContext(),
        'Payment capture failed: $e. Your amount will be refunded if deducted.',
      );
      //     }
    } finally {
      CommonWidgets.removeProgress();
    }
  }

  void onPaymentError(PaymentFailureResponse response) {
    //   adebug(response,tag: "onPaymentError");
    //   Future.delayed(
    //       const Duration(milliseconds: 10),
    //       () => AjugnuFlushbar.showError(getAjungnuGlobalContext(),
    //           response.message ?? 'Something went wrong.'));
    // }
    adebug(
      "Payment error: ${response.code} - ${response.message}",
      tag: "razorpay",
    );
    String errorMessage = response.message ?? 'Payment failed.';
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      errorMessage = 'Payment was cancelled by you.';
    } else if (response.message?.contains("timeout") == true) {
      errorMessage = 'Payment timed out. Please try again.';
    }
    AjugnuFlushbar.showError(getAjungnuGlobalContext(), errorMessage);
    CommonWidgets.removeProgress();
  }

  void onHandleExternalWallet(ExternalWalletResponse response) {
    //   adebug(response,tag: "onHandleExternalWallet");
    //   Future.delayed(
    //       const Duration(milliseconds: 10),
    //       () => AjugnuFlushbar.showError(
    //           getAjungnuGlobalContext(), 'Can not Handle External Wallet.'));
    // }
    adebug("External wallet: ${response.walletName}", tag: "razorpay");
    AjugnuFlushbar.showInstruction(
      getAjungnuGlobalContext(),
      'Payment via ${response.walletName} was initiated but not completed.',
    );
    CommonWidgets.removeProgress();
  }

  Future<void> checkoutAndPay({
    double totalAmountValue = 0.0,
    bool addTransaction = false,
    PaymentSuccessResponse? paymentResponse,
  }) async {
    adebug("Total amount:$totalAmountValue", tag: "checkoutAndPay");

    if (totalAmountValue > 0) {
      adebug("in if of if : $isProductsQuantity", tag: "isProductsQuantity");

      adebug("checkout call", tag: "if ");
      RazorpayManager().pay(totalAmountValue);
    } else {
      adebug(
        "in else of iner if : $isProductsQuantity",
        tag: "isProductsQuantity",
      );

      try {
        // Extract user input from form fields
        final String name = addressForm.nameController.text.trim();
        final String address = addressForm.addressController.text.trim();
        final String remark = addressForm.remarkController.text.trim();
        final String phone = addressForm.mobileNumberController.text.trim();

        // Proceed with checkout
        final String orderID = await CartRepository().checkout(
          name,
          address,
          remark,
          postalCode,
          phone,
          _paymentMethod,
        );

        // Handle transaction addition if required
        if (addTransaction && paymentResponse != null) {
          final response = await makeHttpPostRequest(
            endpoint: "/api/transaction/addTransaction",
            bodyJson: jsonEncode({
              "order_id": orderID,
              "payment_status": "success",
              "total_amount": totalAmount.toInt(),
              "payment_method": "online",
              "status": "order",
              "payment_id": paymentResponse.paymentId ?? "",
              "user_name": AjugnuAuth().getUser()?.fullName,
            }),
            authorization: AjugnuAuth().getUser()?.token ?? '',
          );

          if (response.statusCode != 201) {
            throw response.responseBody["message"] ??
                response.responseBody["error"] ??
                response.responseBody["msg"] ??
                'An error occurred. (Response code: ${response.statusCode})';
          }
        }
        // adebug("payment response: $paymentResponse , paymentid: ${paymentResponse?.paymentId!}, total amount: ${totalAmount*100}",tag: "yash cejdjf");
        //               // Capture payment if applicable
        //               if (paymentResponse != null) {
        //                 try {
        //                   adebug("in try block",tag: "yash try");
        //                   await RazorpayManager().capture(
        //                     paymentResponse.paymentId!,
        //                     totalAmount * 100,
        //                   );
        //                 } catch (e) {
        //                   adebug(" Payment failed, your amount will be refunded $e",tag: "Yash catch");
        //                   throw "Payment failed, your amount wi"
        //                       "ll be refunded.";
        //                 }
        //               }

        // Final cleanup and navigation
        CommonWidgets.removeProgress();
        CartRepository().cartProducts = null;
        widget.onExitCallbacks?.call();
        AjugnuNavigations.orderPlacedScreen();
        CommonWidgets.removeProgress();
      } catch (error) {
        CommonWidgets.removeProgress();
        AjugnuFlushbar.showError(
          getAjungnuGlobalContext(),
          "${error.toString()}.${paymentResponse == null ? '' : ' Your payment will be refunded if deducted.'}",
        );
        adebug(
          "Your payment will be refunded if deducted $error",
          tag: "catch 2",
        );
      } finally {
        CommonWidgets.removeProgress();
      }
    }
    CommonWidgets.removeProgress();
  }

  @override
  Widget build(BuildContext context) {
    var prices =
        products != null
            ? products
                ?.map((prod) => prod.product.price * prod.originalQuantity!)
                .toList()
            : <int>[];
    totalAmount =
        prices!.isNotEmpty ? prices.reduce((a, b) => a + b).toDouble() : 0.0;

    return PopScope(
      onPopInvoked: (didPop) {
        if (widget.onExitCallbacks != null) {
          widget.onExitCallbacks!();
        }
      },
      canPop: false,
      child: Scaffold(
        backgroundColor: AjugnuTheme.appColorScheme.onPrimary,
        appBar: CommonWidgets.appbar('My Cart', showBackButton: false),
        body: SingleChildScrollView(
          child:
              products == null
                  ? Column(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children:
                            [
                                  AjugnuProduct.dummy(),
                                  AjugnuProduct.dummy(),
                                  AjugnuProduct.dummy(),
                                  AjugnuProduct.dummy(),
                                ]
                                .map<Widget>(
                                  (product) => Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 8,
                                    ),
                                    child: Column(
                                      children: [
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(
                                            8.0,
                                          ).copyWith(bottom: 0),
                                          child: Row(
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey
                                                    .withOpacity(0.3),
                                                highlightColor: Colors.white,
                                                child: const Card(
                                                  margin: EdgeInsets.all(8),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: SizedBox(
                                                    height: 70,
                                                    width: 70,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey
                                                        .withOpacity(0.3),
                                                    highlightColor:
                                                        Colors.white,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                            1.0,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2,
                                                            ),
                                                      ),
                                                      child: CommonWidgets.text(
                                                        'Product Name',
                                                        textColor: Colors.green,
                                                        fontSize: 17,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey
                                                        .withOpacity(0.3),
                                                    highlightColor:
                                                        Colors.white,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                            1.0,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2,
                                                            ),
                                                      ),
                                                      child: CommonWidgets.text(
                                                        'size: medium',
                                                        textColor:
                                                            Colors
                                                                .grey
                                                                .shade500,
                                                        fontSize: 13,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                        fontFamily: 'Poly',
                                                      ),
                                                    ),
                                                  ),
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey
                                                        .withOpacity(0.3),
                                                    highlightColor:
                                                        Colors.white,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                            1.0,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2,
                                                            ),
                                                      ),
                                                      child: CommonWidgets.text(
                                                        'price: 129',
                                                        textColor:
                                                            Colors
                                                                .grey
                                                                .shade500,
                                                        fontSize: 13,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                        fontFamily: 'Poly',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey
                                                    .withOpacity(0.3),
                                                highlightColor: Colors.white,
                                                child: Card(
                                                  color: Colors.black,
                                                  margin: EdgeInsets.only(
                                                    left: 1,
                                                  ),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    side: const BorderSide(
                                                      color: Color.fromARGB(
                                                        255,
                                                        121,
                                                        255,
                                                        217,
                                                      ),
                                                    ),
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                  child: Row(
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 6,
                                                              horizontal: 8,
                                                            ),
                                                        child: Icon(
                                                          CupertinoIcons.minus,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 6,
                                                              horizontal: 4,
                                                            ),
                                                        child:
                                                            CommonWidgets.text(
                                                              '0',
                                                              textColor:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 6,
                                                              horizontal: 8,
                                                            ),
                                                        child: Icon(
                                                          CupertinoIcons.add,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                            ],
                                          ),
                                        ),
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey.withOpacity(
                                            0.3,
                                          ),
                                          highlightColor: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: IconButton(
                                                icon: Container(
                                                  margin: const EdgeInsets.all(
                                                    1.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                  child: CommonWidgets.text(
                                                    'delete',
                                                    textColor: Colors.grey,
                                                    fontFamily: 'Poly',
                                                  ),
                                                ),
                                                onPressed: () {},
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 38,
                          vertical: 12,
                        ),
                        title: Shimmer.fromColors(
                          baseColor: Colors.grey.withOpacity(0.3),
                          highlightColor: Colors.white,
                          child: Container(
                            margin: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: CommonWidgets.text(
                              'Total:',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              fontFamily: 'Poly',
                            ),
                          ),
                        ),
                        trailing: Shimmer.fromColors(
                          baseColor: Colors.grey.withOpacity(0.3),
                          highlightColor: Colors.white,
                          child: Container(
                            margin: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: CommonWidgets.text(
                              '₹299',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poly',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : products?.isEmpty == true
                  ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Center(
                      child: Card(
                        elevation: 0,
                        color: AjugnuTheme.appColorScheme.surface,
                        margin: EdgeInsets.symmetric(horizontal: 18),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1,
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/shopping_cart.png',
                                height: MediaQuery.of(context).size.width * 0.3,
                                width: MediaQuery.of(context).size.width * 0.3,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: CommonWidgets.text(
                                  'You do not have any product added in your cart.',
                                  alignment: TextAlign.center,
                                  textColor: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder:
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: Column(
                                children: [
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      8.0,
                                    ).copyWith(bottom: 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              (products![index]
                                                          .originalQuantity! <=
                                                      products![index].quantity)
                                                  ? Colors.white
                                                  : Colors.red,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Card(
                                            margin: EdgeInsets.all(8),
                                            clipBehavior: Clip.hardEdge,
                                            child: CachedNetworkImage(
                                              height: 70,
                                              width: 70,
                                              imageUrl:
                                                  products![index]
                                                      .product
                                                      .productImages
                                                      .firstOrNull ??
                                                  '',
                                              placeholderFadeInDuration:
                                                  Duration.zero,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, error) =>
                                                      Shimmer.fromColors(
                                                        child: Container(
                                                          color: Colors.black12,
                                                        ),
                                                        baseColor: Colors.grey
                                                            .withOpacity(0.3),
                                                        highlightColor:
                                                            Colors.white,
                                                      ),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Container(
                                                    color: Colors.black12,
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CommonWidgets.text(
                                                  products![index]
                                                      .product
                                                      .productName,
                                                  textColor: Colors.green,
                                                  fontSize: 17,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                products![index]
                                                                .product
                                                                .productSize !=
                                                            "Unknown" ||
                                                        products![index]
                                                                .product
                                                                .toolFertilizerSize !=
                                                            "Unknown"
                                                    ? Text.rich(
                                                      TextSpan(
                                                        text: 'Size: ',
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade500,
                                                          fontSize: 13,
                                                          fontFamily: 'Poly',
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                products![index]
                                                                            .product
                                                                            .toolFertilizerSize ==
                                                                        "Unknown"
                                                                    ? products![index]
                                                                        .product
                                                                        .productSize
                                                                    : products![index]
                                                                        .product
                                                                        .toolFertilizerSize,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Poly',
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    : Text.rich(
                                                      TextSpan(
                                                        text: 'Category: ',
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade500,
                                                          fontSize: 13,
                                                          fontFamily: 'Poly',
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                products![index]
                                                                    .product
                                                                    .categoryName,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Poly',
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                Text.rich(
                                                  TextSpan(
                                                    text: 'Price: ',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 13,
                                                      fontFamily: 'Poly',
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            "₹${products![index].product.price}",
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontFamily: 'Poly',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Card(
                                            color: Colors.black,
                                            margin: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: BorderSide(
                                                color:
                                                    (products![index]
                                                                .originalQuantity! <=
                                                            products![index]
                                                                .quantity)
                                                        ? Color.fromARGB(
                                                          255,
                                                          121,
                                                          255,
                                                          217,
                                                        )
                                                        : Colors.red,
                                                width: 1.8,
                                              ),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if (products != null &&
                                                        index <
                                                            products!.length) {
                                                      if (products![index]
                                                              .originalQuantity! >
                                                          1) {
                                                        CommonWidgets.showProgress();
                                                        CartRepository()
                                                            .cartProductQuantityIncrementDecrement(
                                                              products![index]
                                                                  .product
                                                                  .id,
                                                              false,
                                                            )
                                                            .then(
                                                              (v) async {
                                                                await fetchCartProducts();
                                                                ProductChangeListeners.broadcastChanges(
                                                                  AjugnuProduct(
                                                                    id:
                                                                        products![index]
                                                                            .idd,
                                                                    weight:
                                                                        '0kg',
                                                                    productName:
                                                                        'productName',
                                                                    averageRating:
                                                                        0,
                                                                    ratingCount:
                                                                        0,
                                                                    productImages:
                                                                        [],
                                                                    localName:
                                                                        'localName',
                                                                    otherName:
                                                                        'otherName',
                                                                    categoryId:
                                                                        'categoryId',
                                                                    price: 0,
                                                                    quantity: 0,
                                                                    productType:
                                                                        'productType',
                                                                    productSize:
                                                                        'productSize',
                                                                    productRole:
                                                                        'productRole',
                                                                    description:
                                                                        'description',
                                                                    supplierId:
                                                                        'supplierId',
                                                                    createdAt:
                                                                        DateTime.now(),
                                                                    updatedAt:
                                                                        DateTime.now(),
                                                                    isApproved:
                                                                        true,
                                                                    isFavourite:
                                                                        false,
                                                                    isRated:
                                                                        false,
                                                                  ),
                                                                  completeProduct:
                                                                      false,
                                                                );
                                                                CommonWidgets.removeProgress();
                                                                setState(() {
                                                                  // products![
                                                                  //         index]
                                                                  //     .quantity--;
                                                                  products![index]
                                                                          .originalQuantity =
                                                                      (products![index]
                                                                              .originalQuantity ??
                                                                          0) -
                                                                      1;
                                                                });
                                                              },
                                                              onError: (error) {
                                                                CommonWidgets.removeProgress();
                                                                AjugnuFlushbar.showError(
                                                                  context,
                                                                  error
                                                                      .toString(),
                                                                );
                                                              },
                                                            );
                                                      } else {
                                                        showDialog<void>(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          // user must tap button to dismiss
                                                          builder: (
                                                            BuildContext
                                                            context,
                                                          ) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                'Remove Product',
                                                              ),
                                                              content: const Text(
                                                                'Do you want to remove this product from cart?',
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                        'Cancel',
                                                                      ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                        'Remove',
                                                                      ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                    CommonWidgets.showProgress();
                                                                    CartRepository()
                                                                        .removeFromCart(
                                                                          products![index]
                                                                              .product
                                                                              .id,
                                                                        )
                                                                        .then(
                                                                          (v) {
                                                                            CommonWidgets.removeProgress();
                                                                            ProductChangeListeners.broadcastChanges(
                                                                              AjugnuProduct(
                                                                                id:
                                                                                    products![index].idd,
                                                                                weight:
                                                                                    '0kg',
                                                                                productName:
                                                                                    'productName',
                                                                                averageRating:
                                                                                    0,
                                                                                ratingCount:
                                                                                    0,
                                                                                productImages:
                                                                                    [],
                                                                                localName:
                                                                                    'localName',
                                                                                otherName:
                                                                                    'otherName',
                                                                                categoryId:
                                                                                    'categoryId',
                                                                                price:
                                                                                    0,
                                                                                quantity:
                                                                                    0,
                                                                                productType:
                                                                                    'productType',
                                                                                productSize:
                                                                                    'productSize',
                                                                                productRole:
                                                                                    'productRole',
                                                                                description:
                                                                                    'description',
                                                                                supplierId:
                                                                                    'supplierId',
                                                                                createdAt:
                                                                                    DateTime.now(),
                                                                                updatedAt:
                                                                                    DateTime.now(),
                                                                                isApproved:
                                                                                    true,
                                                                                isFavourite:
                                                                                    false,
                                                                                isRated:
                                                                                    false,
                                                                              ),
                                                                              completeProduct:
                                                                                  false,
                                                                            );
                                                                            CommonWidgets.removeProgress();
                                                                            setState(() {
                                                                              products!.removeAt(
                                                                                index,
                                                                              );
                                                                            });
                                                                            AjugnuFlushbar.showSuccess(
                                                                              getAjungnuGlobalContext(),
                                                                              'Product removed from your cart',
                                                                            );
                                                                          },
                                                                          onError: (
                                                                            error,
                                                                          ) {
                                                                            CommonWidgets.removeProgress();
                                                                            AjugnuFlushbar.showError(
                                                                              getAjungnuGlobalContext(),
                                                                              error.toString(),
                                                                            );
                                                                          },
                                                                        );
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 6,
                                                          horizontal: 8,
                                                        ),
                                                    child: Icon(
                                                      CupertinoIcons.minus,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 4,
                                                      ),
                                                  child: CommonWidgets.text(
                                                    products![index]
                                                        .originalQuantity
                                                        .toString(),
                                                    textColor: Colors.white,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (products != null &&
                                                        index <
                                                            products!.length) {
                                                      CommonWidgets.showProgress();
                                                      CartRepository()
                                                          .cartProductQuantityIncrementDecrement(
                                                            products![index]
                                                                .product
                                                                .id,
                                                            true,
                                                          )
                                                          .then(
                                                            (v) async {
                                                              await fetchCartProducts();
                                                              ProductChangeListeners.broadcastChanges(
                                                                AjugnuProduct(
                                                                  id:
                                                                      products![index]
                                                                          .idd,
                                                                  weight: '0kg',
                                                                  productName:
                                                                      'productName',
                                                                  averageRating:
                                                                      0,
                                                                  ratingCount:
                                                                      0,
                                                                  productImages:
                                                                      [],
                                                                  localName:
                                                                      'localName',
                                                                  otherName:
                                                                      'otherName',
                                                                  categoryId:
                                                                      'categoryId',
                                                                  price: 0,
                                                                  quantity: 0,
                                                                  productType:
                                                                      'productType',
                                                                  productSize:
                                                                      'productSize',
                                                                  productRole:
                                                                      'productRole',
                                                                  description:
                                                                      'description',
                                                                  supplierId:
                                                                      'supplierId',
                                                                  createdAt:
                                                                      DateTime.now(),
                                                                  updatedAt:
                                                                      DateTime.now(),
                                                                  isApproved:
                                                                      true,
                                                                  isFavourite:
                                                                      false,
                                                                  isRated:
                                                                      false,
                                                                ),
                                                                completeProduct:
                                                                    false,
                                                              );
                                                              CommonWidgets.removeProgress();
                                                              setState(() {
                                                                // products![index]
                                                                //     .quantity++;

                                                                products![index]
                                                                        .originalQuantity =
                                                                    (products![index]
                                                                            .originalQuantity ??
                                                                        0) +
                                                                    1;
                                                                // fetchCartProducts()
                                                              });
                                                            },
                                                            onError: (error) {
                                                              CommonWidgets.removeProgress();
                                                              setState(() {});
                                                              AjugnuFlushbar.showError(
                                                                context,
                                                                error
                                                                    .toString(),
                                                              );
                                                            },
                                                          );
                                                    }
                                                  },
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 6,
                                                          horizontal: 8,
                                                        ),
                                                    child: Icon(
                                                      CupertinoIcons.add,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!(products![index]
                                              .originalQuantity! <=
                                          products![index].quantity))
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 20,
                                          ),
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Max Stock : ',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 13,
                                                fontFamily: 'Poly',
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "${products![index].quantity}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontFamily: 'Poly',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: CommonWidgets.text(
                                          'delete',
                                          textColor: Colors.grey,
                                          fontFamily: 'Poly',
                                        ),
                                        onPressed: () {
                                          if (products != null &&
                                              index < products!.length) {
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: false,
                                              // user must tap button to dismiss
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Remove Product',
                                                  ),
                                                  content: const Text(
                                                    'Do you want to remove this product from cart?',
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text(
                                                        'Remove',
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        CommonWidgets.showProgress();
                                                        CartRepository()
                                                            .removeFromCart(
                                                              products![index]
                                                                  .product
                                                                  .id,
                                                            )
                                                            .then(
                                                              (v) {
                                                                ProductChangeListeners.broadcastChanges(
                                                                  AjugnuProduct(
                                                                    id:
                                                                        products![index]
                                                                            .idd,
                                                                    weight: '0kg',
                                                                    productName: 'productName',
                                                                    averageRating: 0,
                                                                    ratingCount: 0,
                                                                    productImages: [],
                                                                    localName: 'localName',
                                                                    otherName: 'otherName',
                                                                    categoryId: 'categoryId',
                                                                    price: 0,
                                                                    quantity: 0,
                                                                    productType: 'productType',
                                                                    productSize: 'productSize',
                                                                    productRole: 'productRole',
                                                                    description: 'description',
                                                                    supplierId: 'supplierId',
                                                                    createdAt: DateTime.now(),
                                                                    updatedAt: DateTime.now(),
                                                                    isApproved: true,
                                                                    isFavourite: false,
                                                                    isRated: false,
                                                                  ),
                                                                  completeProduct: false,
                                                                );
                                                                CommonWidgets.removeProgress();
                                                                setState(() {
                                                                  products!.removeAt(index,);
                                                                });
                                                                AjugnuFlushbar.showSuccess(
                                                                  getAjungnuGlobalContext(),
                                                                  'Product removed from your cart',
                                                                );
                                                              },
                                                              onError: (error) {
                                                                CommonWidgets.removeProgress();
                                                                AjugnuFlushbar.showError(
                                                                  getAjungnuGlobalContext(),
                                                                  error.toString(),
                                                                );
                                                              },
                                                            );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                            ),
                        itemCount: products!.length,
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 38,
                          vertical: 12,
                        ),
                        title: CommonWidgets.text(
                          'Total:',
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          fontFamily: 'Poly',
                        ),
                        trailing: CommonWidgets.text(
                          '₹${totalAmount}',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poly',
                        ),
                      ),
                      addressForm,
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xff040A05),
                                border: Border.all(color: Color(0xffABFFE7)),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 8,
                                right:
                                    MediaQuery.of(context).size.width * 0.095,
                                left: MediaQuery.of(context).size.width * 0.095,
                              ),
                              child: ListTile(
                                style: ListTileStyle.list,
                                title: CommonWidgets.text(
                                  'COD',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  fontFamily: "Aclonica",
                                  textColor: Colors.white,
                                ),
                                leading: Radio<String>(
                                  activeColor: Colors.white,
                                  fillColor: new WidgetStatePropertyAll(
                                    Color(0xffffffff),
                                  ),
                                  value: 'COD',
                                  groupValue: _paymentMethod,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _paymentMethod = value ?? '';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xffABFFE7)),
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xff040A05),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 8,
                                right:
                                    MediaQuery.of(context).size.width * 0.095,
                                left: MediaQuery.of(context).size.width * 0.095,
                              ),
                              child: ListTile(
                                horizontalTitleGap: 18,
                                title: CommonWidgets.text(
                                  'Online',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  fontFamily: "Aclonica",
                                  textColor: Colors.white,
                                ),
                                leading: Radio<String>(
                                  fillColor: new WidgetStatePropertyAll(
                                    Color(0xffffffff),
                                  ),
                                  value: 'Online',
                                  groupValue: _paymentMethod,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _paymentMethod = value ?? '';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                          onPressed: (){},
                          child: Row(
                            children: [
                              Image.asset("assets/icons/locationIcon.png"),
                              Text("Add Shipping Address")
                            ],
                          )
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 30,
                            bottom: 50,
                            right: MediaQuery.of(context).size.width * 0.095,
                            left: MediaQuery.of(context).size.width * 0.095,
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              elevation: const WidgetStatePropertyAll<double>(
                                0,
                              ),
                              backgroundColor:
                                  const WidgetStatePropertyAll<Color>(
                                    Color(0xff040A05),
                                  ),
                              side: const WidgetStatePropertyAll<BorderSide>(
                                BorderSide(color: Color(0xffABFFE7)),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              CommonWidgets.showProgress();
                              await fetchCartProducts().then((_) async {
                                try {
                                  String address =
                                      addressForm.addressController.text.trim();
                                  if (address.isNotEmpty) {
                                    String remark =
                                        addressForm.remarkController.text
                                            .trim();
                                    if (remark.isNotEmpty) {
                                      var name =
                                          addressForm.nameController.text
                                              .trim();
                                      var nameError =
                                          FormValidators.isValidFullname(name);
                                      if (nameError == null) {
                                        var mobileNumber = addressForm.mobileNumberController.text.trim().replaceAll("+91", '');
                                        var mobileNumberError =
                                            FormValidators.isValidIndianPhone(
                                              mobileNumber,
                                            );
                                        if (mobileNumberError == null) {
                                          // Get postal code from address
                                          postalCode = '';
                                          try {
                                            var location =
                                                await locationFromAddress(
                                                  address,
                                                );
                                            adebug(
                                              location.first.toJson(),
                                              tag: 'Getting location',
                                            );
                                            // adebug(await placemarkFromCoordinates(location.first.latitude, location.first.longitude), tag: 'Getting location');
                                            if (location.isNotEmpty) {
                                              postalCode =
                                                  (await placemarkFromCoordinates(
                                                    location.firstOrNull?.latitude ?? 0,
                                                    location.firstOrNull?.longitude ?? 0,
                                                  )).firstOrNull?.postalCode ?? '';
                                              // addressForm.postalCodeController.text = postalCode;
                                            }
                                          } catch (error) {
                                            CommonWidgets.removeProgress();
                                            adebug(error);
                                          }

                                          if (postalCode.isNotEmpty) {
                                            bool areAllProductsActive = products != null && products!.isNotEmpty && products!.every(
                                                  (cartProduct) =>
                                                      cartProduct.product.isApproved,
                                                );
                                            adebug(
                                              "$areAllProductsActive",
                                              tag: "areAllProductsActive",
                                            );
                                            bool areAllProductsNotDeleted = products != null && products!.isNotEmpty && products!.every(
                                                  (cartProduct) =>
                                                      cartProduct.product.deleteStatus ?? false,
                                                );
                                            adebug(
                                              "$areAllProductsNotDeleted",
                                              tag: 'areAllProductsNotDeleted',
                                            );

                                            if (!areAllProductsActive) {
                                              // If any product is inactive, show an error and stop the payment process
                                              CommonWidgets.removeProgress();
                                              AjugnuFlushbar.showDialogs(
                                                context,
                                                title: "Removed",
                                                message: 'Remove from cart,  Some products are inactive, Cannot proceed with payment.',
                                              );
                                              return; // Exit the onPressed callback
                                            }
                                            if (!areAllProductsNotDeleted) {
                                              // If any product is inactive, show an error and stop the payment process
                                              CommonWidgets.removeProgress();
                                              AjugnuFlushbar.showDialogs(context, title: "Removed",
                                                message: 'Remove from cart, Some products are deleted,Cannot proceed with payment..',
                                              );
                                              return; // Exit the onPressed callback
                                            }
                                            adebug(
                                              "value:  $isProductsQuantity",
                                              tag: "isProductsQuantity",
                                            );

                                            if (!isProductsQuantity) {
                                              adebug("yashfkdsjfsd ");
                                              CommonWidgets.removeProgress();
                                              adebug("jdfkjsdakfd");
                                              return;
                                            }
                                            adebug(
                                              "where:  $isProductsQuantity",
                                              tag: "isProductsQuantity",
                                            );
                                            //await GoogleApis().isPostalCodeValid(postalCode)) {
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            if (_paymentMethod.toLowerCase() == 'cod') {
                                              CommonWidgets.removeProgress();
                                              checkoutAndPay();
                                            } else {
                                              CommonWidgets.removeProgress();
                                              checkoutAndPay(
                                                totalAmountValue: totalAmount,
                                              );
                                            }
                                            CommonWidgets.removeProgress();
                                          } else {
                                            CommonWidgets.removeProgress();
                                            AjugnuFlushbar.showError(
                                              context,
                                              'Please enter a valid address.',
                                            );
                                          }
                                        } else {
                                          CommonWidgets.removeProgress();
                                          AjugnuFlushbar.showError(
                                            context,
                                            mobileNumberError,
                                          );
                                        }
                                      } else {
                                        CommonWidgets.removeProgress();
                                        AjugnuFlushbar.showError(
                                          context,
                                          nameError,
                                        );
                                      }
                                    } else {
                                      CommonWidgets.removeProgress();
                                      AjugnuFlushbar.showError(
                                        context,
                                        'Please enter valid remark.',
                                      );
                                    }
                                  } else {
                                    CommonWidgets.removeProgress();
                                    AjugnuFlushbar.showError(
                                      context,
                                      'Please enter valid address.',
                                    );
                                  }
                                } catch (error) {
                                  CommonWidgets.removeProgress();
                                  AjugnuFlushbar.showError(
                                    context,
                                    'Something went wrong',
                                  );
                                } finally {
                                  CommonWidgets.removeProgress();
                                }
                              });
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 26,
                                ),
                                child: CommonWidgets.text(
                                  'Checkout',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  fontFamily: 'Aclonica',
                                  textColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class AddressForm extends StatelessWidget {
  final addressController = TextEditingController();
  final remarkController = TextEditingController();

  // final postalCodeController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final nameController = TextEditingController();

  AddressForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 228, 244, 214),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.00,
            ),
            child: CommonWidgets.text(
              'Shipping Address',
              fontFamily: 'Poly',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              textColor: const Color(0xff8F8585),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CommonWidgets.editbox(
              controller: addressController,
              alignment: TextAlign.start,
              borderSideWidth: 1,
              focusedBorderSideWidth: 1,
              borderColor: Colors.grey,
              borderRadius: 4,
              color: Colors.black,
              fontFamily: 'Poly',
              fontSize: 17,
              label: 'Address',
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CommonWidgets.editbox(
              controller: remarkController,
              maxLength: FormValidators.maxNameChunkLength,
              alignment: TextAlign.start,
              borderSideWidth: 1,
              focusedBorderSideWidth: 1,
              borderColor: Colors.grey,
              borderRadius: 4,
              color: Colors.black,
              fontFamily: 'Poly',
              fontSize: 17,
              label: 'Remark',
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 8.0),
          //   child: CommonWidgets.editbox(controller: postalCodeController, aligment: TextAlign.start, borderSideWidth: 1, focusedBorderSideWidth: 1, borderColor: Colors.grey, borderRadius: 4, color: Colors.black, fontFamily: 'Poly', fontSize: 17, label: 'Pin Code', keyboardType: TextInputType.number),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CommonWidgets.editbox(
              controller: nameController,
              maxLength: FormValidators.maxNameChunkLength,
              alignment: TextAlign.start,
              borderSideWidth: 1,
              focusedBorderSideWidth: 1,
              borderColor: Colors.grey,
              borderRadius: 4,
              color: Colors.black,
              fontFamily: 'Poly',
              fontSize: 17,
              label: 'Name',
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              autofillHints: [AutofillHints.name],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CommonWidgets.editbox(
              controller: mobileNumberController,
              maxLength: FormValidators.maxPhoneLength,
              alignment: TextAlign.start,
              borderSideWidth: 1,
              focusedBorderSideWidth: 1,
              borderColor: Colors.grey,
              borderRadius: 4,
              color: Colors.black,
              fontFamily: 'Poly',
              fontSize: 17,
              label: 'Mobile Number',
              keyboardType: TextInputType.number,
              autofillHints: [AutofillHints.telephoneNumber],
            ),
          ),
        ],
      ),
    );
  }
}
