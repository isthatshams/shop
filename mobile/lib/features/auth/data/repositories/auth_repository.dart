import 'package:dio/dio.dart';
import 'package:shop_mobile/core/api/api_client.dart';
import 'package:shop_mobile/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _apiClient.register(name, email, password);

      if (response.data['success'] == true) {
        // New registration requires OTP verification
        if (response.data['data']?['requires_verification'] == true) {
          return AuthResult.requiresOtp(email: email);
        }

        // Fallback for direct login after registration
        final token = response.data['data']?['token'];
        if (token != null) {
          await _apiClient.saveToken(token);
          final user = User.fromJson(response.data['data']['customer']);
          return AuthResult.success(user: user, token: token);
        }

        return AuthResult.requiresOtp(email: email);
      }

      return AuthResult.failure(
        response.data['message'] ?? 'Registration failed',
      );
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  Future<AuthResult> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.verifyOtp(email, otp);

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        await _apiClient.saveToken(token);

        final user = User.fromJson(response.data['data']['customer']);
        return AuthResult.success(user: user, token: token);
      }

      return AuthResult.failure(
        response.data['message'] ?? 'Verification failed',
      );
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  Future<AuthResult> resendOtp(String email) async {
    try {
      final response = await _apiClient.resendOtp(email);

      if (response.data['success'] == true) {
        return AuthResult.success(message: 'OTP sent successfully');
      }

      return AuthResult.failure(
        response.data['message'] ?? 'Failed to resend OTP',
      );
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.login(email, password);

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        await _apiClient.saveToken(token);

        final user = User.fromJson(response.data['data']['customer']);
        return AuthResult.success(user: user, token: token);
      }

      // Check if verification is required
      if (response.data['data']?['requires_verification'] == true) {
        return AuthResult.requiresOtp(
          email: response.data['data']['email'],
          message: response.data['message'],
        );
      }

      return AuthResult.failure(response.data['message'] ?? 'Login failed');
    } catch (e) {
      // Check for 403 requiring verification
      if (e is DioException && e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data?['data']?['requires_verification'] == true) {
          return AuthResult.requiresOtp(
            email: data['data']['email'],
            message: data['message'],
          );
        }
      }
      return AuthResult.failure(_extractError(e));
    }
  }

  Future<TwoFactorSetupResult> enable2FA() async {
    try {
      // This would be for admin 2FA, not customer
      return TwoFactorSetupResult(
        success: false,
        error: '2FA setup not available for customers',
      );
    } catch (e) {
      return TwoFactorSetupResult(success: false, error: _extractError(e));
    }
  }

  Future<AuthResult> verify2FA(String code) async {
    // This is for admin 2FA, not customer OTP
    return AuthResult.failure('2FA not supported for customers');
  }

  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } finally {
      await _apiClient.deleteToken();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _apiClient.getToken();
      if (token == null) return null;

      final response = await _apiClient.getMe();
      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
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

// Result classes
class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? message;
  final String? error;
  final bool requires2FA;
  final bool requiresOtp;
  final String? pendingEmail;

  AuthResult._({
    required this.success,
    this.user,
    this.token,
    this.message,
    this.error,
    this.requires2FA = false,
    this.requiresOtp = false,
    this.pendingEmail,
  });

  factory AuthResult.success({User? user, String? token, String? message}) {
    return AuthResult._(
      success: true,
      user: user,
      token: token,
      message: message,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }

  factory AuthResult.requires2FA({required String tempToken}) {
    return AuthResult._(success: true, requires2FA: true, token: tempToken);
  }

  factory AuthResult.requiresOtp({required String email, String? message}) {
    return AuthResult._(
      success: true,
      requiresOtp: true,
      pendingEmail: email,
      message: message,
    );
  }
}

class TwoFactorSetupResult {
  final bool success;
  final String? secret;
  final String? qrCodeUrl;
  final String? error;

  TwoFactorSetupResult({
    required this.success,
    this.secret,
    this.qrCodeUrl,
    this.error,
  });
}
