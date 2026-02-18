import 'package:dio/dio.dart';
import 'package:shop_mobile/core/api/api_client.dart';
import 'package:shop_mobile/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<NotificationListResult> getNotifications() async {
    try {
      final response = await _apiClient.getNotifications();
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
      final response = await _apiClient.markNotificationRead(id);
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
