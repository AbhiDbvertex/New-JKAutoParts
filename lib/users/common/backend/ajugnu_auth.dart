import 'dart:convert';
import 'dart:io';

import 'package:jkautomed/main.dart';
import 'package:jkautomed/users/common/backend/firebase_notification_impl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/ajugnu_users.dart';
import '../../customer/backend/cart_count_emitter.dart';
import '../../customer/backend/cart_repository.dart';
import 'api_handler.dart';

class AjugnuAuth {

  static const keyUserJson = 'userJsonData';
  static final AjugnuAuth _instance = AjugnuAuth._internal();

  SharedPreferences? localStorage;

  factory AjugnuAuth() {
    return _instance;
  }

  AjugnuAuth._internal();

  Future<AjugnuAuth> initialise() async {
    localStorage = await SharedPreferences.getInstance();
    return this;
  }

  AjugnuUser? getUser() {
    try {
      var json = jsonDecode(localStorage?.getString(keyUserJson) ?? ''); // Map
      AjugnuUser user = AjugnuUser.fromJson(json, token: json['token']);
      return user.token != null && user.token?.isNotEmpty == true ? user : null;
    } catch (error) {
      return null;
    }
  }

  Future<void> saveUser(AjugnuUser user) async {
    try {
      adebug(user.token, tag: 'Saving user');
      String json = jsonEncode(user.toJson());
      await localStorage?.setString(keyUserJson, json);
      return Future.value();
    } catch (error) {
      adebug(error.toString(), tag: 'saveUser');
      rethrow;
    }
  }

 /* Future<String> signup( String fullname, String phone, String email,
      String password, String role, String pinCode, {String? profilePicPath}) async {
    var request = http.MultipartRequest('POST', Uri.parse("$ajugnuBaseUrl/api/user/register"));

    try {
      if (profilePicPath != null) {
        request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicPath));
      }
    } catch (error) {
      throw "Please attach your valid profile picture along with sign up data.";
    }

    request.fields['full_name'] = fullname;
    request.fields['email'] = email;
    request.fields['mobile'] = phone;
    request.fields['password'] = password;
    request.fields['role'] = "user";
    request.fields['pin_code'] = pinCode;

    await initializeFirebaseNotifications();
    request.fields['firebase_token'] = firebaseNotificationToken;

    late http.StreamedResponse streamedResponse;

    try {
      streamedResponse = await request.send().timeout(const Duration(minutes: 1));
    } catch (error) {
      throw 'Timeout! Please check your internet connection.';
    }

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
        responseInJson['status'] == true) {
      String userId = responseInJson['_id'].toString();
      Future<void> saveUserId(String userId) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
      }
      String otp = responseInJson['otp'].toString();
      print("OTP Debug: $otp , userId: ");

      return otp;   // **OTP return**
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
  }*/

  Future<String> signup(
      String fullname,
      String phone,
      String email,
      String password,
      String role,
      String pinCode, {
        String? profilePicPath,
      }) async
  {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$ajugnuBaseUrl/api/user/register"),
    );

    try {
      if (profilePicPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', profilePicPath),
        );
      }
    } catch (error) {
      throw "Please attach your valid profile picture along with sign up data.";
    }

    request.fields['full_name'] = fullname;
    request.fields['email'] = email;
    request.fields['mobile'] = phone;
    request.fields['password'] = password;
    request.fields['role'] = "user";
    request.fields['pin_code'] = pinCode;

    await initializeFirebaseNotifications();
    request.fields['firebase_token'] = firebaseNotificationToken;

    late http.StreamedResponse streamedResponse;

    try {
      streamedResponse =
      await request.send().timeout(const Duration(minutes: 1));
    } catch (error) {
      throw 'Timeout! Please check your internet connection.';
    }

    Map<String, dynamic> responseInJson;

    try {
      responseInJson =
          jsonDecode(await streamedResponse.stream.bytesToString());
    } catch (e) {
      throw streamedResponse.statusCode == 502
          ? 'Server is not working, please wait and try again after some time.'
          : 'Error while decoding response.';
    }

    if (streamedResponse.statusCode == 201 &&
        responseInJson['status'] == true) {

      final String userId = responseInJson['_id'].toString();
      final String otp = responseInJson['otp'].toString();

      // ✅ SAVE USER ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);

      print("OTP Debug: $otp, userId: $userId");

      return otp; // OTP return
    } else {
      String detailedError = responseInJson['message'] ??
          responseInJson['error'] ??
          responseInJson['msg'] ??
          'Something went wrong. (response code: ${streamedResponse.statusCode})';
      throw detailedError;
    }
  }



  Future<AuthResponse> verifyOTP(String phoneNumber, String otp) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({"mobile": phoneNumber, "otp": otp, "firebase_token": firebaseNotificationToken}),
          endpoint: '/api/user/verifyOtp'
      );
    } catch (error) {
      adebug(error.toString());
      return AuthResponse(false, error.toString());
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      var user = AjugnuUser.fromJson(response.responseBody['user'],
          token: response.responseBody['token']);
      await saveUser(user);
      return AuthResponse(true,
          'Welcome, ${user.fullName?.split(' ').first ?? user.fullName}.');
    } else {
      String detailedError = response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
      return AuthResponse(false, detailedError);
    }
  }

  Future<AuthResponse> resendOTP(String phoneNumber) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({"mobile": phoneNumber}),
          endpoint: '/api/user/resendOTP');
    } catch (error) {
      adebug(error.toString());
      return AuthResponse(false, error.toString());
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      return
        const AuthResponse(true, "Please verify OTP sent to your email address.");
    } else {
      String detailedError = response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
      return AuthResponse(false, detailedError);
    }
  }

  Future<AuthResponse> updateUserPinCode(String pinCode) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({"pin_code": pinCode}),
          endpoint: '/api/user/updateUserPincode', authorization: AjugnuAuth().getUser()?.token);
    } catch (error) {
      adebug(error.toString());
      return AuthResponse(false, error.toString());
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      var user = AjugnuUser.fromJson(response.responseBody['user'], token: getUser()?.token);
      await saveUser(user);
      return const AuthResponse(true, "Postal code updated successfully.");
    } else {
      String detailedError = response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
          ? response.responseBody['error']
          : response.responseBody.containsKey('msg')
          ? response.responseBody['msg']
          : 'Something went wrong. (response code: ${response.statusCode})';
      return AuthResponse(false, detailedError);
    }
  }

  Future<AuthResponse> resetPassword(String phoneNumber, String otp, String newPassword) async {
    late ApiResponse response;
    try {
      response = await makeHttpPutRequest(
          bodyJson: jsonEncode(
              {"mobile": phoneNumber, 'otp': otp, 'newPassword': newPassword}),
          endpoint: '/api/user/forgetPassword');
    } catch (error) {
      adebug(error.toString());
      return AuthResponse(false, error.toString());
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      return AuthResponse(true,
          response.responseBody['message'] ?? 'Password changed successfully/');
    } else {
      String detailedError = response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
      return AuthResponse(false, detailedError);
    }
  }

  Future<AuthResponse> signIn(String phoneNumber, String password) async {
    late ApiResponse response;

    try {
      await initializeFirebaseNotifications();

      response = await makeHttpPostRequest(
        bodyJson: jsonEncode({
          "mobile": phoneNumber,
          "password": password,
          "firebase_token": firebaseNotificationToken,
        }),
        endpoint: '/api/user/login',
      );
    } catch (error) {
      adebug(error.toString());
      print("Abhi:-Status Code: ${error}");
      return AuthResponse(false, error.toString());
    }
    print("Abhi:-Status Code: ${response.statusCode}");
    print("Abhi:-Response Body: ${response.responseBody}");

    print("Abhi:- get response in singin : ${response.statusCode}");
// print("Abhi:- get response in singin : ${response.}");
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody['status'] == true) {
      // print("Abhi:- get response in singin : ${response.b}");
      var user = AjugnuUser.fromJson(
        response.responseBody['user'],
        token: response.responseBody['token'],
      );

      // ✅ SAVE USER OBJECT (existing)
      await saveUser(user);

      // ✅ SAVE USER ID (NEW)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id ?? '');

      return AuthResponse(
        true,
        'Welcome Back, ${user.fullName?.split(' ').first ?? user.fullName}.',
      );
    } else {
      String detailedError =
          response.responseBody['message'] ??
              response.responseBody['error'] ??
              response.responseBody['msg'] ??
              'Something went wrong.';

      return AuthResponse(false, detailedError);
    }
  }


  Future<AuthResponse> logout() async {
    late ApiResponse response;
    String? token = getUser()?.token;
    if (kDebugMode) {
      adebug('token: $token', tag: "logout");
    }
    try {
      response = await makeHttpGetRequest(
          endpoint: '/api/user/logoutUser', authorization: token);
    } catch (error) {
      return AuthResponse(false, error.toString());
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      var user = getUser();
      await localStorage?.remove(keyUserJson);
      try {
        FirebaseMessaging.instance.deleteToken();
        firebaseNotificationToken = await FirebaseMessaging.instance.getToken()?? 'No token';
        CartRepository().onLogOut();

        //localStorage?.clear();

      } catch (error) {
        // error
      }
      return AuthResponse(true, 'Goodbye, ${user?.fullName?.split(' ').first ?? user?.fullName}. Hope you come back soon.');
    } else {
      String detailedError = response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';
      return AuthResponse(false, detailedError);
    }
  }

  Future<AuthResponse> changePassword(
      String oldPassword, String password, String cpassword) async {
    late ApiResponse response;
    String? token = getUser()?.token;
    try {
     ;
      response = await makeHttpPutRequest(endpoint: '/api/user/ChangePassword', authorization: token, bodyJson:jsonEncode({'oldPassword':oldPassword,'newPassword':password,'confirmPassword':cpassword}));
    } catch (error) {
      return AuthResponse(false, error.toString());
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      return AuthResponse(true,
          response.responseBody['message'] ?? 'Password changed successfully');
    } else {
      String detailedError = response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
              ? response.responseBody['error']
              : response.responseBody.containsKey('msg')
                  ? response.responseBody['msg']
                  : 'Something went wrong. (response code: ${response.statusCode})';

      return AuthResponse(false, detailedError);
    }
  }

  Future<AuthResponse> updateRole() async {
    late ApiResponse response;
    String? token = getUser()?.token;
    try {
      response = await makeHttpPostRequest(endpoint: '/api/user/updateUserRole', authorization: token, bodyJson:jsonEncode({}));
    } catch (error) {
      return AuthResponse(false, error.toString());
    }
    if ((response.statusCode == 200 || response.statusCode == 201)) {
      var user = AjugnuUser.fromJson(getUser()?.toJson()??{},
          token: response.responseBody['user']['token']);
      adebug(token, tag: "token for update role");
      adebug(response.responseBody['user']['token'], tag: 'new token');
      await saveUser(user);
      adebug(getUser()?.token, tag: 'saved token');
      return AuthResponse(true,
          response.responseBody['message'] ?? 'Role updated as both');
    } else {
      String detailedError = response.responseBody.containsKey('message')
          ? response.responseBody['message']
          : response.responseBody.containsKey('error')
          ? response.responseBody['error']
          : response.responseBody.containsKey('msg')
          ? response.responseBody['msg']
          : 'Something went wrong. (response code: ${response.statusCode})';

      return AuthResponse(false, detailedError);
    }
  }

  /*Future<bool> editProfileSupplier(String fullName, String address, List<String?> pinCode, File? profileImage) async {
    var request = http.MultipartRequest('PUT', Uri.parse("$ajugnuBaseUrl/api/supplier/updateSupplierProfileData"));
    try {
      if (profileImage != null && profileImage.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('profile_pic', profileImage.path));
      }
    } catch (error) {
      throw "Please attach your valid profile picture along with sign up data.";
    }
    request.fields['full_name'] = fullName;
    request.fields['address'] = address;
    request.fields['mobile'] = (getUser()?.mobile??0).toString();
    request.fields['email'] = getUser()?.email ?? '';
    if (pinCode.isNotEmpty) {
      for (int i = 0; i < pinCode.length; i++) {
        if (pinCode[i] != null) {
          request.fields['pin_code[$i]'] = pinCode[i].toString();
        }
      }
    }

    adebug(request.fields.keys, tag: 'editProfileSupplier');

    request.headers['Authorization'] = "Bearer ${AjugnuAuth().getUser()?.token}";
    var streamedResponse = await request.send().timeout(const Duration(minutes: 1));

    Map<String ,dynamic> responseInJson;
    try {
      responseInJson = jsonDecode(await streamedResponse.stream.bytesToString());
    } catch (e) {
      throw streamedResponse.statusCode == 502 ? 'Server is not working, please wait and try again after some time.' :  'Error while decoding response.';
    }

    adebug(responseInJson, tag: 'editProfileSupplier');

    if (streamedResponse.statusCode == 200 && responseInJson.containsKey('status') && responseInJson['status'] is bool && responseInJson['status']) {
      AjugnuUser user = getUser()!;
      saveUser(AjugnuUser(otpVerified: 1, firebaseToken: user.firebaseToken, pinCode: pinCode.isNotEmpty ? List<String?>.from(responseInJson['pin_code']) : user.pinCode, fullName: fullName, addressMap: address, token: user.token, datetime: user.datetime, email: user.email, id: user.id, mobile: user.mobile, profilePic: "$ajugnuBaseUrl/${responseInJson['profile_pic']}", role: user.role));
      return true;
    } else {
      String detailedError = responseInJson.containsKey('message') ? responseInJson['message'] : responseInJson.containsKey('error') ? responseInJson['error'] : responseInJson.containsKey('msg') ? responseInJson['msg'] : 'Something went wrong. (response code: ${streamedResponse.statusCode})';
      throw detailedError;
    }
  }*/

  Future<bool> editProfileSupplier(
      String fullName,
      String address,                  // yeh string hi rahega (user input)
      List<String?> pinCode,
      File? profileImage) async {

    var request = http.MultipartRequest(
        'PUT', Uri.parse("$ajugnuBaseUrl/api/supplier/updateSupplierProfileData"));

    // Profile image
    if (profileImage != null && profileImage.existsSync()) {
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profileImage.path));
    }

    // Fields
    request.fields['full_name'] = fullName;
    request.fields['address'] = address;  // string bhej rahe ho backend ko
    request.fields['mobile'] = (getUser()?.mobile ?? 0).toString();
    request.fields['email'] = getUser()?.email ?? '';

    if (pinCode.isNotEmpty) {
      for (int i = 0; i < pinCode.length; i++) {
        if (pinCode[i] != null) {
          request.fields['pin_code[$i]'] = pinCode[i]!;
        }
      }
    }

    request.headers['Authorization'] = "Bearer ${getUser()?.token}";

    var streamedResponse = await request.send().timeout(const Duration(minutes: 1));

    Map<String, dynamic> responseInJson;
    try {
      responseInJson = jsonDecode(await streamedResponse.stream.bytesToString());
    } catch (e) {
      throw streamedResponse.statusCode == 502
          ? 'Server is not working, please wait and try again.'
          : 'Error decoding response.';
    }

    adebug(responseInJson, tag: 'editProfileSupplier');

    if (streamedResponse.statusCode == 200 && responseInJson['status'] == true) {
      AjugnuUser oldUser = getUser()!;
      var updatedUserJson = responseInJson['user'];

      AjugnuUser updatedUser = AjugnuUser(
        otpVerified: updatedUserJson['otp_verified'] ?? oldUser.otpVerified ?? 1,
        firebaseToken: oldUser.firebaseToken,
        pinCode: pinCode.isNotEmpty ? pinCode : oldUser.pinCode,
        id: oldUser.id,
        fullName: fullName,
        email: updatedUserJson['email'] ?? oldUser.email,
        mobile: oldUser.mobile,
        role: oldUser.role,
        oRole: oldUser.oRole,
        otp: oldUser.otp,
        datetime: oldUser.datetime,
        token: oldUser.token,
        profilePic: updatedUserJson['profile_pic'] != null
            ? "$ajugnuBaseUrl/${updatedUserJson['profile_pic']}"
            : oldUser.profilePic,
        addressMap: updatedUserJson['address'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(updatedUserJson['address'])
            : oldUser.addressMap,
      );

      await saveUser(updatedUser);
      return true;
    } else {
      String error = responseInJson['message'] ??
          responseInJson['error'] ??
          responseInJson['msg'] ??
          'Update failed (${streamedResponse.statusCode})';
      throw error;
    }
  }

  Future<bool> editProfileCustomer(String fullName, /*String address,*/ String? profileImage) async {
    var request = http.MultipartRequest('POST', Uri.parse("$ajugnuBaseUrl/api/user/updateCostomerProfileData"));
    try {
      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath('profile_pic', profileImage));
      }
    } catch (error) {
      throw "Please attach your valid profile picture along with sign up data.";
    }
    request.fields['full_name'] = fullName;
    // request.fields['address'] = address;
    request.fields['mobile'] = (getUser()?.mobile??0).toString();
    request.fields['email'] = getUser()?.email ?? '';
    adebug(request.fields.keys, tag: 'editProfileCustomer');

    request.headers['Authorization'] = "Bearer ${AjugnuAuth().getUser()?.token}";
    var streamedResponse = await request.send().timeout(const Duration(minutes: 1));

    Map<String ,dynamic> responseInJson;
    try {
      responseInJson = jsonDecode(await streamedResponse.stream.bytesToString());
    } catch (e) {
      throw streamedResponse.statusCode == 502 ? 'Server is not working, please wait and try again after some time.' :  'Error while decoding response.';
    }

    adebug(responseInJson, tag: 'editProfileSupplier');

    if (streamedResponse.statusCode == 200 && responseInJson.containsKey('status') && responseInJson['status'] is bool && responseInJson['status']) {
      AjugnuUser user = getUser()!;
      saveUser(AjugnuUser(otpVerified: 1, firebaseToken: user.firebaseToken, pinCode: user.pinCode, fullName: fullName, /*address: address,*/ token: user.token, datetime: user.datetime, email: user.email, id: user.id, mobile: user.mobile, profilePic: "$ajugnuBaseUrl/${responseInJson['profile_pic']}", role: user.role));
      return true;
    } else {
      String detailedError = responseInJson.containsKey('message') ? responseInJson['message'] : responseInJson.containsKey('error') ? responseInJson['error'] : responseInJson.containsKey('msg') ? responseInJson['msg'] : 'Something went wrong. (response code: ${streamedResponse.statusCode})';
      throw detailedError;
    }
  }

  Future<String> cancelOrder(String orderID) async {
    late ApiResponse response;
    try {

      debugPrint("orderid::${orderID}");
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({
            "order_id" : orderID,
            "new_status":"cancelled"
          }),
          endpoint: '/api/user/updateCancelOrder', authorization: getUser()?.token);
      debugPrint("orderidresponse::${response.responseBody.toString()}");
    } catch (error) {
      adebug(error.toString());
      throw error.toString();
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      return 'Order cancellation has been processed. ';
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

  Future<String> addBankDetails(String bankName, String accountNumber, String ifciNumber, String bankAddress, String username) async {
    late ApiResponse response;
    try {
      response = await makeHttpPostRequest(
          bodyJson: jsonEncode({
            "bankName" : bankName,
            "accountNumber" : accountNumber,
            "ifscCode" : ifciNumber,
            "bankAddress" : bankAddress,
            "supplierName" : username
          }),
          endpoint: '/api/user/addBankDetails', authorization: getUser()?.token);
    } catch (error) {
      adebug(error.toString());
      throw error.toString();
    }
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.responseBody.containsKey('status') &&
        response.responseBody['status'] is bool &&
        response.responseBody['status']) {
      return 'Bank details added to your account.';
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

class AuthResponse {
  final bool status;
  final String? message;

  const AuthResponse(this.status, this.message);
}
