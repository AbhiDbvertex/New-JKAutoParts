// class Product {
//   final String id;
//   final String name;
//   final String partnumber;
//   final String description;
//   final double price;
//   final List<String> images;
//   final String categoryName;
//   final String subcategoryName;
//   final int quantity;
//
//   Product({
//     required this.id,
//     required this.name,
//     required this.partnumber,
//     required this.description,
//     required this.price,
//     required this.images,
//     required this.categoryName,
//     required this.subcategoryName,
//     required this.quantity,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['_id'] ?? '',
//       name: json['product_name'] ?? 'Unknown Product',
//       partnumber: json['part_number'] ?? 'Unknown Product',
//       description: json['product_description'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       images: List<String>.from(json['product_images'] ?? []),
//       categoryName: json['category_name'] ?? '',
//       subcategoryName: json['subcategory_name'] ?? '',
//       quantity: json['quantity'] ?? 0,
//     );
//   }
// }

class Product {
  final String id;
  final String name;
  final String partnumber;
  final dynamic avgRating;
  final String refranceNumber;
  final String description;
  final double price;
  final List<String> images;
  final String categoryName;
  final String subcategoryName;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.partnumber,
    required this.avgRating,
    required this.refranceNumber,
    required this.description,
    required this.price,
    required this.images,
    required this.categoryName,
    required this.subcategoryName,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['product_name']?.toString() ?? '',
      partnumber: json.containsKey('part_number') && json['part_number'] != null ? json['part_number'].toString() : '',
      refranceNumber: json.containsKey('reference_number') && json['reference_number'] != null ? json['reference_number'].toString() : '',
      description: json['product_description']?.toString() ?? '',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      images: json['product_images'] != null
          ? List<String>.from(json['product_images'])
          : [],
      categoryName: json['category_name']?.toString() ?? '',
      avgRating: json['avgRating']?.toString() ?? '',
      subcategoryName: json['subcategory_name']?.toString() ?? '',
      quantity: json['quantity'] != null
          ? int.tryParse(json['quantity'].toString()) ?? 0
          : 0,
    );
  }
}
