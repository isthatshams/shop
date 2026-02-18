import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/features/notifications/data/models/notification_model.dart';
import 'package:shop_mobile/features/notifications/data/repositories/notification_repository.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationRepository _repository = NotificationRepository();
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final result = await _repository.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = result.notifications;
      _unreadCount = result.unreadCount;
      _isLoading = false;
    });
  }

  Future<void> _markRead(AppNotification notification) async {
    if (notification.isRead) return;
    final success = await _repository.markRead(notification.id);
    if (!mounted) return;
    if (success) {
      setState(() {
        _notifications = _notifications
            .map(
              (n) => n.id == notification.id
                  ? AppNotification(
                      id: n.id,
                      title: n.title,
                      body: n.body,
                      type: n.type,
                      isRead: true,
                      createdAt: n.createdAt,
                    )
                  : n,
            )
            .toList();
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 120.h),
                        Icon(Icons.notifications_none, size: 64.sp),
                        SizedBox(height: 12.h),
                        Center(
                          child: Text(
                            'No notifications yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return GestureDetector(
                          onTap: () => _markRead(notification),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? Theme.of(context).colorScheme.surface
                                  : AppTheme.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: notification.isRead
                                    ? Colors.transparent
                                    : AppTheme.primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: notification.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notification.body,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      if (notification.createdAt != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(notification.createdAt!),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _notifications.length,
                    ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
