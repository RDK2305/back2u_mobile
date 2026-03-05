import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'item_detail_screen.dart';

class BrowseItemsScreen extends StatefulWidget {
  const BrowseItemsScreen({super.key});

  @override
  State<BrowseItemsScreen> createState() => _BrowseItemsScreenState();
}

class _BrowseItemsScreenState extends State<BrowseItemsScreen>
    with SingleTickerProviderStateMixin {
  final ItemProvider _itemProvider = Get.find<ItemProvider>();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  String? _selectedCategory;
  String? _selectedCampus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _itemProvider.getItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Item> _filterItems(List<Item> all, String type) {
    return all.where((item) {
      final matchType = item.type.toLowerCase() == type;
      final matchCat = _selectedCategory == null ||
          item.category.toLowerCase() == _selectedCategory!.toLowerCase();
      final matchCampus = _selectedCampus == null ||
          item.campus.toLowerCase() == _selectedCampus!.toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      return matchType && matchCat && matchCampus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverAppBar(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            title: const Text('Browse Items'),
            floating: true,
            snap: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search items...',
                        hintStyle:
                            const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Found Items'),
                      Tab(text: 'Lost Items'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Filter chips
            _buildFilterChips(),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItemsList('found'),
                  _buildItemsList('lost'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Category filter
            _buildDropdownChip(
              label: _selectedCategory ?? 'Category',
              icon: Icons.category_outlined,
              onTap: _showCategoryFilter,
              isActive: _selectedCategory != null,
            ),
            const SizedBox(width: 8),
            // Campus filter
            _buildDropdownChip(
              label: _selectedCampus ?? 'Campus',
              icon: Icons.location_on_outlined,
              onTap: _showCampusFilter,
              isActive: _selectedCampus != null,
            ),
            if (_selectedCategory != null || _selectedCampus != null) ...[
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Clear'),
                avatar: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() {
                  _selectedCategory = null;
                  _selectedCampus = null;
                }),
                backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
                labelStyle:
                    TextStyle(color: AppTheme.errorColor, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppTheme.textPrimaryColor,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      avatar: Icon(icon,
          size: 16, color: isActive ? Colors.white : AppTheme.primaryColor),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      backgroundColor:
          Theme.of(context).cardColor,
      side: BorderSide(
          color: isActive ? AppTheme.primaryColor : AppTheme.borderColor),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildFilterSheet(
        title: 'Filter by Category',
        items: AppConstants.itemCategories,
        selected: _selectedCategory,
        onSelect: (v) {
          setState(() => _selectedCategory = v == _selectedCategory ? null : v);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showCampusFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildFilterSheet(
        title: 'Filter by Campus',
        items: AppConstants.campuses,
        selected: _selectedCampus,
        onSelect: (v) {
          setState(() => _selectedCampus = v == _selectedCampus ? null : v);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildFilterSheet({
    required String title,
    required List<String> items,
    required String? selected,
    required void Function(String) onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = item == selected;
              return ChoiceChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (_) => onSelect(item),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemsList(String type) {
    return Obx(() {
      if (_itemProvider.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Show error state with retry option
      if (_itemProvider.error.value != null &&
          _itemProvider.error.value!.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _itemProvider.error.value!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _itemProvider.getItems(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final filtered = _filterItems(_itemProvider.items, type);

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == 'found'
                    ? Icons.find_in_page_outlined
                    : Icons.search_off_outlined,
                size: 64,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty || _selectedCategory != null
                    ? 'No items match your filters'
                    : type == 'found'
                        ? 'No found items yet'
                        : 'No lost items reported',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              if (_searchQuery.isNotEmpty || _selectedCategory != null)
                TextButton(
                  onPressed: () => setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedCategory = null;
                    _selectedCampus = null;
                  }),
                  child: const Text('Clear Filters'),
                ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _itemProvider.getItems(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildItemCard(filtered[index]),
        ),
      );
    });
  }

  Widget _buildItemCard(Item item) {
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: item.displayImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.displayImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.image_outlined,
                              color: AppTheme.primaryColor),
                        ),
                        errorWidget: (_, _, _) =>
                            _buildImagePlaceholder(item),
                      )
                    : _buildImagePlaceholder(item),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildCategoryBadge(item.category),
                        const Spacer(),
                        _buildStatusBadge(item.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style:
                          Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12,
                            color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.locationFound,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Item item) {
    return Container(
      color: _categoryColor(item.category).withValues(alpha: 0.1),
      child: Icon(
        _categoryIcon(item.category),
        size: 36,
        color: _categoryColor(item.category),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _categoryColor(category).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: _categoryColor(category),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'open':
        color = AppTheme.successColor;
        break;
      case 'claimed':
        color = AppTheme.warningColor;
        break;
      case 'returned':
        color = AppTheme.infoColor;
        break;
      default:
        color = AppTheme.textSecondaryColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'wallet':
        return const Color(0xFF10B981);
      case 'phone':
        return const Color(0xFF3B82F6);
      case 'keys':
        return const Color(0xFFF59E0B);
      case 'id':
        return const Color(0xFFEF4444);
      case 'clothing':
        return const Color(0xFF8B5CF6);
      case 'bag':
        return const Color(0xFFEC4899);
      case 'textbook':
        return const Color(0xFF06B6D4);
      case 'electronics':
        return const Color(0xFF6366F1);
      default:
        return AppTheme.primaryColor;
    }
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
