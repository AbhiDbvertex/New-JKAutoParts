import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:http/http.dart' as http;

import '../../common/backend/ajugnu_auth.dart';
import '../../common/backend/api_handler.dart';

class RazorpayManager {
  static final RazorpayManager _instance = RazorpayManager._internal();
  final Razorpay _razorpay = Razorpay();

  double lastAmount = -1;

  Function(PaymentSuccessResponse response)? successCallbacks;
  Function(PaymentFailureResponse response)? errorCallbacks;
  Function(ExternalWalletResponse response)? walletCallbacks;

  factory RazorpayManager() {
    return _instance;
  }

  RazorpayManager._internal() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onHandleExternalWallet);
  }

  Future<void> onPaymentSuccess(PaymentSuccessResponse response) async {
    successCallbacks?.call(response);
  }

  void onPaymentError(PaymentFailureResponse response) {
    if (errorCallbacks != null) {
      errorCallbacks!(response);
    }
  }

  void onHandleExternalWallet(ExternalWalletResponse response) {
    if (walletCallbacks != null) {
      walletCallbacks!(response);
    }
  }

  void setCallbacks(Function(PaymentSuccessResponse response) successCallback, Function(PaymentFailureResponse response) errorCallback, {Function(ExternalWalletResponse response)? externalWalletCallback}) {
    this.successCallbacks = successCallback;
    this.errorCallbacks = errorCallback;
    this.walletCallbacks = externalWalletCallback;
  }

  void pay(double amount) {
    lastAmount = amount * 100;
    var options = {
      'key': razorpayApiKey,
      'amount': (amount * 100).toInt(), // convert to paise
      'name': '${AjugnuAuth().getUser()?.fullName} ${DateTime.now()}',
      'description': 'Account ${AjugnuAuth().getUser()?.mobile} paying $amount rupees to jkautomed for purchasing parts',
      'timeout': 120,
      'prefill': {
        'contact': '+91${AjugnuAuth().getUser()?.mobile}',
        'email': AjugnuAuth().getUser()?.email
      }
    };
    _razorpay.open(options);
  }

  Future<String> capture(String payId, double amount) async {
    adebug(payId);
    try {
      final basic = base64Encode(utf8.encode("$razorpayApiKey:$razorpayServerKey"));

      Map<String, String> headers = {'Content-Type': 'application/json'};
      headers['Authorization'] = "Basic $basic";

      late http.Response response;
      try {
        response = await http.post(Uri.parse("https://api.razorpay.com/v1/payments/$payId/capture"), body: jsonEncode({
          "amount": amount.toInt(),
          "currency": "INR"
        }), headers: headers, encoding: Encoding.getByName('utf-8'),).timeout(const Duration(minutes: 2));
      } catch (error) {
        throw noInternetError;
      }

      if (kDebugMode) {
        adebug('HTTP response(${response.statusCode}): ${response.body}');
      }

      late dynamic responseInJson;
      try {
        responseInJson = jsonDecode(response.body);
      } catch (error) {
        if (response.statusCode == 502) {
          throw serverDownError;
        } else {
          rethrow;
        }
      }

      if ((response.statusCode == 200 || response.statusCode == 201) && responseInJson['status'] == 'captured') {
        return responseInJson.toString();
      } else {
        throw "Capturing failed";
    }
    } catch (error) {
      throw "Error while capturing razorpay: $error";
    }
  }
}