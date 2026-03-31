// lib/models/category_model.dart

class Category {
  final String id;
  final String name;
  final String imageUrl;
  final List<SubCategory> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['category_name'],
      imageUrl: json['category_image'] ?? '',
      subcategories: (json['subcategories'] as List)
          .map((e) => SubCategory.fromJson(e))
          .toList(),
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final String imageUrl;

  SubCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'],
      name: json['subcategory_name'],
      imageUrl: json['subcategory_image'] ?? '',
    );
  }
}