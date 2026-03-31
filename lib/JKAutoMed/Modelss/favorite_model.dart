class FavoriteProductResponse {
  final bool status;
  final String message;
  final List<FavoriteItem> favorites;

  FavoriteProductResponse({
    required this.status,
    required this.message,
    required this.favorites,
  });

  factory FavoriteProductResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteProductResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      favorites: (json['favorites'] as List<dynamic>?)
          ?.map((item) => FavoriteItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class FavoriteItem {
  final String id; // favorite entry ka _id
  final String userId;
  final Product product; // yeh product_id object hai
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      product: Product.fromJson(json['product_id']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Product {
  final String id;
  final String productName;
  final String? localName;
  final String? otherName;
  final List<String> productImages;
  final String categoryId;
  final String? partnumber;
  final String? productWeight;
  final String? categoryName;
  final String? size;
  final String? description;
  final double averageRating;
  final int ratingCount;
  final bool active;
  final bool defaultProduct;
  final bool deleteStatus;
  final ShipmentBox shipmentBox;
  final String productDescription;
  final String categoryNameFull; // category_name
  final String subcategoryId;
  final String subcategoryName;
  final double price;
  final int quantity;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.productName,
    this.localName,
    this.otherName,
    this.partnumber,
    required this.productImages,
    required this.categoryId,
    this.productWeight,
    this.categoryName,
    this.size,
    this.description,
    required this.averageRating,
    required this.ratingCount,
    required this.active,
    required this.defaultProduct,
    required this.deleteStatus,
    required this.shipmentBox,
    required this.productDescription,
    required this.categoryNameFull,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.price,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      productName: json['product_name'] ?? 'Unknown Product',
      localName: json['local_name'],
      otherName: json['other_name'],
      partnumber: json['part_number'],
      productImages: (json['product_images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      categoryId: json['category_id'] ?? '',
      productWeight: json['product_weight'],
      categoryName: json['categoryName'],
      size: json['size'],
      description: json['description'],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      active: json['active'] ?? false,
      defaultProduct: json['default_product'] ?? false,
      deleteStatus: json['delete_status'] ?? false,
      shipmentBox: ShipmentBox.fromJson(json['shipment_box'] ?? {}),
      productDescription: json['product_description'] ?? '',
      categoryNameFull: json['category_name'] ?? '',
      subcategoryId: json['subcategory_id'] ?? '',
      subcategoryName: json['subcategory_name'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// class ShipmentBox {
//   final int weight;
//
//   ShipmentBox({required this.weight});
//
//   factory ShipmentBox.fromJson(Map<String, dynamic> json) {
//     return ShipmentBox(
//       weight: json['weight'] ?? 0,
//     );
//   }
// }

class ShipmentBox {
  final double weight;

  ShipmentBox({required this.weight});

  factory ShipmentBox.fromJson(Map<String, dynamic> json) {
    return ShipmentBox(
      weight: (json['weight'] ?? 0).toDouble(),
    );
  }
}
