import 'package:dio/dio.dart';
import 'package:shop_mobile/core/api/api_client.dart';
import 'package:shop_mobile/features/settings/data/models/customer_settings_model.dart';

class SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<SettingsPayload?> getSettings() async {
    try {
      final response = await _apiClient.getSettings();
      if (response.data['success'] == true) {
        return SettingsPayload.fromJson(response.data['data']);
      }
    } catch (_) {}
    return null;
  }

  Future<SettingsUpdateResult> updateSettings({
    CustomerProfile? profile,
    CustomerSettings? settings,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (profile != null) {
        payload['profile'] = {
          'name': profile.name,
          'phone': profile.phone,
          'avatar': profile.avatar,
        };
      }
      if (settings != null) {
        payload['settings'] = settings.toJson();
      }

      final response = await _apiClient.updateSettings(payload);
      if (response.data['success'] == true) {
        return SettingsUpdateResult.success(
          SettingsPayload.fromJson(response.data['data']),
        );
      }
      return SettingsUpdateResult.failure('Failed to update settings');
    } catch (e) {
      return SettingsUpdateResult.failure(extractError(e));
    }
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

class SettingsUpdateResult {
  final bool success;
  final SettingsPayload? payload;
  final String? error;

  SettingsUpdateResult._({required this.success, this.payload, this.error});

  factory SettingsUpdateResult.success(SettingsPayload payload) {
    return SettingsUpdateResult._(success: true, payload: payload);
  }

  factory SettingsUpdateResult.failure(String error) {
    return SettingsUpdateResult._(success: false, error: error);
  }
}
