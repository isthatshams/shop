import 'package:dio/dio.dart';
import 'package:shop_mobile/core/api/api_client.dart';
import 'package:shop_mobile/features/notifications/data/models/notification_model.dart';

class AdminNotificationRepository {
  final ApiClient _apiClient;

  AdminNotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(tokenKey: 'admin_jwt_token', authPrefix: 'admin');

  Future<NotificationListResult> getNotifications() async {
    try {
      final response = await _apiClient.getAdminNotifications();
      if (response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        final items = data['notifications']?['data'] ?? [];
        final notifications = (items as List)
            .map((n) => AppNotification.fromJson(n))
            .toList();
        return NotificationListResult(
          notifications: notifications,
          unreadCount: data['unread_count'] ?? 0,
        );
      }
    } catch (_) {}
    return NotificationListResult(notifications: [], unreadCount: 0);
  }

  Future<bool> markRead(String id) async {
    try {
      final response = await _apiClient.markAdminNotificationRead(id);
      return response.data['success'] == true;
    } catch (_) {}
    return false;
  }

  Future<bool> sendNotification({
    required String title,
    required String body,
    String type = 'general',
    String sendTo = 'customers',
  }) async {
    try {
      final response = await _apiClient.sendAdminNotification({
        'title': title,
        'body': body,
        'type': type,
        'send_to': sendTo,
      });
      return response.data['success'] == true;
    } catch (_) {}
    return false;
  }

  String extractError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'];
      }
    }
    return 'An error occurred. Please try again.';
  }
}
