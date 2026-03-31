import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:jkautomed/models/ajugnu_users.dart';
import 'package:jkautomed/users/common/backend/ajugnu_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/ajugnu_order.dart';
import '../../../models/ajugnu_order_notification.dart';
import '../../../models/ajugnu_product.dart';
import '../../../models/pagination_result.dart';
import '../../common/backend/api_handler.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();

  ProductRepository._internal();

  factory ProductRepository() {
    return _instance;
  }

  Future<void> deleteProduct(String productID) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({"product_id": productID}),
          endpoint: '/api/supplier/deleteProduct', authorization: AjugnuAuth().getUser()?.token);
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

  Future<PaginationResult<List<AjugnuProduct>>> getProducts({int currentPage = 0}) async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/supplier/getProducts?page=$currentPage',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow; // Handle error appropriately
    }

    List<AjugnuProduct> products = [];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          if(productJson['delete_status']==true){
            products.add(AjugnuProduct.fromJson(productJson));

          }
        }
      }
      int totalPages = response.responseBody['totalPages'];
      return PaginationResult(currentPage: currentPage, totalPages: totalPages, data: products, notificationCounts: response.responseBody['unreadNotificationsCount'] ?? 0);
    } else {
      throw Exception("Failed to load products. Status code: ${response.statusCode}");
    }
  }

  Future<bool> addProduct(String englishName, String localName, String otherName, String categoryId, String price, String quantity, String productType, String productSize, String description, List<String> images) async {
    var request = http.MultipartRequest('POST', Uri.parse("$ajugnuBaseUrl/api/supplier/addProduct"));
    try {
      for (int i = 0; i < images.length; ++i) {
        request.files.add(await http.MultipartFile.fromPath('product_images', images[i]));
      }

    } catch (error) {
      throw "Invalid image selected.";
    }
    // request.
    request.fields['english_name'] = englishName;
    request.fields['local_name'] = localName;
    request.fields['other_name'] = otherName;
    request.fields['category_id'] = categoryId;
    request.fields['price'] = price;
    request.fields['quantity'] = quantity;
    request.fields['product_type'] = productType.toLowerCase();
    request.fields['product_size'] = productSize.toLowerCase();
    request.fields['description'] = description;
    request.fields['product_role'] = 'supplier';

    adebug(request.files.map((e) => e.field), tag: 'addProduct');

    request.headers['Authorization'] = "Bearer ${AjugnuAuth().getUser()?.token}";

    try {
      var streamedResponse = await request.send().timeout(const Duration(minutes: 1));

      Map<String, dynamic> responseInJson;
      try {
        responseInJson = jsonDecode(await streamedResponse.stream.bytesToString());
      } catch (e) {
        throw streamedResponse.statusCode == 502
            ? 'Server is not working, please wait and try again after some time.'
            : 'Error while decoding response.';
      }

      if (streamedResponse.statusCode == 201 &&
          responseInJson.containsKey('status') &&
          responseInJson['status'] is bool &&
          responseInJson['status']) {
        return true;
      } else {
        String detailedError = responseInJson.containsKey('message')
            ? responseInJson['message']
            : responseInJson.containsKey('error')
            ? responseInJson['error']
            : responseInJson.containsKey('msg')
            ? responseInJson['msg']
            : 'Something went wrong. (response code: ${streamedResponse.statusCode})';
        throw detailedError;
      }
    } on SocketException catch (e) {
      throw 'No internet connection: ${e.message}';
    } on TimeoutException {
      throw 'Request timed out. Please try again later.';
    } catch (e) {
      throw 'Something went wrong: $e';
    }

  }

  Future<bool> updateProduct(String id, String englishName, String localName, String otherName, String categoryId, String price, String quantity, String productType, String productSize, String description, List<String> images) async {
    var request = http.MultipartRequest('POST', Uri.parse("$ajugnuBaseUrl/api/supplier/editProduct"));
    try {
      for (int i = 0; i < images.length; ++i) {
        request.files.add(await http.MultipartFile.fromPath('product_images', images[i]));
      }
    } catch (error) {
      throw "Invalid image selected $error.";
    }
    // request.
    request.fields['product_id'] = id;
    request.fields['english_name'] = englishName;
    request.fields['local_name'] = localName;
    request.fields['other_name'] = otherName;
    request.fields['category_id'] = categoryId;
    request.fields['price'] = price;
    request.fields['quantity'] = quantity;
    request.fields['product_type'] = productType.toLowerCase();
    request.fields['product_size'] = productSize.toLowerCase();
    request.fields['description'] = description;
    request.fields['product_role'] = 'supplier';

    adebug(request.files.map((e) => e.field), tag: 'addProduct');

    request.headers['Authorization'] = "Bearer ${AjugnuAuth().getUser()?.token}";
    var streamedResponse = await request.send().timeout(const Duration(minutes: 1));

    Map<String ,dynamic> responseInJson;
    try {
      responseInJson = jsonDecode(await streamedResponse.stream.bytesToString());
    } catch (e) {
      adebug(e);
      throw streamedResponse.statusCode == 502 ? 'Server is not working, please wait and try again after some time.' :  'Error while decoding response.';
    }

    adebug(responseInJson, tag: 'addProduct');

    if (streamedResponse.statusCode == 200 && responseInJson.containsKey('status') && responseInJson['status'] is bool && responseInJson['status']) {
      return true;
    } else {

      String detailedError = responseInJson.containsKey('message') ? responseInJson['message'] : responseInJson.containsKey('error') ? responseInJson['error'] : responseInJson.containsKey('msg') ? responseInJson['msg'] : 'Something went wrong. (response code: ${streamedResponse.statusCode})';
      throw detailedError;
    }
  }

  Future<AjugnuProduct?> getProductByIDForCustomer(String productID) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(endpoint: '/api/user/getProductDetailByProductId', bodyJson: jsonEncode({
        'product_id': productID
      }), authorization: AjugnuAuth().getUser()?.token);
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    if (response.statusCode == 200) {
      try {
        return AjugnuProduct.fromJson(response.responseBody['product']);
      } catch (error) {
        throw 'Unable to parse product data, please update application.';
      }
    } else {
      throw response.responseBody.containsKey('message') ? response.responseBody['message'] : response.responseBody.containsKey('error') ? response.responseBody['error'] : response.responseBody.containsKey('msg') ? response.responseBody['msg'] : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  Future<List<AjugnuOrder>> getOrders() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/supplier/getOrdersBySupplierId',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    if (response.statusCode == 200) {
      List<AjugnuOrder>? orderNotifications = [];
      var productList = (response.responseBody['orders'] ?? []) as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          orderNotifications.add(AjugnuOrder.fromJson(productJson));
        }
      }
      return orderNotifications;
    } else {
      throw response.responseBody.containsKey('message') ? response.responseBody['message'] : response.responseBody.containsKey('error') ? response.responseBody['error'] : response.responseBody.containsKey('msg') ? response.responseBody['msg'] : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  Future<String> updateOrderStatus(String productID, String orderID, String newStatus) async {
    late ApiResponse response;
    try {
      response = await makeHttpPutRequest(endpoint: '/api/supplier/updateOrderItemStatus', bodyJson: jsonEncode({
        'product_id': productID,
        'order_id': orderID,
        'new_status': newStatus
      }), authorization: AjugnuAuth().getUser()?.token);
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    if (response.statusCode == 200) {
      return 'Order status updated successfully.';
    } else {
      throw response.responseBody.containsKey('message') ? response.responseBody['message'] : response.responseBody.containsKey('error') ? response.responseBody['error'] : response.responseBody.containsKey('msg') ? response.responseBody['msg'] : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }

  Future<List<AjugnuOrderNotification>> getOrderNotifications() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/supplier/getSupplierOrderNotification',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    if (response.statusCode == 200) {
      List<AjugnuOrderNotification>? orderNotifications = [];
      var productList = (response.responseBody['notifications'] ?? []) as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          orderNotifications.add(AjugnuOrderNotification.fromJson(productJson));
        }
      }
      return orderNotifications;
    } else {
      throw response.responseBody.containsKey('message') ? response.responseBody['message'] : response.responseBody.containsKey('error') ? response.responseBody['error'] : response.responseBody.containsKey('msg') ? response.responseBody['msg'] : 'Something went wrong. (response code: ${response.statusCode})';
    }
  }
}

