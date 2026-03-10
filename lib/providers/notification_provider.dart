import 'dart:async';
import 'package:get/get.dart';
import '../models/app_notification.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class NotificationProvider extends GetxController {
  final _apiService = ApiService();
  final _authService = AuthService();

  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchNotifications(silent: true),
    );
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;

      final token = _authService.getToken();
      if (token == null) return;

      final data = await _apiService.getNotifications(token);
      final fetched = data
          .map((n) => AppNotification.fromMap(n as Map<String, dynamic>))
          .toList();

      notifications.value = fetched;
      unreadCount.value = fetched.where((n) => !n.isRead).length;
    } catch (e) {
      // Silently fail for notifications — don't disrupt the user
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = _authService.getToken();
      if (token == null) return;

      await _apiService.markNotificationRead(token, notificationId);

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final n = notifications[index];
        notifications[index] = AppNotification(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
          relatedItemId: n.relatedItemId,
          relatedClaimId: n.relatedClaimId,
        );
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final token = _authService.getToken();
      if (token == null) return;

      await _apiService.markAllNotificationsRead(token);
      await fetchNotifications();
    } catch (_) {}
  }

  void clearNotifications() {
    notifications.clear();
    unreadCount.value = 0;
  }
}
