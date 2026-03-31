import '../users/common/backend/api_handler.dart';

class AjugnuProduct {
  String id;
  final String productName;
  final double averageRating;
  final int ratingCount;
  final List<String> productImages;
  final String localName;
  final String otherName;
  final String? categoryName;
  final String categoryId;
  final int price;
  int quantity;
  final String productType;
  final String productSize;
  final String? toolFertilizerSize;
  final String productRole;
  final String description;
  final String weight;
  final dynamic supplierId;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isFavourite;
  bool isRated;
  bool isApproved;
  bool? deleteStatus;

  AjugnuProduct({
    required this.id,
    required this.productName,
    required this.averageRating,
    required this.ratingCount,
    required this.productImages,
    required this.localName,
    this.categoryName,
    required this.otherName,
    required this.categoryId,
    required this.price,
    required this.quantity,
    required this.productType,
    required this.productSize,
     this.toolFertilizerSize,

    required this.productRole,
    required this.description,
    required this.weight,
    required this.supplierId,
    required this.createdAt,
    required this.updatedAt,
    required this.isApproved,
    required this.isFavourite,
    required this.isRated,
     this.deleteStatus,
  });

  factory AjugnuProduct.fromJson(Map<String, dynamic> json) {
    return AjugnuProduct(
      id: json['_id'] ?? '',
      productName: json['english_name'] ?? json['product_name'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      productImages: List<String>.from(json['product_images'] ?? [])
          .map((e) => "$ajugnuBaseUrl/$e")
          .toList(),
      localName: json['local_name'] ?? '',
      categoryName: json['categoryName'] ?? '',
      otherName: json['other_name'] ?? '',
      categoryId: json['category_id'] is String
          ? json['category_id'] ?? ''
          : json['category_id'] is Map<String, dynamic>
              ? json['category_id']['_id'] ?? ''
              : '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productType: json['product_type'] ?? 'Unknown',
      productSize: json['product_size'] ?? 'Unknown',
      toolFertilizerSize: json['size'] ?? 'Unknown',
      productRole: json['product_role'] ?? 'product',
      description: json['description'] ?? '',
      weight: json['product_weight'] ?? '0kg',
      supplierId: json['supplier_id'] ?? '',
      createdAt: parseDate(json['createdAt'] ?? ''),
      updatedAt: parseDate(json['updatedAt'] ?? ''),
      isFavourite:
          json['isFavorite'] is bool ? json['isFavorite'] ?? false : false,
      isRated: json['has_rated'] is bool ? json['has_rated'] ?? false : false,
      isApproved: json['active'] is bool ? json['active'] ?? false : false,
       deleteStatus: json['delete_status'] is bool ? json['delete_status'] ?? false : false,
    );
  }

  static DateTime parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (error) {
      return DateTime.now();
    }
  }

  static AjugnuProduct dummy({String name = 'Dummy Product'}) {
    return AjugnuProduct(
      id: 'id',
      productName: name,
      averageRating: 0,
      ratingCount: 0,
      productImages: [
        'https://control.ajugnu.com/uploads/product/1723290851998.png'
      ],
      localName: 'localName',
      otherName: 'otherName',
      categoryName: 'categoryName',
      categoryId: 'categoryId',
      price: 199,
      quantity: 2,
      productType: 'indoor',
      productSize: 'medium',
      toolFertilizerSize: "medius",
      description: 'description',
      supplierId: 'supplierId',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFavourite: false,
      productRole: 'product',
      isApproved: true,
      isRated: false,
      weight: '0kg',
        deleteStatus: false,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'english_name': productName,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'product_images': productImages
          .map((image) => image.replaceFirst(ajugnuBaseUrl, ''))
          .toList(),
      'local_name': localName,
      'categoryName':categoryName,
      'other_name': otherName,
      'category_id': categoryId,
      'price': price,
      'quantity': quantity,
      'product_type': productType,
      'product_size': productSize,
      "size":toolFertilizerSize,
      'description': description,
      'supplier_id': supplierId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      "isFavorite": isFavourite,
      "delete_status":deleteStatus,
    };
  }
}
