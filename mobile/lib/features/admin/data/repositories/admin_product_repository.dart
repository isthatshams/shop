import 'package:dio/dio.dart';
import 'package:shop_mobile/core/api/api_client.dart';
import 'package:shop_mobile/features/products/data/models/product_model.dart';
import 'package:shop_mobile/features/products/data/repositories/product_repository.dart';

class AdminProductRepository {
  final ApiClient _apiClient;

  AdminProductRepository({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(tokenKey: 'admin_jwt_token', authPrefix: 'admin');

  Future<ProductListResult> getProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? isActive,
  }) async {
    try {
      final response = await _apiClient.getAdminProducts(
        page: page,
        perPage: perPage,
        categoryId: categoryId,
        sortBy: sortBy,
        sortOrder: sortOrder,
        isActive: isActive,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final products = (data['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList();

        return ProductListResult(
          products: products,
          currentPage: data['current_page'] ?? 1,
          lastPage: data['last_page'] ?? 1,
          total: data['total'] ?? 0,
        );
      }
    } catch (_) {}

    return ProductListResult.empty();
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await _apiClient.getAdminProduct(id);
      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  Future<ProductActionResult> createProduct(ProductPayload payload) async {
    try {
      final response = await _apiClient.createAdminProduct(payload.toJson());
      if (response.data['success'] == true) {
        return ProductActionResult.success(
          Product.fromJson(response.data['data']),
        );
      }
      return ProductActionResult.failure('Failed to create product');
    } catch (e) {
      return ProductActionResult.failure(extractError(e));
    }
  }

  Future<ProductActionResult> updateProduct(int id, ProductPayload payload) async {
    try {
      final response = await _apiClient.updateAdminProduct(id, payload.toJson());
      if (response.data['success'] == true) {
        return ProductActionResult.success(
          Product.fromJson(response.data['data']),
        );
      }
      return ProductActionResult.failure('Failed to update product');
    } catch (e) {
      return ProductActionResult.failure(extractError(e));
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _apiClient.deleteAdminProduct(id);
      return response.data['success'] == true;
    } catch (_) {}
    return false;
  }

  String extractError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'];
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }
    return 'An error occurred. Please try again.';
  }
}

class ProductActionResult {
  final bool success;
  final Product? product;
  final String? error;

  ProductActionResult._({required this.success, this.product, this.error});

  factory ProductActionResult.success(Product product) {
    return ProductActionResult._(success: true, product: product);
  }

  factory ProductActionResult.failure(String error) {
    return ProductActionResult._(success: false, error: error);
  }
}

class ProductPayload {
  final String name;
  final String? slug;
  final String? description;
  final double price;
  final double? originalPrice;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final List<String> images;
  final int? categoryId;
  final double rating;
  final int reviewsCount;

  ProductPayload({
    required this.name,
    this.slug,
    this.description,
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.isActive,
    required this.isFeatured,
    required this.images,
    this.categoryId,
    required this.rating,
    required this.reviewsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'stock': stock,
      'is_active': isActive,
      'is_featured': isFeatured,
      'images': images,
      'category_id': categoryId,
      'rating': rating,
      'reviews_count': reviewsCount,
    };
  }
}
