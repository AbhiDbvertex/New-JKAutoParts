// import 'package:jkautomed/models/ajugnu_product.dart';
import 'package:intl/intl.dart';

import '../users/common/backend/api_handler.dart';
import 'ajugnu_product.dart';

class AjugnuOrder {
  final String id;
  final String orderID;
  final String date;
  final String paymentMethod;
  List<AjugnuOrderSupplier> orderSupplier;

  AjugnuOrder({
    required this.id,
    required this.orderID,
    required this.date,
    required this.paymentMethod,
    required this.orderSupplier
  });

  factory AjugnuOrder.fromJson(Map<String, dynamic> json) {
    return AjugnuOrder(
      id: json['_id'] ?? '',
      orderID: json['order_id'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      orderSupplier: json['details'] is List<dynamic> ? json['details'].map<AjugnuOrderSupplier>((e) => AjugnuOrderSupplier.fromJson(e)).toList() ?? [] : [],
      date: DateFormat('dd/MM/yyyy').format(parseDate(json['created_at'])),
    );
  }

  static DateTime parseDate(String? date) {
    try {
      return DateTime.parse(date!);
    } catch (error) {
      return DateTime.now();
    }
  }
}

class AjugnuOrderSupplier {
  final String supplierId;
  final String fullName;
  final String verificationId;
  final int totalAmount;
  List<AjugnuProduct> products;
  String status;

  AjugnuOrderSupplier({
    required this.supplierId,
    required this.fullName,
    required this.verificationId,
    required this.totalAmount,
    required this.products,
    required this.status
  });

  factory AjugnuOrderSupplier.fromJson(Map<String, dynamic> json) {
    return AjugnuOrderSupplier(
      supplierId: json['supplier_id'] ?? '',
      fullName: json['full_name'] ?? '',
      verificationId: json['verification_code'] ?? '',
      totalAmount: json['total_amount'] is int ? json['total_amount'] ?? 0 : 0,
        status: (json['products'] is List<dynamic> && json['products'] != null) ? ((json['products'] as List<dynamic>).firstOrNull?['status'] ?? 'order') : 'order',
      products: (json['products'] is List<dynamic> && json['products'] != null) ? json['products'].map<AjugnuProduct>((e) {
        var product =  AjugnuProduct.fromJson(e);
        product.id = e['product_id'];
        return product;
      }).toList() : [],
    );
  }
}
