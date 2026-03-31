import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../models/ajugnu_users.dart';
import '../../users/common/backend/ajugnu_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Modelss/address_model.dart';
import '../Modelss/category_model.dart';
import '../Modelss/notification_model.dart';
import '../Modelss/order_history_model.dart';
import '../Modelss/product_list_model.dart';

class ApiService {
  // static const String baseUrl = "https://api.jkautomed.graphicsvolume.com/api";
  //static const String baseUrl = "https://api.jkautomed.graphicsvolume.com/api";
  // static const String baseUrl = "https://api.jkautomedglobal.in/api";
  static const String baseUrl = "https://api.jkautomedglobal.in/api";

  Future<List<Category>> getAllCategories() async {
    try {
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (user != null && user.token != null && user.token!.isNotEmpty) {
        headers[
          'Authorization'] = 'Bearer ${user.token}';
        print('Bearer ${user.token}');
      }

      final response = await http.get(
        Uri.parse("$baseUrl/category/GetAllCategories"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to fetch categories: $e");
    }
  }

  //      Get product list
  Future<List<Product>> getProductsByCategory({
    required String categoryId,
    required List<String> subcategoryIds,
  }) async
  {
    try {
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (user != null && user.token != null && user.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${user.token}';
      }
      print("Abhi:- get reponse : ${categoryId} subCatery: ${subcategoryIds}");
      final response = await http.post(
        Uri.parse("$baseUrl/user/product/getProductsByCategory"),
        headers: headers,

        body: jsonEncode({
          "categoryId": categoryId,
          "subcategoryIds": subcategoryIds,
        }),
      );
        print("Abhi:- get getProductsByCategory : ${response.statusCode}");
        print("Abhi:- get getProductsByCategory : ${response.body}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          print("Abhi:- get reponse : ${response.statusCode}");
          print("Abhi:- get reponse : ${response.body}");
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['status'] == true) {
            List<dynamic> productsJson = data['products'];
            return productsJson.map((json) => Product.fromJson(json)).toList();
          } else {
            throw Exception("No products found");
          }
        } else {
          throw Exception("Server error: ${response.statusCode}");
        }
      } catch (e) {
        throw Exception("Failed to fetch products: $e");
      }
    }

  // get product by id
// ApiService class ke andar yeh method add kar do

  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      print("Abhi:- get UserId : ${userId}");

      AjugnuUser? user = AjugnuAuth().getUser();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID':userId ?? ''
      };
      if (user != null && user.token != null && user.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${user.token}';
      }

      final response = await http.get(
        Uri.parse("$baseUrl/user/product/get-product/$productId"),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Abhi:- get product id:- ${productId}");
        print("Abhi:- get product detaies:- ${response.body}");
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          return jsonResponse['product']; // sirf product object return kar rahe hain
        } else {
          throw Exception(jsonResponse['message'] ?? "Product not found");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch product: $e");
    }
  }

  // ================== INCREASE CART QUANTITY ==================

  Future<bool> increaseCartQuantity(String productId, int newQuantity) async {
    //Dart is an object-oriented programming language developed by Google. It is used to build applications and is the primary language for the Flutter framework.
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      String? mobileNumber = prefs.getString('mobile');
      String? email = prefs.getString('email');
      String? full_name = prefs.getString('full_name');

      print("userId -> $userId");
      print("productId -> $productId");


      AjugnuUser? user = AjugnuAuth().getUser();
      print("Abhi mobileNumber -> ${user?.mobile} , email: ${user?.email}, fullName: ${user?.fullName}");
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'userID': userId ?? '',
      };


      if (user != null && user.token != null && user.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${user.token}';
      }
      final response = await http.post(
        Uri.parse("$baseUrl/user/increaseCartQuantity"),
        headers: headers,
        body: jsonEncode({
          "product_id": productId,
          "quantity": /*newQuantity*/1,
        }),
      );

      debugPrint("increase cart status: ${response.statusCode}");
      debugPrint("increase cart body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("increaseCart error: $e");
      return false;
    }
  }

   Future<bool> deleteCartitem(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      print("userId -> $userId");
      print("productId -> $productId");

      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'userID': userId ?? '',
      };

      if (user != null && user.token != null && user.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${user.token}';
      }

      final response = await http.post(
        Uri.parse("$baseUrl/user/removeFromCart"),
        headers: headers,
        body: jsonEncode({
          "product_id": productId,
          "quantity": /*newQuantity*/1,
        }),
      );

      debugPrint("deleteCartitem cart status: ${response.statusCode}");
      debugPrint("deleteCartitem cart body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("deleteCartitem error: $e");
      return false;
    }
  }

  Future<bool> decreaseCartQuantity(String productId, int newQuantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.post(
        Uri.parse("$baseUrl/user/decreaseCartQuantity"),
        headers: headers,
        body: jsonEncode({
          "product_id": productId,
          "quantity": /*newQuantity > 0 ? newQuantity :*/ 1,
        }),
      );

      final data = jsonDecode(response.body);
      return data['status'] == true;
    } catch (e) {
      print("decreaseCart error: $e");
      return false;
    }
  }

  //     Add to card
  Future<bool> addToCard(String productId, int newQuantity) async {
    try {
    print("gdfgdfgdh  ${AjugnuAuth().getUser()!.token}");
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      print("Abhi:- add to card Token:- ${user?.token}");

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.post(
        Uri.parse("$baseUrl/user/addToCart"),
        headers: headers,
        body: jsonEncode({
          "product_id": productId,
          "quantity": newQuantity > 0 ? newQuantity : 1,
        }),
      );

      debugPrint("addToCart status: ${response.statusCode}");
      debugPrint("addToCart body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }

      return false;
    } catch (e) {
      print("addToCart error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getCartProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.get(
        Uri.parse("$baseUrl/user/getCartProducts"),
        headers: headers,
      );

      debugPrint("getCart status: ${response.statusCode}");
      debugPrint("getCart body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to get cart: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("getCartProducts error: $e");
      rethrow;
    }
  }
  Future<List<StateModel>> getStates() async {
    try {
      final response = await http.get(
        Uri.parse("https://countriesnow.space/api/v0.1/countries/states"),
        headers: {'Content-Type': 'application/json'},
      );

      print("Abhi:- get response state api ${response.statusCode}");
      print("Abhi:- get response state api ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['error'] == false) {
          // data['data'] ek List hai multiple countries ki
          final List<dynamic> countries = data['data'];

          // India
          final indiaData = countries.firstWhere(
                (country) => (country['name'] as String).toLowerCase() == 'india',
            orElse: () => null,
          );

          if (indiaData != null) {
            final List<dynamic> statesJson = indiaData['states'];
            return statesJson
                .map((s) => StateModel.fromJson(s as Map<String, dynamic>))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print("Error fetching states: $e");
      return [];
    }
  }

  Future<List<CityModel>> getCities(String state) async {
    try {
      final uri = Uri.parse(
        'https://countriesnow.space/api/v0.1/countries/state/cities/q'
            '?country=India&state=$state',
      );

      final response = await http.get(uri);

      print("Cities Status: ${response.statusCode}");
      print("Cities Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['error'] == false) {
          final List cities = data['data'];
          return cities.map((e) => CityModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching cities: $e");
      return [];
    }
  }

  // update address

  Future<bool> updateUserAddress(Map<String, dynamic> addressData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      AjugnuUser? user = AjugnuAuth().getUser();
      final response = await http.put(
        Uri.parse("$baseUrl/user/update-address/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user!.token}', // Agar token chahiye  headers['Authorization'] = 'Bearer ${user!.token}';
        },
        body: jsonEncode(addressData),
      );

      print("Update Address Status: ${response.statusCode}");
      print("Update Address Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      print("Error updating address: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.post(
        Uri.parse("$baseUrl/order/create-order"),
        headers: headers,
        body: jsonEncode(orderData),
      );
      print("Abhi:- create order: $baseUrl/order/create-order");
      debugPrint("Create Order Status: ${response.statusCode}");
      debugPrint("Create Order Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Order creation failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Create Order Error: $e");
      rethrow;
    }
  }
  Future<Map<String, dynamic>> createBackendShiprocketOrder(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.post(
        Uri.parse("$baseUrl/shiprocket/create-order"),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint("Backend Shiprocket Status: ${response.statusCode}");
      debugPrint("Backend Shiprocket Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Abhi:- get error on this: ${response.body}");
        throw Exception("Failed to sync with delivery: ${response.body}");
      }
    } catch (e) {
      debugPrint("Backend Shiprocket Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addTransaction(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transaction/addTransaction'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint("Abhi:- addTransaction status :- ${response.statusCode}");
      debugPrint("Abhi:- addTransaction body :- ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Transaction failed: ${response.body}');
      }
    } catch (e) {
      debugPrint("addTransaction Error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> shipingProductAssign(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    final AjugnuUser? user = AjugnuAuth().getUser();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'userID': userId ?? '',
    };

    if (user?.token?.isNotEmpty == true) {
      headers['Authorization'] = 'Bearer ${user!.token}';
    }

    debugPrint("Assign AWB URL: $baseUrl/shiprocket/assign-awb");
    debugPrint("Assign AWB Payload: $payload");

    final response = await http.post(
      // Uri.parse('$baseUrl/shiprocket/assign-awb'),
      //Uri.parse('https://api.jkautomed.graphicsvolume.com/api/shiprocket/assign-awb'),
      Uri.parse('https://api.jkautomedglobal.in/api/shiprocket/assign-awb'),
      headers: headers,
      body: jsonEncode(payload),
    );

    debugPrint("Assign AWB Status: ${response.statusCode}");
    debugPrint("Assign AWB Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      debugPrint("Abhi:- assign failed ");
      throw Exception('AWB Assign Failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> addToFavorite(dynamic productId) async {
    print("Abhi:- get product id :- $productId");
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.post(
        Uri.parse("$baseUrl/user/addFavoriteProduct"),
        headers: headers,
        body: jsonEncode({
          "product_id": productId
        }),
      );

      debugPrint("Backend add product in favorite Status: ${response.statusCode}");
      debugPrint("Backend add product in favorite Body: ${response.body}");

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {

        return jsonDecode(response.body);
      } else {
        print("Abhi:- add product in favorite get error on this: ${response.body}");
        throw Exception("Failed to sync with delivery: ${response.body}");
      }
    } catch (e) {
      debugPrint("Backend add product in favorite Error: $e");
      rethrow;
    }
  }

  // // Get Favorites
  // static Future<Map<String, dynamic>> getFavoriteProducts() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? userId = prefs.getString('user_id');
  //   AjugnuUser? user = AjugnuAuth().getUser();
  //
  //   try{
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'userID': userId ?? '',
  //     };
  //
  //     if (user?.token?.isNotEmpty == true) {
  //       headers['Authorization'] = 'Bearer ${user!.token}';
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/user/getFavoriteProduct'),
  //       headers: headers,
  //     );
  //
  //     debugPrint("Abhi:- getFavorite status :- ${response.statusCode}");
  //     debugPrint("Abhi:- getFavorite body :- ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       print("Abhi:- get favorite product Exception:  ");
  //       // throw Exception('Failed to load favorites');
  //     return null ;
  //     }
  //   }catch(e){
  //     print("Abhi:- get favorite product Exception: $e");
  //
  //   }
  // }

  static Future<Map<String, dynamic>?> getFavoriteProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    AjugnuUser? user = AjugnuAuth().getUser();

    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user?.token?.isNotEmpty == true) {
          headers['Authorization'] = 'Bearer ${user!.token}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/getFavoriteProduct'),
        headers: headers,
      );

      debugPrint("Abhi:- getFavorite status :- ${response.statusCode}");
      debugPrint("Abhi:- getFavorite body :- ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint("Abhi:- get favorite failed");
        return null;
      }
    } catch (e) {
      debugPrint("Abhi:- get favorite exception :- $e");
      return null;
    }
  }

  // Api_Service.dart mein

  static Future<Map<String, dynamic>> toggleFavorite(String productId) async {
    try {
      print("Abhi:- toggle favraite :- $productId");
      final prefs =  await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
           'Authorization': 'Bearer ${user!.token}',

      };

      // if (user?.token?.isNotEmpty == true) {
      //   headers['Authorization'] = 'Bearer ${user!.token}';
        print("toggle favoritetoken:- ${user!.token}");
      // }

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
        print("toggle favoritetoken:- ${user!.token}");
      }
      final response = await http.post(
        Uri.parse("$baseUrl/user/addFavoriteProduct"),
        headers: headers,
        body: jsonEncode({"product_id": productId}),
      );

      debugPrint("Toggle favorite status: ${response.statusCode}");
      debugPrint("Toggle favorite body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to toggle favorite");
      }
    } catch (e) {
      debugPrint("Toggle favorite error: $e");
      rethrow;
    }
  }

  // Remove Favorite
  static Future<Map<String, dynamic>> removeFavoriteProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    AjugnuUser? user = AjugnuAuth().getUser();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'userID': userId ?? '',
    };

    if (user?.token?.isNotEmpty == true) {
      headers['Authorization'] = 'Bearer ${user!.token}';
    }

    final response = await http.post(
      Uri.parse('$baseUrl/user/removeFavoriteProduct'),
      headers: headers,
      body: jsonEncode({"product_id": productId}),
    );

    debugPrint("Abhi:- removeFavorite status :- ${response.statusCode}");
    debugPrint("Abhi:- removeFavorite body :- ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to remove favorite');
    }
  }

  Future<List<OrderHistory>> orderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'userID': userId ?? '',
      };

      if (user != null && user.token != null && user.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${user.token}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/order/get-orders/$userId'),
        headers: headers,
      );

      debugPrint("get Order history statusCode: ${response.statusCode}");
      debugPrint("get Order history body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true) {
          List<dynamic> ordersJson = jsonResponse['data'];
          // List<dynamic> RordersJson = jsonResponse['data'];
          return ordersJson.map((json) => OrderHistory.fromJson(json)).toList();
        } else {
          // agar status false hai to empty list return kar de
          return [];
        }
      } else {
        // server error bhi silent handle, empty list return
        return [];
      }
    } catch (e) {
      // exception ko screen par print mat kar, bas log me debugPrint
      debugPrint('Order History Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRelatedProducts(
      String categoryId,
      List<String> subcategoryIds,
      String productId,
      ) async
  {
    final prefs = await SharedPreferences.getInstance();
    AjugnuUser? user = AjugnuAuth().getUser();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (user != null && user.token != null && user.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${user.token}';
    }

    print("Abhi:- categoryId:$categoryId, subcategoryId:$subcategoryIds,productId:$productId");

    final response = await http.post(
      Uri.parse('$baseUrl/user/product/getRelatedProducts'),
      headers: headers,
      body: jsonEncode({
        "categoryId": categoryId,
        "subcategoryIds": subcategoryIds,
        "productId": productId,
      }),
    );

    debugPrint("getRelatedProducts statusCode: ${response.statusCode}");
    debugPrint("getRelatedProducts body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load related products');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentProducts() async {
    try {
      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (user != null && user.token != null && user.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${user.token}';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/product/recent-products'),
        // Uri.parse('$baseUrl/user/product'),
        headers: headers,
      );

      debugPrint("recent products status: ${response.statusCode}");
      debugPrint("recent products body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Recent Products Error: $e");
      return [];
    }
  }
  static Future<List<Map<String, dynamic>>> searchProducts(String keyword) async {
    final url = Uri.parse(
      "https://api.jkautomedglobal.in/api/user/product/search",
    ).replace(queryParameters: {
      "search": keyword,
    });

    AjugnuUser? user = AjugnuAuth().getUser();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (user != null && user.token != null && user.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${user.token}';
    }

    final response = await http.get(
      url,
      headers: headers,
    );

    print("Abhi:- search product statusCode:- ${response.statusCode}");
    print("Abhi:- search product statusCode:- ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        return List<Map<String, dynamic>>.from(data["data"]);
      } else {
        return [];
      }
    } else {
      throw Exception("Search API failed: ${response.statusCode}");
    }
  }
  static Future<NotificationResponse?> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    AjugnuUser? user = AjugnuAuth().getUser();

    final url = Uri.parse('$baseUrl/notification/getnotifications/$userId');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (user != null && user.token != null && user.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${user.token}';
    }

    try {
      final response = await http.get(url, headers: headers);

      debugPrint("Abhi:-get user statusCode: ${response.statusCode}");
      debugPrint("Abhi:-get user statusCode: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NotificationResponse.fromJson(jsonData);
      } else {
        return null; // 👈 silently fail
      }
    } catch (e) {
      print("Abhi:- get notification exception: $e");
      return null; // 👈 user ko kuch nahi dikhega
    }
  }

  Future<Map<String, dynamic>> createPhonePeOrder(
     double amount
      ) async
  {
    final prefs = await SharedPreferences.getInstance();
    AjugnuUser? user = AjugnuAuth().getUser();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (user != null && user.token != null && user.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${user.token}';
    }


    final response = await http.post(
      Uri.parse('$baseUrl/phonepay/create-order'),
      headers: headers,
      body: jsonEncode({
       "amount": amount
      }),
    );

    debugPrint("Create phone pe order response statusCode: ${response.statusCode}");
    debugPrint("Create phone pe order response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load related products');
    }
  }

  Future<Map<String, dynamic>> verifyPhonePeOrder(
      String orderId
      ) async
  {
    final prefs = await SharedPreferences.getInstance();
    AjugnuUser? user = AjugnuAuth().getUser();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (user != null && user.token != null && user.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${user.token}';
    }


    final response = await http.get(
      Uri.parse('$baseUrl/phonepay/check-status/$orderId'),
      headers: headers,

    );

    debugPrint("verify phone pe order response statusCode: ${response.statusCode}");
    debugPrint("verify phone pe order response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load related products');
    }
  }

  // Future<Map<String, dynamic>> createCashfreeOrder({
  //   required double amount,
  //   required String customerName,
  //   required String customerPhone,
  //   String? customerEmail,
  //   String? orderNote,
  // }) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String? userId = prefs.getString('user_id');
  //     AjugnuUser? user = AjugnuAuth().getUser();
  //
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'userID': userId ?? '',
  //     };
  //     if (user?.token?.isNotEmpty == true) {
  //       headers['Authorization'] = 'Bearer ${user!.token}';
  //     }
  //
  //     final response = await http.post(
  //       // Uri.parse('$baseUrl/cashfree/create-order'),  // ← yeh backend endpoint banao
  //       Uri.parse('https://api.jkautomedglobal.in/api/phonepay/create-order'),  // ← yeh backend endpoint banao
  //       headers: headers,
  //       body: jsonEncode(/*{
  //         "amount": amount,
  //         "customerName": customerName,
  //         "customerPhone": customerPhone,
  //         "customerEmail": customerEmail ?? "test@example.com",
  //         "orderNote": orderNote ?? "Cart Checkout",
  //       }*/
  //
  //           {
  //             "amount": amount,
  //             "customerName": "Abhishek Patel",
  //             "customerPhone": "9999999999",
  //             "user_id": userId ?? ''
  //           }
  //       ),
  //     );
  //
  //     debugPrint("Cashfree create order status: ${response.statusCode}");
  //     debugPrint("Cashfree create order body: ${response.body}");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final data = jsonDecode(response.body);
  //       if (data['success'] == true) {
  //         return data;  // {success: true, order_id: ..., payment_session_id: ...}
  //       } else {
  //         debugPrint("Cashfree create order error: ${data['error']}");
  //         throw Exception(data['error'] ?? "Order creation failed");
  //       }
  //     } else {
  //       debugPrint("Cashfree create order Server error: ${response.statusCode} - ${response.body}");
  //       throw Exception("Server error: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     debugPrint("Cashfree order error: ${e}");
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> createCashfreeOrder({
    required double amount,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? orderNote,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      AjugnuUser? user = AjugnuAuth().getUser();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (userId != null && userId.isNotEmpty) 'userID': userId,
      };

      if (user?.token?.isNotEmpty == true) {
        headers['Authorization'] = 'Bearer ${user!.token}';
      }

      /// ✅ BODY (IMPORTANT FIX)
      Map<String, dynamic> body = {
        "amount": amount,
        "customerName": customerName,
        "customerPhone": customerPhone,
        "customerEmail": customerEmail ?? "test@example.com",
        "orderNote": orderNote ?? "Cart Checkout",
      };

      /// 👇 user_id tabhi bhejna jab valid ho
      if (userId != null && userId.length == 24) {
        body["user_id"] = userId;
      }

      debugPrint("👉 Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse('https://api.jkautomedglobal.in/api/phonepay/create-order'),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint("✅cashfree Status: ${response.statusCode}");
      debugPrint("✅cashfree Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['error'] ?? "Order creation failed");
        }
      } else {
        throw Exception("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e, s) {
      debugPrint("❌ Cashfree order error: $e");
      debugPrint("📌 Stacktrace: $s");
      rethrow;
    }
  }

  //https://api.jkautomedglobal.in/api/phonepay/create-order
  //http://localhost:4170/api/phonepay/check-status/407fd2dc-b47b-42f5-8834-509eb5d27fc7
}