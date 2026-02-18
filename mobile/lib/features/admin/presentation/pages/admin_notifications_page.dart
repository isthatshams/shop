import 'package:flutter/material.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/features/admin/data/repositories/admin_auth_repository.dart';
import 'package:shop_mobile/features/admin/data/repositories/admin_notification_repository.dart';
import 'package:shop_mobile/features/notifications/data/models/notification_model.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final AdminNotificationRepository _repository = AdminNotificationRepository();
  final AdminAuthRepository _authRepository = AdminAuthRepository();
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final authenticated = await _authRepository.isAuthenticated();
    if (!mounted) return;
    if (!authenticated) {
      Navigator.pop(context);
      return;
    }
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

  Future<void> _sendNotification() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and body are required'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final success = await _repository.sendNotification(
      title: title,
      body: body,
      sendTo: 'customers',
    );

    if (!mounted) return;

    if (success) {
      await _loadNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send notification'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notifications'),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('$_unreadCount')),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendNotification,
        child: const Icon(Icons.send),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.notifications_none, size: 64),
                        SizedBox(height: 12),
                        Center(child: Text('No notifications yet')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return ListTile(
                          tileColor: notification.isRead
                              ? Theme.of(context).colorScheme.surface
                              : AppTheme.primaryColor.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(notification.title),
                          subtitle: Text(notification.body),
                          onTap: () => _markRead(notification),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: _notifications.length,
                    ),
            ),
    );
  }
}
