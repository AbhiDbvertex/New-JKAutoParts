// class CartResponse {
//   final bool status;
//   final String message;
//   final List<CartItem> cartItems;
//   final String? location;
//   final String? pincode;
//   final String? userPincode;
//   final UserFullAddress? userfulladdress; // API mein lowercase 'f'
//   final CourierData? courierData;
//   final num totalAmount; // API mein integer bhi aa sakta hai (3000)
//   final num totalWeight;  // API mein integer (4)
//
//   CartResponse({
//     required this.status,
//     required this.message,
//     required this.cartItems,
//     this.location,
//     this.pincode,
//     this.userPincode,
//     this.userfulladdress,
//     this.courierData,
//     required this.totalAmount,
//     required this.totalWeight,
//   });
//
//   factory CartResponse.fromJson(Map<String, dynamic> json) {
//     return CartResponse(
//       status: json['status'] as bool? ?? false,
//       message: json['message'] as String? ?? '',
//       cartItems: (json['cartItems'] as List<dynamic>? ?? [])
//           .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       location: json['location'] as String?,
//       pincode: json['pincode'] as String?,
//       userPincode: json['user_pincode'] as String?,
//       userfulladdress: json['userfulladdress'] != null
//           ? UserFullAddress.fromJson(json['userfulladdress'] as Map<String, dynamic>)
//           : null,
//       courierData: json['courierData'] != null
//           ? CourierData.fromJson(json['courierData'] as Map<String, dynamic>)
//           : null,
//       totalAmount: json['totalAmount'] ?? 0,
//       totalWeight: json['totalWeight'] ?? 0,
//     );
//   }
// }

class CartResponse {
  final bool status;
  final String message;
  final List<CartItem> cartItems;
  final String? location;
  final String? pincode;
  final String? userPincode;
  final UserFullAddress? userfulladdress;
  final CourierData? courierData;
  final num totalAmount;
  final num totalWeight;

  CartResponse({
    required this.status,
    required this.message,
    required this.cartItems,
    this.location,
    this.pincode,
    this.userPincode,
    this.userfulladdress,
    this.courierData,
    required this.totalAmount,
    required this.totalWeight,
  });

  // ADD THIS: copyWith method
  CartResponse copyWith({
    bool? status,
    String? message,
    List<CartItem>? cartItems,
    String? location,
    String? pincode,
    String? userPincode,
    UserFullAddress? userfulladdress,
    CourierData? courierData,
    num? totalAmount,
    num? totalWeight,
  }) {
    return CartResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      cartItems: cartItems ?? this.cartItems,
      location: location ?? this.location,
      pincode: pincode ?? this.pincode,
      userPincode: userPincode ?? this.userPincode,
      userfulladdress: userfulladdress ?? this.userfulladdress,
      courierData: courierData ?? this.courierData,
      totalAmount: totalAmount ?? this.totalAmount,
      totalWeight: totalWeight ?? this.totalWeight,
    );
  }

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      cartItems: (json['cartItems'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] as String?,
      pincode: json['pincode'] as String?,
      userPincode: json['user_pincode'] as String?,
      userfulladdress: json['userfulladdress'] != null
          ? UserFullAddress.fromJson(json['userfulladdress'] as Map<String, dynamic>)
          : null,
      courierData: json['courierData'] != null
          ? CourierData.fromJson(json['courierData'] as Map<String, dynamic>)
          : null,
      totalAmount: json['totalAmount'] ?? 0,
      totalWeight: json['totalWeight'] ?? 0,
    );
  }
}

/*class CartItem {
  final String id;
  final int quantity;
  final String userId;
  final Product product;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.quantity,
    required this.userId,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      product: Product.fromJson(json['product_id'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}*/
class CartItem {
  final String id;
  final int quantity;
  final String userId;
  final Product product;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.quantity,
    required this.userId,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  // ADD THIS: copyWith
  CartItem copyWith({
    String? id,
    int? quantity,
    String? userId,
    Product? product,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      product: Product.fromJson(json['product_id'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final num price; // API mein integer (1500)
  final int quantity;
  final int status;
  final List<String> images;
  final ShipmentBox shipmentBox;
  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;

  // Extra firstImage helper
  String get firstImage {
    if (images.isEmpty) return '';
    return 'https://api.jkautomedglobal.in/${images.first}';
  }

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.status,
    required this.images,
    required this.shipmentBox,
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String? ?? '',
      name: json['product_name'] as String? ?? '',
      description: json['product_description'] as String? ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      images: List<String>.from(json['product_images'] ?? []),
      shipmentBox: ShipmentBox.fromJson(json['shipment_box'] as Map<String, dynamic>),
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      subcategoryId: json['subcategory_id'] as String?,
      subcategoryName: json['subcategory_name'] as String?,
    );
  }
}

class ShipmentBox {
  final num weight; // API mein integer (2)

  ShipmentBox({required this.weight});

  factory ShipmentBox.fromJson(Map<String, dynamic> json) {
    return ShipmentBox(
      weight: json['weight'] ?? 0,
    );
  }
}

class UserFullAddress {
  final String? state;
  final String? city;
  final String? buildingName;
  final String? addressLine;
  final String? addressDescription;

  UserFullAddress({
    this.state,
    this.city,
    this.buildingName,
    this.addressLine,
    this.addressDescription,
  });

  factory UserFullAddress.fromJson(Map<String, dynamic> json) {
    return UserFullAddress(
      state: json['state'] as String?,
      city: json['city'] as String?,
      buildingName: json['building_name'] as String?,
      addressLine: json['address_line'] as String?,
      addressDescription: json['address_description'] as String?,
    );
  }
}

class CourierData {
  final String courierName;
  final int courierCompanyId;
  final num rate; // API mein decimal (182.9)
  final String estimatedDeliveryDays;
  final String etd;
  final int cod;
  final String deliveryBoyContact;

  CourierData({
    required this.courierName,
    required this.courierCompanyId,
    required this.rate,
    required this.estimatedDeliveryDays,
    required this.etd,
    required this.cod,
    required this.deliveryBoyContact,
  });

  factory CourierData.fromJson(Map<String, dynamic> json) {
    return CourierData(
      courierName: json['courier_name'] as String? ?? '',
      courierCompanyId: json['courier_company_id'] as int? ?? 0,
      rate: json['rate'] ?? 0,
      estimatedDeliveryDays: json['estimated_delivery_days'] as String? ?? '',
      etd: json['etd'] as String? ?? '',
      cod: json['cod'] as int? ?? 0,
      deliveryBoyContact: json['delivery_boy_contact'] as String? ?? '',
    );
  }
}