import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String tokenKey;
  final String authPrefix;
  // Development: Use php artisan serve (localhost:8000)
  // Production: Update to your deployed API URL
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Android emulator -> host machine
    } else {
      return 'http://localhost:8000/api'; // iOS simulator / macOS
    }
  }

  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({
    Dio? dio,
    FlutterSecureStorage? storage,
    this.tokenKey = 'jwt_token',
    this.authPrefix = 'customer',
  }) : _dio = dio ?? Dio(),
       _storage = storage ?? const FlutterSecureStorage() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add JWT interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Skip refresh for auth endpoints - they should fail normally
          final path = error.requestOptions.path;
          final isAuthEndpoint =
              path.contains('/$authPrefix/login') ||
              path.contains('/$authPrefix/register') ||
              path.contains('/$authPrefix/verify-otp') ||
              path.contains('/$authPrefix/refresh');

          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            // Token expired on a protected route, try to refresh
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry request with new token
                final token = await _storage.read(key: tokenKey);
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (_) {
              // Refresh failed, clear token
              await _storage.delete(key: tokenKey);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final response = await _dio.post('/$authPrefix/refresh');
      if (response.statusCode == 200) {
        final token = response.data['data']?['token'] ?? response.data['token'];
        if (token != null) {
          await _storage.write(key: tokenKey, value: token);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // ============ Customer Auth ============

  Future<Response> register(String name, String email, String password) async {
    return _dio.post(
      '/customer/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
  }

  Future<Response> verifyOtp(String email, String otp) async {
    return _dio.post(
      '/customer/verify-otp',
      data: {'email': email, 'otp': otp},
    );
  }

  Future<Response> resendOtp(String email) async {
    return _dio.post('/customer/resend-otp', data: {'email': email});
  }

  Future<Response> login(String email, String password) async {
    return _dio.post(
      '/customer/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> logout() async {
    return _dio.post('/customer/logout');
  }

  Future<Response> getMe() async {
    return _dio.get('/customer/me');
  }

  // ============ Admin Auth ============

  Future<Response> adminLogin(String email, String password) async {
    return _dio.post(
      '/admin/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> adminLogout() async {
    return _dio.post('/admin/logout');
  }

  Future<Response> adminMe() async {
    return _dio.get('/admin/me');
  }

  // ============ Products ============

  Future<Response> getProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? featured,
    bool? inStock,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
    if (categoryId != null) params['category_id'] = categoryId;
    if (search != null) params['search'] = search;
    if (featured != null) params['featured'] = featured;
    if (inStock != null) params['in_stock'] = inStock;

    return _dio.get('/products', queryParameters: params);
  }

  Future<Response> getProduct(int id) async {
    return _dio.get('/products/$id');
  }

  Future<Response> getFeaturedProducts() async {
    return _dio.get('/products/featured');
  }

  Future<Response> getNewArrivals() async {
    return _dio.get('/products/new-arrivals');
  }

  // ============ Categories ============

  Future<Response> getCategories() async {
    return _dio.get('/categories');
  }

  Future<Response> getCategory(int id) async {
    return _dio.get('/categories/$id');
  }

  Future<Response> getCategoryProducts(int categoryId) async {
    return _dio.get('/categories/$categoryId/products');
  }

  // ============ Customer Settings ============

  Future<Response> getSettings() async {
    return _dio.get('/customer/settings');
  }

  Future<Response> updateSettings(Map<String, dynamic> payload) async {
    return _dio.put('/customer/settings', data: payload);
  }

  // ============ Notifications ============

  Future<Response> getNotifications() async {
    return _dio.get('/customer/notifications');
  }

  Future<Response> markNotificationRead(String id) async {
    return _dio.post('/customer/notifications/$id/read');
  }

  Future<Response> registerDeviceToken({
    required String token,
    String? platform,
  }) async {
    return _dio.post(
      '/customer/device-tokens',
      data: {'token': token, 'platform': platform},
    );
  }

  // ============ Admin Products ============

  Future<Response> getAdminProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? isActive,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
    if (categoryId != null) params['category_id'] = categoryId;
    if (isActive != null) params['is_active'] = isActive;

    return _dio.get('/admin/products', queryParameters: params);
  }

  Future<Response> getAdminProduct(int id) async {
    return _dio.get('/admin/products/$id');
  }

  Future<Response> createAdminProduct(Map<String, dynamic> payload) async {
    return _dio.post('/admin/products', data: payload);
  }

  Future<Response> updateAdminProduct(int id, Map<String, dynamic> payload) async {
    return _dio.put('/admin/products/$id', data: payload);
  }

  Future<Response> deleteAdminProduct(int id) async {
    return _dio.delete('/admin/products/$id');
  }

  // ============ Admin Notifications ============

  Future<Response> getAdminNotifications() async {
    return _dio.get('/admin/notifications');
  }

  Future<Response> sendAdminNotification(Map<String, dynamic> payload) async {
    return _dio.post('/admin/notifications', data: payload);
  }

  Future<Response> markAdminNotificationRead(String id) async {
    return _dio.post('/admin/notifications/$id/read');
  }

  Future<Response> registerAdminDeviceToken({
    required String token,
    String? platform,
  }) async {
    return _dio.post(
      '/admin/device-tokens',
      data: {'token': token, 'platform': platform},
    );
  }

  // ============ Token management ============

  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: tokenKey);
  }
}
