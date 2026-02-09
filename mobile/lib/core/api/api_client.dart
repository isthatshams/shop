import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // For iOS simulator use: 'http://localhost:8000/api'
  
  final Dio _dio;
  final FlutterSecureStorage _storage;
  
  ApiClient({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add JWT interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry request with new token
                final token = await _storage.read(key: 'jwt_token');
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (_) {
              // Refresh failed, clear token
              await _storage.delete(key: 'jwt_token');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<bool> _refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
    } catch (_) {}
    return false;
  }
  
  // Auth methods
  Future<Response> register(String name, String email, String password) async {
    return _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
  }
  
  Future<Response> login(String email, String password) async {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }
  
  Future<Response> logout() async {
    return _dio.post('/auth/logout');
  }
  
  Future<Response> getMe() async {
    return _dio.get('/auth/me');
  }
  
  // 2FA methods
  Future<Response> enable2FA() async {
    return _dio.post('/auth/2fa/enable');
  }
  
  Future<Response> verify2FA(String code) async {
    return _dio.post('/auth/2fa/verify', data: {
      'code': code,
    });
  }
  
  Future<Response> disable2FA(String code) async {
    return _dio.post('/auth/2fa/disable', data: {
      'code': code,
    });
  }
  
  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
  
  Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}
