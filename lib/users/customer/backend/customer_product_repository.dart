import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../../../models/ajugnu_product.dart';
import '../../../models/ajugnu_type.dart';
import '../../../models/pagination_response.dart';
import '../../../models/pagination_result.dart';
import '../../common/backend/ajugnu_auth.dart';
import '../../common/backend/api_handler.dart';

class CustomerProductRepository {
  static final CustomerProductRepository _instance = CustomerProductRepository._internal();
  PaginationResult<List<AjugnuProduct>>? popularProducts;

  bool doesPopularProductsAvailableLocally() {
    return popularProducts != null;
  }

  CustomerProductRepository._internal();

  factory CustomerProductRepository() {
    return _instance;
  }

  Future<bool> favourite(String productID, {removeFromFavourite = false}) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(endpoint: removeFromFavourite ? '/api/user/removeFavoriteProduct' : '/api/user/addFavoriteProduct', authorization: AjugnuAuth().getUser()?.token, bodyJson: jsonEncode({'product_id': productID}));
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    try {
      if ((response.statusCode == 201 || response.statusCode == 200) && response.responseBody['status'] is bool) {
        return response.responseBody['status'];
      } else {
        throw response.responseBody.containsKey('message')
            ? response.responseBody['message']
            : response.responseBody.containsKey('error')
            ? response.responseBody['error']
            : response.responseBody.containsKey('msg')
            ? response.responseBody['msg']
            : 'Something went wrong. (response code: ${response.statusCode})';
      }
    } catch(e) {
      adebug(e);
      throw 'Unexpected error while toggling favourite state of a product: $e';
    }
  }

  Future<List<AjugnuProduct>> searchProducts(String searchQuery) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(endpoint: '/api/user/searchProducts', authorization: AjugnuAuth().getUser()?.token, bodyJson: jsonEncode({'q': searchQuery}));
    } catch (error) {
      rethrow; // Handle error appropriately
    }
    try {
      var searchResults = <AjugnuProduct>[];
      if (response.statusCode == 200 && response.responseBody['products'] is List<dynamic>) {
        var productList = response.responseBody['products'] as List<dynamic>;
        for (var productJson in productList) {
          if (productJson is Map<String, dynamic>) {
            if(productJson['delete_status']==true){
              searchResults.add(AjugnuProduct.fromJson(productJson));

            }
          }
        }
        return searchResults;
      } else {
        return [];
      }
    } catch(e) {
      adebug(e);
      throw 'Unexpected error: $e';
    }
  }

  Future<List<AjugnuProduct>> getFavouriteProducts() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/user/getFavoriteProduct',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow;
    }

    List<AjugnuProduct> products = [];
    if (response.statusCode == 200) {
      var productList = response.responseBody['favorites'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic> && productJson['product_id'] is Map<String, dynamic>) {
          var product = AjugnuProduct.fromJson(productJson['product_id']);
          product.isFavourite = true;
          products.add(product);
        }
      }
      return products;
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

  Future<List<AjugnuProduct>> getProductsByCategoryId(String categoryId) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
        endpoint: '/api/user/getProductByCategory_id',
        authorization: AjugnuAuth().getUser()?.token, bodyJson: jsonEncode({'category_id': categoryId}),
      );
    } catch (error) {
      rethrow;
    }

    List<AjugnuProduct> products = [];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          //var productData=productJson;
          if(productJson['delete_status']==true){
            products.add(AjugnuProduct.fromJson(productJson));
          }

        }
      }
      return products;
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

  Future<List<AjugnuProduct>> getSimilarProducts(String productId) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
        endpoint: '/api/supplier/getSimilarProducts',
        authorization: AjugnuAuth().getUser()?.token,
        bodyJson: jsonEncode({'product_id': productId}),
      );
    } catch (error) {
      rethrow;
    }

    List<AjugnuProduct> products = [];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        products.add(AjugnuProduct.fromJson(productJson));
      }
      return products;
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

  Future<PaginationResponse<List<AjugnuProduct>>> getFertilizerProducts(String supplierID) async {
    late ApiResponse response;
    adebug('here $supplierID');
    try {
      response = await makeHttpPostRequest(
        endpoint: '/api/supplier/getFertilizerBySupplierId',
        authorization: AjugnuAuth().getUser()?.token,
        bodyJson: jsonEncode({
          'supplier_id': supplierID
        }),
      );
    } catch (error) {
      rethrow;
    }

    List<AjugnuProduct> products = [];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          var product = AjugnuProduct.fromJson(productJson);
          products.add(product);
          adebug("checking");
        }
      }
      return PaginationResponse(item: products, currentPage: response.responseBody['page'] ?? 0, totalPages: response.responseBody['totalPages'] ?? 0);
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

  Future<PaginationResponse<List<AjugnuProduct>>> getToolProducts(String supplierID) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
        endpoint: '/api/supplier/getToolsBySupplierId',
        authorization: AjugnuAuth().getUser()?.token,
        bodyJson: jsonEncode({
          'supplier_id': supplierID
        }),
      );
    } catch (error) {
      rethrow;
    }

    List<AjugnuProduct> products = [];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          var product = AjugnuProduct.fromJson(productJson);
          products.add(product);
        }
      }
      return PaginationResponse(item: products, currentPage: response.responseBody['page'] ?? 0, totalPages: response.responseBody['totalPages'] ?? 0);
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

  Future<List<AjugnuType>> getTypes() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/supplier/getProductTypes',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      throw 'Something went wrong';
    }

    List<AjugnuType> products = [];
    if (response.statusCode == 200) {
      var productList = response.responseBody['productTypes'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          var product = AjugnuType(productJson['_id'], productJson['type_name']);
          products.add(product);
        }
      }
      return products;
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

  Future<PaginationResult<List<AjugnuProduct>>> getPopularProducts() async {
    late ApiResponse response;
    try {
      print("hello token ${ AjugnuAuth().getUser()?.token}");
      response = await makeHttpGetRequest(
        endpoint: '/api/user/getPopularProduct',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow;
    }

    var _popularProducts = <AjugnuProduct>[];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          _popularProducts.add(AjugnuProduct.fromJson(productJson));
        }
      }
      popularProducts = PaginationResult(currentPage: 1, totalPages: response.responseBody['cartProductCount'] ?? 0, data: _popularProducts, notificationCounts: response.responseBody['unreadNotificationsCount'] ?? 0);
      //CartCountEmitter.set(popularProducts!.totalPages);
      return popularProducts!;
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


  Future<List<AjugnuProduct>> getRandomProducts() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/user/getProductsRendom',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow;
    }

    List<AjugnuProduct>? randomProducts = <AjugnuProduct>[];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          randomProducts.add(AjugnuProduct.fromJson(productJson));
        }
      }
      return randomProducts;
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



  Future<List<AjugnuProduct>> getFeaturedProducts() async {
    late ApiResponse response;
    try {
      response = await makeHttpGetRequest(
        endpoint: '/api/user/getProductsRendom',
        authorization: AjugnuAuth().getUser()?.token,
      );
    } catch (error) {
      rethrow;
    }

    var featuredProducts = <AjugnuProduct>[];
    if (response.statusCode == 200) {
      var productList = response.responseBody['products'] as List<dynamic>;
      for (var productJson in productList) {
        if (productJson is Map<String, dynamic>) {
          featuredProducts.add(AjugnuProduct.fromJson(productJson));
        }
      }
      return featuredProducts;
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
}