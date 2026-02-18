import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop_mobile/core/api/api_client.dart';
import 'package:shop_mobile/features/auth/data/models/user_model.dart';

class AdminAuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AdminAuthRepository({ApiClient? apiClient, FlutterSecureStorage? storage})
      : _apiClient = apiClient ??
            ApiClient(tokenKey: 'admin_jwt_token', authPrefix: 'admin'),
        _storage = storage ?? const FlutterSecureStorage();

  Future<AdminAuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.adminLogin(email, password);

      if (response.data['success'] == true) {
        if (response.data['requires_2fa'] == true) {
          return AdminAuthResult.requires2FA(
            tempToken: response.data['temp_token'],
          );
        }

        final token = response.data['token'] ?? response.data['data']?['token'];
        if (token != null) {
          await _apiClient.saveToken(token);
          await _storage.write(key: 'admin_auth_role', value: 'admin');
        }

        final userJson = response.data['user'] ?? response.data['data']?['user'];
        final user = userJson != null ? User.fromJson(userJson) : null;
        return AdminAuthResult.success(user: user, token: token);
      }

      return AdminAuthResult.failure(
        response.data['message'] ?? 'Login failed',
      );
    } catch (e) {
      return AdminAuthResult.failure(_extractError(e));
    }
  }

  Future<User?> getCurrentAdmin() async {
    try {
      final token = await _apiClient.getToken();
      if (token == null) return null;

      final response = await _apiClient.adminMe();
      if (response.data['success'] == true) {
        return User.fromJson(response.data['user']);
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    try {
      await _apiClient.adminLogout();
    } finally {
      await _apiClient.deleteToken();
      await _storage.delete(key: 'admin_auth_role');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null;
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server. Make sure Laravel is running.';
        case DioExceptionType.badResponse:
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
          return 'Server error: ${e.response?.statusCode}';
        default:
          return 'Network error. Please try again.';
      }
    }
    return 'An error occurred. Please try again.';
  }
}

class AdminAuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? error;
  final bool requires2FA;

  AdminAuthResult._({
    required this.success,
    this.user,
    this.token,
    this.error,
    this.requires2FA = false,
  });

  factory AdminAuthResult.success({User? user, String? token}) {
    return AdminAuthResult._(success: true, user: user, token: token);
  }

  factory AdminAuthResult.failure(String error) {
    return AdminAuthResult._(success: false, error: error);
  }

  factory AdminAuthResult.requires2FA({required String tempToken}) {
    return AdminAuthResult._(
      success: true,
      requires2FA: true,
      token: tempToken,
    );
  }
}
