import 'package:flutter/services.dart';

class PhonePeService {
  static const _channel = MethodChannel('phonepe_payment');

  // Payment initiate function
  static Future<String?> startPayment(Map<String, dynamic> paymentData) async {
    try {
      final result = await _channel.invokeMethod('startPayment', paymentData);
      return result; // Success ya error message
    } catch (e) {
      return 'Error: $e';
    }
  }
}
