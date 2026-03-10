import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/notification_provider.dart';
import '../models/app_notification.dart';
import '../config/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationProvider notifProvider =
        Get.find<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (notifProvider.unreadCount.value == 0) {
              return const SizedBox.shrink();
            }
            return TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text('Mark All Read',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (notifProvider.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = notifProvider.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_none_outlined,
                      size: 50, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 20),
                Text('All Caught Up!',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'No notifications yet.\nWe\'ll notify you about claims and matches.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => notifProvider.fetchNotifications(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (ctx, i) =>
                _buildNotificationTile(ctx, notifications[i], notifProvider),
          ),
        );
      }),
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppNotification notif,
      NotificationProvider provider) {
    return InkWell(
      onTap: () {
        if (!notif.isRead) provider.markAsRead(notif.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notif.isRead
              ? null
              : notif.color.withValues(alpha: 0.05),
          border: Border(
            left: BorderSide(
              color: notif.isRead
                  ? Colors.transparent
                  : notif.color,
              width: 3,
            ),
            bottom: BorderSide(
              color: AppTheme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, color: notif.color, size: 22),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  fontWeight: notif.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: notif.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(notif.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                            fontSize: 10,
                            color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
