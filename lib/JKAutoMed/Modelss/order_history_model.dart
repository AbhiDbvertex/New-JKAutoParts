// import 'dart:convert';
//
// class OrderHistory {
//   final ShippingAddress shippingAddress;
//   final String status;
//   final String? awbNumber;
//   final double courierCharge;
//   final String id;
//   final String orderId;
//   final String userId;
//   final List<Item> items;
//   final String paymentMethod;
//   final double totalAmount;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final Tracking? tracking;
//
//   OrderHistory({
//     required this.shippingAddress,
//     required this.status,
//     this.awbNumber,
//     required this.courierCharge,
//     required this.id,
//     required this.orderId,
//     required this.userId,
//     required this.items,
//     required this.paymentMethod,
//     required this.totalAmount,
//     required this.createdAt,
//     required this.updatedAt,
//     this.tracking,
//   });
//
//   factory OrderHistory.fromJson(Map<String, dynamic> json) {
//     return OrderHistory(
//       shippingAddress: ShippingAddress.fromJson(json['shipping_address']),
//       status: json['status'],
//       awbNumber: json['awb_number'],
//       courierCharge: json['courier_charge'].toDouble(),
//       id: json['_id'],
//       orderId: json['order_id'],
//       userId: json['user_id'],
//       items: (json['items'] as List).map((i) => Item.fromJson(i)).toList(),
//       paymentMethod: json['payment_method'],
//       totalAmount: json['total_amount'].toDouble(),
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//       tracking: json['tracking'] != null ? Tracking.fromJson(json['tracking']) : null,
//     );
//   }
// }
//
// class ShippingAddress {
//   final String name;
//   final String address;
//   final String pincode;
//   final String mobileNumber;
//
//   ShippingAddress({
//     required this.name,
//     required this.address,
//     required this.pincode,
//     required this.mobileNumber,
//   });
//
//   factory ShippingAddress.fromJson(Map<String, dynamic> json) {
//     return ShippingAddress(
//       name: json['name'],
//       address: json['address'],
//       pincode: json['pincode'],
//       mobileNumber: json['mobile_number'],
//     );
//   }
// }
//
// class Item {
//   final String id;
//   final String productName;
//   final double sellingPrice;
//   final int units;
//   // Add imageUrl if your API provides it; otherwise, use a placeholder
//   final String? imageUrl;
//
//   Item({
//     required this.id,
//     required this.productName,
//     required this.sellingPrice,
//     required this.units,
//     this.imageUrl,
//   });
//
//   factory Item.fromJson(Map<String, dynamic> json) {
//     return Item(
//       id: json['_id'],
//       productName: json['product_name'],
//       sellingPrice: json['selling_price'].toDouble(),
//       units: json['units'],
//       imageUrl: null, // Replace with json['image_url'] if available
//     );
//   }
// }
//
// class Tracking {
//   final bool success;
//   final String message;
//   final TrackingData data;
//
//   Tracking({
//     required this.success,
//     required this.message,
//     required this.data,
//   });
//
//   factory Tracking.fromJson(Map<String, dynamic> json) {
//     return Tracking(
//       success: json['success'],
//       message: json['message'],
//       data: TrackingData.fromJson(json['data']),
//     );
//   }
// }
//
// class TrackingData {
//   final String orderDbId;
//   final String awb;
//   final int shipmentStatus;
//   final String shiprocketStatusText;
//   final String orderStatus;
//   final String trackUrl;
//
//   TrackingData({
//     required this.orderDbId,
//     required this.awb,
//     required this.shipmentStatus,
//     required this.shiprocketStatusText,
//     required this.orderStatus,
//     required this.trackUrl,
//   });
//
//   factory TrackingData.fromJson(Map<String, dynamic> json) {
//     return TrackingData(
//       orderDbId: json['order_db_id'],
//       awb: json['awb'],
//       shipmentStatus: json['shipment_status'],
//       shiprocketStatusText: json['shiprocket_status_text'],
//       orderStatus: json['order_status'],
//       trackUrl: json['track_url'],
//     );
//   }
// }
//
// // Helper to parse full API response
// List<OrderHistory> parseOrders(String jsonString) {
//   final Map<String, dynamic> response = json.decode(jsonString);
//   if (response['status'] == true) {
//     return (response['data'] as List).map((item) => OrderHistory.fromJson(item)).toList();
//   }
//   return [];
// }

import 'dart:convert';

class OrderHistory {
  final ShippingAddress shippingAddress;
  final String status;
  final String? awbNumber;
  final double courierCharge;
  final String id;
  final String orderId;
  final String userId;
  final List<Item> items;
  final String paymentMethod;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Tracking? tracking;

  OrderHistory({
    required this.shippingAddress,
    required this.status,
    this.awbNumber,
    required this.courierCharge,
    required this.id,
    required this.orderId,
    required this.userId,
    required this.items,
    required this.paymentMethod,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.tracking,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      shippingAddress: ShippingAddress.fromJson(json['shipping_address']),
      status: json['status'],
      awbNumber: json['awb_number'],
      courierCharge: (json['courier_charge'] ?? 0).toDouble(),
      id: json['_id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      items: (json['items'] as List)
          .map((i) => Item.fromJson(i))
          .toList(),
      paymentMethod: json['payment_method'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tracking:
      json['tracking'] != null ? Tracking.fromJson(json['tracking']) : null,
    );
  }
}

class ShippingAddress {
  final String name;
  final String address;
  final String pincode;
  final String mobileNumber;

  ShippingAddress({
    required this.name,
    required this.address,
    required this.pincode,
    required this.mobileNumber,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'],
      address: json['address'],
      pincode: json['pincode'],
      mobileNumber: json['mobile_number'],
    );
  }
}

class Item {
  final String id;
  final String productId;          // ✅ new
  final String productName;
  final double sellingPrice;
  final int units;
  final List<String> productImages; // ✅ new

  Item({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sellingPrice,
    required this.units,
    required this.productImages,
  });

  String get firstImage =>
      productImages.isNotEmpty ? productImages.first : '';

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      productId: json['product_id'], // ✅ api se
      productName: json['product_name'],
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      units: json['units'] ?? 0,
      productImages: json['product_images'] != null
          ? List<String>.from(json['product_images'])
          : [],
    );
  }
}

class Tracking {
  final bool success;
  final String message;
  final TrackingData data;

  Tracking({
    required this.success,
    required this.message,
    required this.data,
  });

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      success: json['success'],
      message: json['message'],
      data: TrackingData.fromJson(json['data']),
    );
  }
}

class TrackingData {
  final String orderDbId;
  final String awb;
  final int shipmentStatus;
  final String shiprocketStatusText;
  final String orderStatus;
  final String trackUrl;

  TrackingData({
    required this.orderDbId,
    required this.awb,
    required this.shipmentStatus,
    required this.shiprocketStatusText,
    required this.orderStatus,
    required this.trackUrl,
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    return TrackingData(
      orderDbId: json['order_db_id'],
      awb: json['awb'],
      shipmentStatus: json['shipment_status'],
      shiprocketStatusText: json['shiprocket_status_text'],
      orderStatus: json['order_status'],
      trackUrl: json['track_url'],
    );
  }
}

// helper
List<OrderHistory> parseOrders(String jsonString) {
  final Map<String, dynamic> response = json.decode(jsonString);
  if (response['status'] == true) {
    return (response['data'] as List)
        .map((e) => OrderHistory.fromJson(e))
        .toList();
  }
  return [];
}
