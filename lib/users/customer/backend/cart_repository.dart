import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../../models/ajugnu_cart_product.dart';
import '../../../models/ajugnu_order.dart';
import '../../../models/ajugnu_order_notification.dart';
import '../../../models/ajugnu_product.dart';
import '../../common/backend/ajugnu_auth.dart';
import '../../common/backend/api_handler.dart';
import '../../common/common_widgets.dart';
import 'cart_count_emitter.dart';

class CartFetchResult {
  final List<AjugnuCartProduct> cartProducts; // Products to display in cart
  final List<Map<String, dynamic>> excludedProducts; // Products excluded with reason

  CartFetchResult({
    required this.cartProducts,
    required this.excludedProducts,
  });
}


class CartRepository {
  static final CartRepository _instance = CartRepository._internal();
  List<AjugnuCartProduct>? cartProducts;
  String? _currentUserId;

  int cartCounts = 0;

  CartRepository._internal();

  factory CartRepository() {
    return _instance;
  }

  Future<void> cartProductQuantityIncrementDecrement(
      String productID, bool increase) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({"product_id": productID, 'quantity': 1}),
          endpoint: increase
              ? '/api/user/increaseCartQuantity'
              : '/api/user/decreaseCartQuantity',
          authorization: AjugnuAuth().getUser()?.token);
    } catch (error) {
      adebug(error.toString());
      rethrow;
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      return Future.value();
    } else {
      throw response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  Future<void> removeFromCart(String productID) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({"product_id": productID}),
          endpoint: '/api/user/removeFromCart',
          authorization: AjugnuAuth().getUser()?.token);
    } catch (error) {
      adebug(error.toString());
      rethrow;
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      CartCountEmitter.accum(-1);
      return Future.value();
    } else {
      throw response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  Future<String> checkout(String name, String address, String remark,
      String pincode, String mobileNumber, String paymentMethod
      ) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({
            "shipping_address": {
              "name": name,
              "address": address,
              "remark": remark,
              "pincode": pincode,
              "mobile_number": mobileNumber,
            },
            "payment_method": paymentMethod.toString().toLowerCase()
          }),
          endpoint: '/api/user/checkout',
          authorization: AjugnuAuth().getUser()?.token);
      adebug("checkout response: ${response.statusCode}, response: ${response.responseBody}");
    } catch (error) {
      adebug(error.toString());
      rethrow;
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      CartCountEmitter.reset();
      return response.responseBody['order'] is Map<String, dynamic>
          ? response.responseBody['order']['_id'] ?? ''
          : '';
    } else {
      throw response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  Future<void> addToCart(String productId) async {
    late ApiResponse response;
    try {
      print("Token Main ${AjugnuAuth().getUser()?.token}");
      print(" product id${productId}");
      print(" product id${productId}");
      response = await makeHttpPostRequest(

          bodyJson: jsonEncode({"product_id": productId, "quantity": 1}),
          endpoint: '/api/user/addToCart',
          authorization: AjugnuAuth().getUser()?.token);
    } catch (error) {
      adebug(error.toString());
      rethrow;
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      CartCountEmitter.accum(1);
      return Future.value();
    } else {
      throw response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  bool doesCartProductsAvailableLocally() {
    final currentUserId=AjugnuAuth().getUser()?.id;
    return cartProducts != null && _currentUserId==currentUserId;
  }
void onLogOut(){
    cartProducts=null;
    _currentUserId=null;
    CartCountEmitter.reset();
}
  // Future<List<AjugnuCartProduct>> getCartProducts() async {
  //   late ApiResponse response;
  //   CartCountEmitter.set(0);
  //   try {
  //     response = await makeHttpGetRequest(
  //       endpoint: '/api/user/getCartProducts',
  //       authorization: AjugnuAuth().getUser()?.token,
  //     );
  //   } catch (error) {
  //     rethrow; // Handle error appropriately
  //   }
  //   if (response.statusCode == 200) {
  //     cartProducts = [];
  //     List<Map<String,dynamic>>excludedProducts=[];
  //     _currentUserId=AjugnuAuth().getUser()?.id;
  //     var productList = response.responseBody['cartItems'] as List<dynamic>;
  //
  //
  //     for (var productJson in productList) {
  //       if (productJson is Map<String, dynamic>) {
  //
  //         var productData = productJson['product_id'];
  //         // if(productData !=null && productData['delete_status']==true){
  //         //   var cartProduct = AjugnuCartProduct(
  //         //       idd: productJson['_id'] ?? '',
  //         //       quantity: productJson['quantity'] ?? 0,
  //         //       product: AjugnuProduct.fromJson(productData),);
  //         //   cartProducts!.add(cartProduct);
  //         // }
  //         if (productData != null) {
  //           // Parse product and apply filtering
  //           var product = AjugnuProduct.fromJson(productData);
  //
  //           bool isValid = product.isApproved == true &&
  //               product.deleteStatus == true && product.quantity >0;
  //           adebug("Product ID: ${product.id},Product name: ${product.productName} isApproved: ${product.isApproved}, deleteStatus: "
  //               "${product.deleteStatus}, Quantity: ${product.quantity} Included: $isValid",tag: "getProductYash");
  //           if (isValid) {
  //             int cartQuantity=productJson['quantity']??0;
  //             int availableStock=product.quantity;
  //             int adjustedQuantity = cartQuantity>availableStock?availableStock:cartQuantity;
  //
  //             var cartProduct = AjugnuCartProduct(
  //               idd: productJson['_id'] ?? '',
  //              // quantity: productJson['quantity'] ?? 0,
  //               quantity: adjustedQuantity,
  //               product: product,
  //             );
  //             cartProducts!.add(cartProduct);
  //           }
  //         }
  //       }
  //     }
  //     adebug("Filtered cart products count: ${cartProducts!.length}",tag:"getProductYash");
  //     CartCountEmitter.set(cartProducts?.length ?? 0);
  //     return cartProducts!;
  //   } else {
  //     throw response.responseBody.containsKey('message')
  //         ? response.responseBody['message']
  //         : response.responseBody.containsKey('error')
  //             ? response.responseBody['error']
  //             : response.responseBody.containsKey('msg')
  //                 ? response.responseBody['msg']
  //                 : 'Something went wrong. (response code: ${response.statusCode})';
  //   }
  // }


  Future<CartFetchResult> getCartProducts() async {
    late ApiResponse response;
    CartCountEmitter.set(0); // Reset cart count
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/user/getCartProducts',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow; // Pass error to caller
    }
    finally{
      CommonWidgets.removeProgress();
    }
    adebug("Yash Response: ${response.statusCode}",tag: "getCartProduct");
    if (response.statusCode == 200) {
      List<AjugnuCartProduct> cartProducts = []; // List for valid products
      List<Map<String, dynamic>> excludedProducts = []; // List for excluded products
      _currentUserId = AjugnuAuth().getUser()?.id;
      var productList = response.responseBody['cartItems'] as List<dynamic>;

      // Loop through each cart item
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          var productData = productJson['product_id'];
          if (productData != null) {
            var product = AjugnuProduct.fromJson(productData);

            // Check if product is valid (active, not deleted, has stock)
            bool isValidProduct = product.isApproved == true &&
                product.deleteStatus == true ; // Changed from true to false (assuming typo in your original code)

              bool isAvailableProduct=  product.quantity > 0;

            adebug(
              "Product ID: ${product.id}, Product name: ${product.productName}, isApproved: ${product.isApproved}, deleteStatus: ${product.deleteStatus}, Quantity: ${product.quantity}, Included: $isAvailableProduct",
              tag: "getProductYash",
            );

            if (isValidProduct && isAvailableProduct) {
              // Get user-selected quantity and available stock
              int originalQuantity = productJson['quantity'] ?? 0;
              int availableStock = product.quantity;
              int adjustedQuantity = originalQuantity > availableStock ? availableStock : originalQuantity;

              // Add valid product to cartProducts with both quantities
              var cartProduct = AjugnuCartProduct(
                idd: productJson['_id'] ?? '',
                originalQuantity: originalQuantity, // NEW: Store original quantity
                quantity: adjustedQuantity, // Adjusted based on stock
                product: product,
              );
              cartProducts.add(cartProduct);
            }else {
              // Track why product was excluded
              String reason = "";
              if (product.isApproved == false) {
                reason = "inactive"; // Product is not approved/active
              } else if (product.deleteStatus == true) {
                reason = "deleted"; // Product is deleted
              } else if (product.quantity <= 0) {
                reason = "out of stock"; // Product has no stock
              }
              excludedProducts.add({
                "name": product.productName,
                "reason": reason,
              });
              try{
                await removeFromCart(product.id);
                adebug("Automatically removed product ${product.productName} from cart due to $reason", tag: "getProductYash");
              } catch (error) {
                CommonWidgets.removeProgress();
                adebug("Failed to remove product ${product.productName} from cart: $error", tag: "getProductYash");
                // Continue processing other products even if removal fails
              }
              finally{
                CommonWidgets.removeProgress();
              }
            }

          }
        }
      }
      adebug("Filtered cart products count: ${cartProducts.length}", tag: "getProductYash");
      adebug("Excluded products: $excludedProducts", tag: "getProductYash");

      CartCountEmitter.set(cartProducts.length);
      return CartFetchResult(
        cartProducts: cartProducts,
        excludedProducts: excludedProducts,
      );
    } else {
      throw response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
          ? response.responseBody['error']
          : response.responseBody.containsKey('msg')
          ? response.responseBody['msg']
          : 'Something went wrong. (response code: ${response.statusCode})';
    }


// Other methods (getOrderNotifications, getOrders, etc.) remain unchanged
}
  Future<List<AjugnuOrderNotification>> getOrderNotifications() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/user/getOrderNotifications',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    if (response.statusCode == 200) {
      List<AjugnuOrderNotification>? orderNotifications = [];
      var productList =
          (response.responseBody['notifications'] ?? []) as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          orderNotifications.add(AjugnuOrderNotification.fromJson(productJson));
        }
      }
      return orderNotifications;
    } else {
      throw response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  Future<List<AjugnuOrder>> getOrders() async {
    // print("Abhi:- orderId : $orderId");
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/user/getUserOrderDetails',
        // endpoint: '/api/user/product/get-product/${orderId}',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    adebug("response: ${response.statusCode}");
    if (response.statusCode == 200) {
      List<AjugnuOrder>? orderNotifications = [];
      var productList =
          (response.responseBody['orders'] ?? []) as List<dynamic>;
      adebug("listorder:${productList.toString()}",tag: "listOrder");
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          orderNotifications.add(AjugnuOrder.fromJson(productJson));
        }
      }
      adebug("${orderNotifications}",tag: "OrderNotification");
      return orderNotifications;
    } else {
      adebug("else call",tag: "Else");
      throw response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }
}
