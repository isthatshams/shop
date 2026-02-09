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
        final token = response.data['token'];
        await _apiClient.saveToken(token);

        final user = User.fromJson(response.data['user']);
        return AuthResult.success(user: user, token: token);
      }

      return AuthResult.failure(
        response.data['message'] ?? 'Registration failed',
      );
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.login(email, password);

      if (response.data['success'] == true) {
        // Check if 2FA is required
        if (response.data['requires_2fa'] == true) {
          final tempToken = response.data['temp_token'];
          await _apiClient.saveToken(tempToken);
          return AuthResult.requires2FA(tempToken: tempToken);
        }

        final token = response.data['token'];
        await _apiClient.saveToken(token);

        final user = User.fromJson(response.data['user']);
        return AuthResult.success(user: user, token: token);
      }

      return AuthResult.failure(response.data['message'] ?? 'Login failed');
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  Future<AuthResult> verify2FA(String code) async {
    try {
      final response = await _apiClient.verify2FA(code);

      if (response.data['success'] == true) {
        final token = response.data['token'];
        if (token != null) {
          await _apiClient.saveToken(token);
        }

        if (response.data['user'] != null) {
          final user = User.fromJson(response.data['user']);
          return AuthResult.success(user: user, token: token);
        }

        return AuthResult.success(message: response.data['message']);
      }

      return AuthResult.failure(
        response.data['message'] ?? 'Verification failed',
      );
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  Future<TwoFactorSetupResult> enable2FA() async {
    try {
      final response = await _apiClient.enable2FA();

      if (response.data['success'] == true) {
        return TwoFactorSetupResult(
          success: true,
          secret: response.data['secret'],
          qrCodeUrl: response.data['qr_code_url'],
        );
      }

      return TwoFactorSetupResult(
        success: false,
        error: response.data['message'] ?? 'Failed to enable 2FA',
      );
    } catch (e) {
      return TwoFactorSetupResult(success: false, error: _extractError(e));
    }
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
        return User.fromJson(response.data['user']);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null;
  }

  String _extractError(dynamic e) {
    if (e is Exception) {
      final message = e.toString();
      if (message.contains('SocketException')) {
        return 'Unable to connect to server';
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
  final String? tempToken;

  AuthResult._({
    required this.success,
    this.user,
    this.token,
    this.message,
    this.error,
    this.requires2FA = false,
    this.tempToken,
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
    return AuthResult._(success: true, requires2FA: true, tempToken: tempToken);
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
