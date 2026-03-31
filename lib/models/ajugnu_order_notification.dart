import '../users/common/backend/api_handler.dart';

class AjugnuOrderNotification {
  final String id;
  final String title;
  final String message;
  final String orderId;
  final String type;
  final int totalAmount;
  final DateTime date;
  final List<String> supplierIDs;
  final String userID;
  final String englishName;


  AjugnuOrderNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.orderId,
    required this.type,
    required this.totalAmount,
    required this.date,
    required this.supplierIDs,
    required this.userID,
     this.englishName="Unknown"

  });

  factory AjugnuOrderNotification.fromJson(Map<String, dynamic> json) {
    return AjugnuOrderNotification(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      orderId: json['order_id'] is Map<String, dynamic> ? json['order_id']['order_id'] ?? '' : json['order_id'] ?? '',
      supplierIDs: List<String>.from(json['supplier_ids'] ?? []).map((e) => "$ajugnuBaseUrl/$e").toList(),
      totalAmount: json['totalamount'] ?? 0,
      type: json['type'] ?? '',
      date: parseDate(json['created_at'] ?? ''),
      userID: json['user_id'] ?? '',
      englishName: (json['order_id'] is Map<String, dynamic> && json['order_id']['items'] is List && json['order_id']['items'].isNotEmpty)
          ? json['order_id']['items'][0]['product_id']['english_name'] ?? ''
          : '',

    );
  }

  static DateTime parseDate(String date) {
    try {
      return DateTime.parse(date).toLocal();
    } catch (error) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'order_id': orderId,
      'supplier_ids': supplierIDs,
      'totalamount': totalAmount,
      'type': type,
      'user_id': userID,
      'english_name':englishName,
      'createdAt': date
    };
  }
}
