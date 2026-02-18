class Product {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? originalPrice;
  final int stock;
  final List<String> images;
  final int? categoryId;
  final String? categoryName;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.images,
    this.categoryId,
    this.categoryName,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price']).toDouble()
          : null,
      stock: json['stock'] ?? 0,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      categoryId: json['category_id'],
      categoryName: json['category']?['name'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercent =>
      hasDiscount ? ((originalPrice! - price) / originalPrice! * 100) : 0;

  String get primaryImage =>
      images.isNotEmpty ? images.first : 'https://via.placeholder.com/400';

  bool get isInStock => stock > 0;
}

class Category {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? color;
  final int? parentId;
  final int productsCount;
  final List<Category>? children;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.color,
    this.parentId,
    this.productsCount = 0,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'],
      color: json['color'],
      parentId: json['parent_id'],
      productsCount: json['products_count'] ?? 0,
      children: json['children'] != null
          ? (json['children'] as List).map((c) => Category.fromJson(c)).toList()
          : null,
    );
  }
}
