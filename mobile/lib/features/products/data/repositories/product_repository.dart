import 'package:shop_mobile/core/api/api_client.dart';
import 'package:shop_mobile/features/products/data/models/product_model.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ProductListResult> getProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? featured,
    bool? inStock,
  }) async {
    try {
      final response = await _apiClient.getProducts(
        page: page,
        perPage: perPage,
        categoryId: categoryId,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        featured: featured,
        inStock: inStock,
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
      return ProductListResult.empty();
    } catch (e) {
      return ProductListResult.empty();
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await _apiClient.getProduct(id);
      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await _apiClient.getFeaturedProducts();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Product>> getNewArrivals() async {
    try {
      final response = await _apiClient.getNewArrivals();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.getCategories();
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((c) => Category.fromJson(c))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}

class ProductListResult {
  final List<Product> products;
  final int currentPage;
  final int lastPage;
  final int total;

  ProductListResult({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory ProductListResult.empty() =>
      ProductListResult(products: [], currentPage: 1, lastPage: 1, total: 0);

  bool get hasMore => currentPage < lastPage;
}
