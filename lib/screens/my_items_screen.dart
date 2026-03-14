import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';
import '../config/theme.dart';
import 'item_detail_screen.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen>
    with SingleTickerProviderStateMixin {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final ItemProvider _itemProvider = Get.find<ItemProvider>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _itemProvider.getItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Item> _getMyItems(String type) {
    final userId = _authProvider.currentUser.value?.id;
    if (userId == null) return [];
    return _itemProvider.items
        .where((i) => i.type.toLowerCase() == type && i.userId == userId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Items'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.search_off_outlined, size: 18), text: 'Lost'),
            Tab(icon: Icon(Icons.find_in_page_outlined, size: 18), text: 'Found'),
          ],
        ),
      ),
      body: Obx(() {
        if (_itemProvider.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildItemsTab('lost', AppTheme.errorColor, Icons.search_off_outlined, 'No lost items', 'Report a lost item'),
            _buildItemsTab('found', AppTheme.successColor, Icons.find_in_page_outlined, 'No found items', 'Report a found item'),
          ],
        );
      }),
    );
  }

  Widget _buildItemsTab(String type, Color color, IconData emptyIcon, String emptyTitle, String emptySubtitle) {
    final items = _getMyItems(type);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(emptyIcon, size: 44, color: color),
            ),
            const SizedBox(height: 16),
            Text(emptyTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(emptySubtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(type == 'lost' ? '/report-lost' : '/report-found'),
              icon: const Icon(Icons.add),
              label: Text(type == 'lost' ? 'Report Lost' : 'Report Found'),
              style: ElevatedButton.styleFrom(backgroundColor: color),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _itemProvider.getItems(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (ctx, i) => _buildItemCard(items[i], color),
      ),
    );
  }

  Widget _buildItemCard(Item item, Color typeColor) {
    return GestureDetector(
      onTap: () => Get.to(() => ItemDetailScreen(item: item)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.shadowSmall],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 90, height: 90,
                child: item.displayImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.displayImageUrl!, fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: typeColor.withValues(alpha: 0.1), child: Icon(Icons.image_outlined, color: typeColor)),
                        errorWidget: (_, _, _) => Container(color: typeColor.withValues(alpha: 0.1), child: Icon(_categoryIcon(item.category), color: typeColor, size: 32)),
                      )
                    : Container(color: typeColor.withValues(alpha: 0.1), child: Icon(_categoryIcon(item.category), color: typeColor, size: 32)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        _buildStatusBadge(item.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (item.description != null)
                      Text(item.description!, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 2),
                        Expanded(child: Text(item.locationFound, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.chevron_right, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'open': color = AppTheme.successColor; break;
      case 'claimed': color = AppTheme.warningColor; break;
      case 'returned': color = AppTheme.infoColor; break;
      default: color = AppTheme.textSecondaryColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'wallet': return Icons.account_balance_wallet_outlined;
      case 'phone': return Icons.phone_android_outlined;
      case 'keys': return Icons.key_outlined;
      case 'id': return Icons.badge_outlined;
      case 'clothing': return Icons.checkroom_outlined;
      case 'bag': return Icons.backpack_outlined;
      case 'textbook': return Icons.book_outlined;
      case 'electronics': return Icons.devices_outlined;
      default: return Icons.category_outlined;
    }
  }
}
