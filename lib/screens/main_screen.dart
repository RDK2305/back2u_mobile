import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../providers/notification_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'browse_items_screen.dart';
import 'my_items_screen.dart';
import 'my_claims_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'messages_inbox_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final RxInt _unreadMessages = 0.obs;

  final List<Widget> _screens = const [
    HomeScreen(),
    BrowseItemsScreen(),
    MyItemsScreen(),
    MyClaimsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _refreshUnreadMessages();
  }

  Future<void> _refreshUnreadMessages() async {
    try {
      final token = AuthService().getToken() ?? '';
      if (token.isEmpty) return;
      final count = await ApiService().getUnreadMessageCount(token);
      _unreadMessages.value = count;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final NotificationProvider notifProvider =
        Get.find<NotificationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondaryColor,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Browse',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'My Items',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.assignment_outlined),
                  Obx(() {
                    final count = _unreadMessages.value;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              activeIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.assignment),
                  Obx(() {
                    final count = _unreadMessages.value;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              label: 'Claims',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.person_outlined),
                  Obx(() {
                    final count = notifProvider.unreadCount.value;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              activeIcon: Stack(
                children: [
                  const Icon(Icons.person),
                  Obx(() {
                    final count = notifProvider.unreadCount.value;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 2
          ? _buildSpeedDial(context)
          : null,
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showActionSheet(context),
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('What would you like to do?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _actionTile(
              ctx,
              icon: Icons.search_off_outlined,
              color: AppTheme.errorColor,
              title: 'Report Lost Item',
              subtitle: 'I lost something on campus',
              route: '/report-lost',
            ),
            const SizedBox(height: 8),
            _actionTile(
              ctx,
              icon: Icons.volunteer_activism_outlined,
              color: AppTheme.successColor,
              title: 'Report Found Item',
              subtitle: 'I found something on campus',
              route: '/report-found',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext ctx, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        Get.toNamed(route);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(ctx)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: Theme.of(ctx).textTheme.bodySmall),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: AppTheme.textSecondaryColor),
          ],
        ),
      ),
    );
  }

  void showNotificationsScreen() {
    Get.to(() => const NotificationsScreen());
  }

  void showMessagesScreen() {
    Get.to(() => const MessagesInboxScreen())?.then((_) => _refreshUnreadMessages());
  }
}
