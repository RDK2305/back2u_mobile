import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/claim_provider.dart';
import '../models/item.dart';
import 'item_detail_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final ItemProvider _itemProvider = Get.find<ItemProvider>();
  final NotificationProvider _notifProvider = Get.find<NotificationProvider>();
  final ClaimProvider _claimProvider = Get.find<ClaimProvider>();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    _itemProvider.getItems();
    _claimProvider.fetchMyClaims();
    _notifProvider.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  _buildQuickActions(),
                  _buildRecentFoundItems(),
                  const SizedBox(height: 100), // bottom nav spacing
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      actions: [
        // Notification bell
        Obx(() {
          final count = _notifProvider.unreadCount.value;
          return Stack(
            children: [
              IconButton(
                onPressed: () => Get.to(() => const NotificationsScreen()),
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
              ),
              if (count > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (v) async {
            if (v == 'settings') Get.toNamed('/settings');
            if (v == 'logout') {
              await _authProvider.logout();
              Get.offAllNamed('/login');
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
            const PopupMenuItem(
                value: 'logout',
                child: Text('Logout',
                    style: TextStyle(color: Colors.red))),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                Color(0xFF2563EB),
                AppTheme.primaryLightColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Obx(() {
                final user = _authProvider.currentUser.value;
                final name = user?.firstName ?? 'User';
                final campus = user?.campus ?? '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $name 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (campus.isNotEmpty)
                              Text(
                                '$campus Campus',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Find your lost items or help others',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Obx(() {
        final user = _authProvider.currentUser.value;
        final myLostItems = _itemProvider.items
            .where((i) =>
                i.type.toLowerCase() == 'lost' && i.userId == user?.id)
            .length;
        final foundItems = _itemProvider.items
            .where((i) => i.type.toLowerCase() == 'found')
            .length;
        final myClaims = _claimProvider.claims.length;

        return Row(
          children: [
            _buildStatCard(
              value: '$myLostItems',
              label: 'My Lost\nItems',
              icon: Icons.search_off_outlined,
              color: AppTheme.errorColor,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              value: '$foundItems',
              label: 'Found\nItems',
              icon: Icons.find_in_page_outlined,
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              value: '$myClaims',
              label: 'My\nClaims',
              icon: Icons.assignment_outlined,
              color: AppTheme.warningColor,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.shadowSmall],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.search_off_outlined,
                label: 'Lost\nItem',
                gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFF87171)]),
                onTap: () => Get.toNamed('/report-lost'),
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                icon: Icons.volunteer_activism_outlined,
                label: 'Found\nItem',
                gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                onTap: () => Get.toNamed('/report-found'),
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                icon: Icons.search_outlined,
                label: 'Browse\nAll',
                gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]),
                onTap: () => Get.toNamed('/browse-items'),
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                icon: Icons.assignment_outlined,
                label: 'My\nClaims',
                gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                onTap: () => Get.toNamed('/my-claims'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFoundItems() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Found Items',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => Get.toNamed('/browse-items'),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (_itemProvider.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            final foundItems = _itemProvider.items
                .where((i) => i.type.toLowerCase() == 'found')
                .take(5)
                .toList();

            if (foundItems.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: foundItems
                  .map((item) => _buildRecentItemCard(item))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.shadowSmall],
      ),
      child: Column(
        children: [
          Icon(Icons.find_in_page_outlined,
              size: 52, color: AppTheme.textSecondaryColor),
          const SizedBox(height: 12),
          Text('No Found Items Yet',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            'Be the first to report a found item\nand help someone recover it.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/report-found'),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Report Found Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemCard(Item item) {
    return GestureDetector(
      onTap: () => Get.to(() => ItemDetailScreen(item: item)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [AppTheme.shadowSmall],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: item.displayImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.displayImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppTheme.primaryColor
                              .withValues(alpha: 0.1),
                          child: Icon(Icons.image_outlined,
                              color: AppTheme.primaryColor),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppTheme.successColor
                              .withValues(alpha: 0.1),
                          child: Icon(
                            _categoryIcon(item.category),
                            color: AppTheme.successColor,
                            size: 28,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        child: Icon(
                          _categoryIcon(item.category),
                          color: AppTheme.successColor,
                          size: 28,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description ?? item.category.capitalize!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 11,
                          color: AppTheme.textSecondaryColor),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          item.locationFound,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'phone':
        return Icons.phone_android_outlined;
      case 'keys':
        return Icons.key_outlined;
      case 'id':
        return Icons.badge_outlined;
      case 'clothing':
        return Icons.checkroom_outlined;
      case 'bag':
        return Icons.backpack_outlined;
      case 'textbook':
        return Icons.book_outlined;
      case 'electronics':
        return Icons.devices_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
